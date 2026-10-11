from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from db.connection import get_db
from utils.security import hash_password, verify_password

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password', '')

        conn = get_db()
        cursor = conn.cursor()

        # Check USER table first
        cursor.execute("SELECT * FROM USER WHERE LOWER(email) = ?;", (email,))
        user = cursor.fetchone()

        if user:
            if verify_password(password, user['password_hash']):
                session['user_id'] = user['user_id']
                session['name'] = user['name']
                session['role'] = user['role']
                session['is_admin'] = False
                
                if user['role'] == 'instructor':
                    return redirect(url_for('instructor.dashboard'))
                return redirect(url_for('student.dashboard'))
            else:
                flash('Invalid credentials. Please check your password.', 'error')
                return render_template('login.html', email=email)

        # Check ADMIN table
        cursor.execute("SELECT * FROM ADMIN WHERE LOWER(email) = ?;", (email,))
        admin = cursor.fetchone()

        if admin:
            if verify_password(password, admin['password_hash']):
                session['user_id'] = admin['admin_id']
                session['name'] = admin['name']
                session['role'] = 'admin'
                session['is_admin'] = True
                return redirect(url_for('admin.dashboard'))
            else:
                flash('Invalid credentials. Please check your password.', 'error')
                return render_template('login.html', email=email)

        # Email not found in both USER and ADMIN
        flash('No account found with this email. Please register below.', 'info')
        return redirect(url_for('auth.register', email=email))

    prefilled_email = request.args.get('email', '')
    return render_template('login.html', email=prefilled_email)

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password', '')
        role = request.form.get('role', 'student')

        if not name or not email or not password:
            flash('All fields are required.', 'error')
            return render_template('register.html', name=name, email=email, role=role)

        conn = get_db()
        cursor = conn.cursor()

        # Check uniqueness
        cursor.execute("SELECT user_id FROM USER WHERE LOWER(email) = ?;", (email,))
        if cursor.fetchone():
            flash('An account with this email already exists.', 'error')
            return render_template('register.html', name=name, email=email, role=role)

        hashed = hash_password(password)
        cursor.execute("""
            INSERT INTO USER (name, email, password_hash, role)
            VALUES (?, ?, ?, ?);
        """, (name, email, hashed, role))
        conn.commit()

        user_id = cursor.lastrowid
        conn.close()

        # Auto login
        session['user_id'] = user_id
        session['name'] = name
        session['role'] = role
        session['is_admin'] = False

        flash('Account created successfully!', 'success')
        if role == 'instructor':
            return redirect(url_for('instructor.dashboard'))
        return redirect(url_for('student.dashboard'))

    prefilled_email = request.args.get('email', '')
    return render_template('register.html', email=prefilled_email)

@auth_bp.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out.', 'info')
    return redirect(url_for('auth.login'))
