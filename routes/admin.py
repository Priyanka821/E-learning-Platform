from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from db.connection import get_db

admin_bp = Blueprint('admin', __name__)

def check_admin():
    if 'user_id' not in session or session.get('role') != 'admin':
        return False
    return True

@admin_bp.route('/admin/dashboard')
def dashboard():
    if not check_admin():
        return redirect(url_for('auth.login'))

    conn = get_db()
    cursor = conn.cursor()

    # Pending Course Queue
    cursor.execute("""
        SELECT c.*, u.name as instructor_name
        FROM COURSE c
        JOIN USER u ON c.instructor_id = u.user_id
        WHERE c.approval_status = 'pending'
        ORDER BY c.created_at ASC;
    """, ())
    pending_courses = cursor.fetchall()

    # Approved Courses
    cursor.execute("""
        SELECT c.*, u.name as instructor_name,
               (SELECT COUNT(*) FROM ENROLLMENT e WHERE e.course_id = c.course_id) as student_count
        FROM COURSE c
        JOIN USER u ON c.instructor_id = u.user_id
        WHERE c.approval_status = 'approved'
        ORDER BY c.created_at DESC;
    """, ())
    approved_courses = cursor.fetchall()

    # Platform Users
    cursor.execute("SELECT * FROM USER ORDER BY created_at DESC;", ())
    users = cursor.fetchall()

    # Platform Totals
    cursor.execute("SELECT COUNT(*) FROM USER WHERE role = 'student';")
    total_students = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM USER WHERE role = 'instructor';")
    total_instructors = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM COURSE WHERE approval_status = 'approved';")
    total_courses = cursor.fetchone()[0]

    cursor.execute("SELECT SUM(amount) FROM PAYMENT WHERE status = 'completed';")
    total_revenue = cursor.fetchone()[0] or 0.0

    conn.close()

    return render_template('dashboard_admin.html',
                           pending_courses=pending_courses,
                           approved_courses=approved_courses,
                           users=users,
                           total_students=total_students,
                           total_instructors=total_instructors,
                           total_courses=total_courses,
                           total_revenue=round(total_revenue, 2))

@admin_bp.route('/admin/approve_course/<int:course_id>', methods=['POST'])
def approve_course(course_id):
    if not check_admin():
        return redirect(url_for('auth.login'))

    action = request.form.get('action', 'approved') # 'approved' or 'rejected'
    admin_id = session['user_id']

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE COURSE
        SET approval_status = ?, approved_by_admin_id = ?, approved_at = CURRENT_TIMESTAMP
        WHERE course_id = ?;
    """, (action, admin_id, course_id))
    conn.commit()
    conn.close()

    flash(f'Course status updated to {action}.', 'success')
    return redirect(url_for('admin.dashboard'))

@admin_bp.route('/admin/delete_user/<int:user_id>', methods=['POST'])
def delete_user(user_id):
    if not check_admin():
        return redirect(url_for('auth.login'))

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM USER WHERE user_id = ?;", (user_id,))
    conn.commit()
    conn.close()

    flash('User deleted successfully.', 'success')
    return redirect(url_for('admin.dashboard'))
