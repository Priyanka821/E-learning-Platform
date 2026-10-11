from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from db.connection import get_db

instructor_bp = Blueprint('instructor', __name__)

def check_instructor():
    if 'user_id' not in session or session.get('role') != 'instructor':
        return False
    return True

@instructor_bp.route('/instructor/dashboard')
def dashboard():
    if not check_instructor():
        return redirect(url_for('auth.login'))

    user_id = session['user_id']
    conn = get_db()
    cursor = conn.cursor()

    # List of owned courses with student count
    cursor.execute("""
        SELECT c.*,
               (SELECT COUNT(*) FROM ENROLLMENT e WHERE e.course_id = c.course_id) as student_count,
               (SELECT COUNT(*) FROM MODULE m WHERE m.course_id = c.course_id) as module_count
        FROM COURSE c
        WHERE c.instructor_id = ?
        ORDER BY c.created_at DESC;
    """, (user_id,))
    courses = cursor.fetchall()

    # Submissions to grade
    cursor.execute("""
        SELECT s.submission_id, s.submitted_at, s.file_url, s.score, u.name as student_name, a.title as assignment_title
        FROM SUBMISSION s
        JOIN USER u ON s.user_id = u.user_id
        JOIN ASSIGNMENT a ON s.assignment_id = a.assignment_id
        JOIN LESSON l ON a.lesson_id = l.lesson_id
        JOIN MODULE m ON l.module_id = m.module_id
        JOIN COURSE c ON m.course_id = c.course_id
        WHERE c.instructor_id = ?
        ORDER BY s.submitted_at DESC LIMIT 10;
    """, (user_id,))
    submissions = cursor.fetchall()

    conn.close()

    return render_template('dashboard_instructor.html', courses=courses, submissions=submissions)

@instructor_bp.route('/instructor/add_course', methods=['POST'])
def add_course():
    if not check_instructor():
        return redirect(url_for('auth.login'))

    user_id = session['user_id']
    title = request.form.get('title', '').strip()
    description = request.form.get('description', '').strip()
    price = request.form.get('price', 0.0, type=float)
    level = request.form.get('level', 'Beginner')

    if not title:
        flash('Course title is required.', 'error')
        return redirect(url_for('instructor.dashboard'))

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO COURSE (instructor_id, title, description, price, level, approval_status)
        VALUES (?, ?, ?, ?, ?, 'pending');
    """, (user_id, title, description, price, level))
    conn.commit()
    conn.close()

    flash('Course created successfully! Submitted for admin approval.', 'success')
    return redirect(url_for('instructor.dashboard'))

@instructor_bp.route('/instructor/grade_submission/<int:submission_id>', methods=['POST'])
def grade_submission(submission_id):
    if not check_instructor():
        return redirect(url_for('auth.login'))

    score = request.form.get('score', type=int)
    feedback = request.form.get('feedback', '').strip()

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE SUBMISSION
        SET score = ?, feedback = ?
        WHERE submission_id = ?;
    """, (score, feedback, submission_id))
    conn.commit()
    conn.close()

    flash('Submission graded successfully!', 'success')
    return redirect(url_for('instructor.dashboard'))
