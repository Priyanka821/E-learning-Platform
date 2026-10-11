from flask import Flask, redirect, url_for, session
from config import Config
from db.connection import init_db
from routes.auth import auth_bp
from routes.student import student_bp
from routes.instructor import instructor_bp
from routes.admin import admin_bp

app = Flask(__name__)
app.config.from_object(Config)

# Register Blueprints
app.register_blueprint(auth_bp)
app.register_blueprint(student_bp)
app.register_blueprint(instructor_bp)
app.register_blueprint(admin_bp)

@app.route('/')
def index():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    
    role = session.get('role')
    if role == 'instructor':
        return redirect(url_for('instructor.dashboard'))
    elif role == 'admin':
        return redirect(url_for('admin.dashboard'))
    return redirect(url_for('student.dashboard'))

if __name__ == '__main__':
    # Initialize DB & seed data
    init_db()
    print("=========================================================")
    print(" E-Learning Web Application Starting...")
    print(" Open browser at: http://127.0.0.1:5000")
    print("=========================================================")
    app.run(host='127.0.0.1', port=5000, debug=True)
