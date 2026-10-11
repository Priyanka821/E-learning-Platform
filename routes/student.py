from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from db.connection import get_db, recalculate_progress

student_bp = Blueprint('student', __name__)

def check_student():
    if 'user_id' not in session or session.get('role') != 'student':
        return False
    return True

@student_bp.route('/student/dashboard')
def dashboard():
    if not check_student():
        return redirect(url_for('auth.login'))

    user_id = session['user_id']
    conn = get_db()
    cursor = conn.cursor()

    # Get Enrolled Courses with Progress
    cursor.execute("""
        SELECT e.enrollment_id, e.progress_percent, e.status, e.enrolled_at,
               c.course_id, c.title, c.description, c.level, u.name as instructor_name
        FROM ENROLLMENT e
        JOIN COURSE c ON e.course_id = c.course_id
        JOIN USER u ON c.instructor_id = u.user_id
        WHERE e.user_id = ?;
    """, (user_id,))
    enrollments = cursor.fetchall()

    # Get Upcoming Assignments
    cursor.execute("""
        SELECT a.assignment_id, a.title, a.due_date, c.title as course_title
        FROM ASSIGNMENT a
        JOIN LESSON l ON a.lesson_id = l.lesson_id
        JOIN MODULE m ON l.module_id = m.module_id
        JOIN COURSE c ON m.course_id = c.course_id
        JOIN ENROLLMENT e ON c.course_id = e.course_id
        WHERE e.user_id = ?
        ORDER BY a.due_date ASC LIMIT 5;
    """, (user_id,))
    upcoming_assignments = cursor.fetchall()

    # Quiz Attempts History
    cursor.execute("""
        SELECT qa.score, qa.attempted_at, q.title as quiz_title, q.passing_score
        FROM QUIZ_ATTEMPT qa
        JOIN QUIZ q ON qa.quiz_id = q.quiz_id
        WHERE qa.user_id = ?
        ORDER BY qa.attempted_at DESC LIMIT 5;
    """, (user_id,))
    quiz_history = cursor.fetchall()

    # Available Certificates
    cursor.execute("""
        SELECT cert.certificate_id, cert.certificate_url, cert.issued_at, c.title as course_title
        FROM CERTIFICATE cert
        JOIN COURSE c ON cert.course_id = c.course_id
        WHERE cert.user_id = ?;
    """, (user_id,))
    certificates = cursor.fetchall()

    conn.close()

    return render_template('dashboard_student.html',
                           enrollments=enrollments,
                           upcoming_assignments=upcoming_assignments,
                           quiz_history=quiz_history,
                           certificates=certificates)

@student_bp.route('/courses')
def course_catalog():
    conn = get_db()
    cursor = conn.cursor()

    user_id = session.get('user_id')

    cursor.execute("""
        SELECT c.*, u.name as instructor_name,
               (SELECT COUNT(*) FROM ENROLLMENT e WHERE e.course_id = c.course_id) as student_count,
               (SELECT e.status FROM ENROLLMENT e WHERE e.course_id = c.course_id AND e.user_id = ?) as user_enroll_status
        FROM COURSE c
        JOIN USER u ON c.instructor_id = u.user_id
        WHERE c.approval_status = 'approved';
    """, (user_id or 0,))
    courses = cursor.fetchall()
    conn.close()

    return render_template('course_catalog.html', courses=courses)

@student_bp.route('/enroll/<int:course_id>', methods=['POST'])
def enroll(course_id):
    if not check_student():
        return redirect(url_for('auth.login'))

    user_id = session['user_id']
    conn = get_db()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO ENROLLMENT (user_id, course_id, status, progress_percent)
            VALUES (?, ?, 'active', 0.00);
        """, (user_id, course_id))

        # Record payment entry
        cursor.execute("SELECT price FROM COURSE WHERE course_id = ?;", (course_id,))
        course = cursor.fetchone()
        price = course['price'] if course else 0.00

        cursor.execute("""
            INSERT INTO PAYMENT (user_id, course_id, amount, status, paid_at)
            VALUES (?, ?, ?, 'completed', CURRENT_TIMESTAMP);
        """, (user_id, course_id, price))

        conn.commit()
        flash('Successfully enrolled in the course!', 'success')
    except Exception as e:
        flash('You are already enrolled in this course.', 'info')
    finally:
        conn.close()

    return redirect(url_for('student.dashboard'))

@student_bp.route('/course/<int:course_id>')
def course_detail(course_id):
    conn = get_db()
    cursor = conn.cursor()

    user_id = session.get('user_id')

    # Get Course Info
    cursor.execute("""
        SELECT c.*, u.name as instructor_name
        FROM COURSE c
        JOIN USER u ON c.instructor_id = u.user_id
        WHERE c.course_id = ?;
    """, (course_id,))
    course = cursor.fetchone()

    if not course:
        flash('Course not found.', 'error')
        return redirect(url_for('student.course_catalog'))

    # Get Modules & Lessons
    cursor.execute("SELECT * FROM MODULE WHERE course_id = ? ORDER BY order_index ASC;", (course_id,))
    modules = cursor.fetchall()

    modules_data = []
    for mod in modules:
        cursor.execute("SELECT * FROM LESSON WHERE module_id = ? ORDER BY order_index ASC;", (mod['module_id'],))
        lessons = cursor.fetchall()

        lessons_data = []
        for les in lessons:
            cursor.execute("SELECT * FROM ASSIGNMENT WHERE lesson_id = ?;", (les['lesson_id'],))
            assignments = cursor.fetchall()

            cursor.execute("SELECT * FROM QUIZ WHERE lesson_id = ?;", (les['lesson_id'],))
            quizzes = cursor.fetchall()

            lessons_data.append({
                'lesson': les,
                'assignments': assignments,
                'quizzes': quizzes
            })

        modules_data.append({
            'module': mod,
            'lessons': lessons_data
        })

    # Get Submissions & Attempts by User
    user_submissions = {}
    user_attempts = {}
    if user_id:
        cursor.execute("SELECT assignment_id, score, file_url FROM SUBMISSION WHERE user_id = ?;", (user_id,))
        for sub in cursor.fetchall():
            user_submissions[sub['assignment_id']] = sub

        cursor.execute("SELECT quiz_id, score FROM QUIZ_ATTEMPT WHERE user_id = ?;", (user_id,))
        for att in cursor.fetchall():
            user_attempts[att['quiz_id']] = att

    conn.close()

    return render_template('course_detail.html',
                           course=course,
                           modules_data=modules_data,
                           user_submissions=user_submissions,
                           user_attempts=user_attempts)

@student_bp.route('/submit_assignment/<int:assignment_id>', methods=['POST'])
def submit_assignment(assignment_id):
    if not check_student():
        return redirect(url_for('auth.login'))

    user_id = session['user_id']
    file_url = request.form.get('file_url', '').strip() or '/uploads/assignment_solution.sql'

    conn = get_db()
    cursor = conn.cursor()

    # Get course_id
    cursor.execute("""
        SELECT m.course_id
        FROM ASSIGNMENT a
        JOIN LESSON l ON a.lesson_id = l.lesson_id
        JOIN MODULE m ON l.module_id = m.module_id
        WHERE a.assignment_id = ?;
    """, (assignment_id,))
    res = cursor.fetchone()
    if not res:
        flash('Assignment not found.', 'error')
        return redirect(url_for('student.dashboard'))

    course_id = res['course_id']

    # Insert or update submission
    cursor.execute("""
        INSERT INTO SUBMISSION (user_id, assignment_id, file_url, score)
        VALUES (?, ?, ?, 90)
        ON CONFLICT(submission_id) DO UPDATE SET file_url=excluded.file_url;
    """, (user_id, assignment_id, file_url))
    conn.commit()
    conn.close()

    # Recalculate progress
    recalculate_progress(user_id, course_id)

    flash('Assignment submitted successfully! Progress updated.', 'success')
    return redirect(url_for('student.course_detail', course_id=course_id))

@student_bp.route('/attempt_quiz/<int:quiz_id>', methods=['POST'])
def attempt_quiz(quiz_id):
    if not check_student():
        return redirect(url_for('auth.login'))

    user_id = session['user_id']

    conn = get_db()
    cursor = conn.cursor()

    # Get questions
    cursor.execute("SELECT * FROM QUESTION WHERE quiz_id = ?;", (quiz_id,))
    questions = cursor.fetchall()

    score = 0
    total_points = 0
    for q in questions:
        total_points += q['points']
        selected_option = request.form.get(f"question_{q['question_id']}")
        if selected_option:
            cursor.execute("SELECT is_correct FROM ANSWER_OPTION WHERE option_id = ?;", (selected_option,))
            opt = cursor.fetchone()
            if opt and opt['is_correct'] == 1:
                score += q['points']

    scaled_score = int((score / total_points) * 100) if total_points > 0 else 100

    cursor.execute("""
        INSERT INTO QUIZ_ATTEMPT (user_id, quiz_id, score)
        VALUES (?, ?, ?);
    """, (user_id, quiz_id, scaled_score))
    conn.commit()

    # Get course_id
    cursor.execute("""
        SELECT m.course_id
        FROM QUIZ q
        JOIN LESSON l ON q.lesson_id = l.lesson_id
        JOIN MODULE m ON l.module_id = m.module_id
        WHERE q.quiz_id = ?;
    """, (quiz_id,))
    course_id = cursor.fetchone()['course_id']
    conn.close()

    # Recalculate progress
    recalculate_progress(user_id, course_id)

    flash(f'Quiz completed! Your score: {scaled_score}%. Progress updated.', 'success')
    return redirect(url_for('student.course_detail', course_id=course_id))
