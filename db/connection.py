import sqlite3
import os
from config import Config

def get_db():
    os.makedirs(os.path.dirname(Config.DB_PATH), exist_ok=True)
    conn = sqlite3.connect(Config.DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn

def init_db():
    os.makedirs(os.path.dirname(Config.DB_PATH), exist_ok=True)
    db_exists = os.path.exists(Config.DB_PATH)
    
    conn = get_db()
    cursor = conn.cursor()
    
    # Run Schema DDL
    if os.path.exists(Config.SCHEMA_PATH):
        with open(Config.SCHEMA_PATH, 'r', encoding='utf-8') as f:
            cursor.executescript(f.read())
            
    # Load Seed Data if database was just created or tables are empty
    cursor.execute("SELECT COUNT(*) FROM USER;")
    user_count = cursor.fetchone()[0]
    
    if user_count == 0 and os.path.exists(Config.SEED_PATH):
        with open(Config.SEED_PATH, 'r', encoding='utf-8') as f:
            cursor.executescript(f.read())
            
    conn.commit()
    conn.close()

def recalculate_progress(user_id: int, course_id: int):
    conn = get_db()
    cursor = conn.cursor()
    
    # 1. Total assignments in course
    cursor.execute("""
        SELECT COUNT(a.assignment_id)
        FROM ASSIGNMENT a
        JOIN LESSON l ON a.lesson_id = l.lesson_id
        JOIN MODULE m ON l.module_id = m.module_id
        WHERE m.course_id = ?;
    """, (course_id,))
    total_assignments = cursor.fetchone()[0] or 0
    
    # 2. Submitted assignments by student
    cursor.execute("""
        SELECT COUNT(DISTINCT s.assignment_id)
        FROM SUBMISSION s
        JOIN ASSIGNMENT a ON s.assignment_id = a.assignment_id
        JOIN LESSON l ON a.lesson_id = l.lesson_id
        JOIN MODULE m ON l.module_id = m.module_id
        WHERE s.user_id = ? AND m.course_id = ?;
    """, (user_id, course_id))
    submitted_assignments = cursor.fetchone()[0] or 0

    # 3. Total quizzes in course
    cursor.execute("""
        SELECT COUNT(q.quiz_id)
        FROM QUIZ q
        JOIN LESSON l ON q.lesson_id = l.lesson_id
        JOIN MODULE m ON l.module_id = m.module_id
        WHERE m.course_id = ?;
    """, (course_id,))
    total_quizzes = cursor.fetchone()[0] or 0

    # 4. Attempted quizzes by student
    cursor.execute("""
        SELECT COUNT(DISTINCT qa.quiz_id)
        FROM QUIZ_ATTEMPT qa
        JOIN QUIZ q ON qa.quiz_id = q.quiz_id
        JOIN LESSON l ON q.lesson_id = l.lesson_id
        JOIN MODULE m ON l.module_id = m.module_id
        WHERE qa.user_id = ? AND m.course_id = ?;
    """, (user_id, course_id))
    attempted_quizzes = cursor.fetchone()[0] or 0

    # Section 7 Logic from specification:
    # progress = ((submitted / total_assignments)*0.5 + (attempted / total_quizzes)*0.5) * 100
    if total_assignments > 0 and total_quizzes > 0:
        progress = ((submitted_assignments / total_assignments) * 0.5 + (attempted_quizzes / total_quizzes) * 0.5) * 100
    elif total_assignments > 0:
        progress = (submitted_assignments / total_assignments) * 100
    elif total_quizzes > 0:
        progress = (attempted_quizzes / total_quizzes) * 100
    else:
        progress = 0.0

    progress = round(min(progress, 100.0), 2)
    status = 'completed' if progress >= 100.0 else 'active'

    cursor.execute("""
        UPDATE ENROLLMENT
        SET progress_percent = ?, status = ?
        WHERE user_id = ? AND course_id = ?;
    """, (progress, status, user_id, course_id))

    # Auto issue certificate if 100%
    if progress >= 100.0:
        cursor.execute("SELECT COUNT(*) FROM CERTIFICATE WHERE user_id = ? AND course_id = ?;", (user_id, course_id))
        if cursor.fetchone()[0] == 0:
            cert_url = f"/static/certificates/cert_{user_id}_{course_id}.pdf"
            cursor.execute("""
                INSERT INTO CERTIFICATE (user_id, course_id, certificate_url)
                VALUES (?, ?, ?);
            """, (user_id, course_id, cert_url))

    conn.commit()
    conn.close()
