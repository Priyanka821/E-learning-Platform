-- ============================================================
-- E-Learning Platform Demonstration & Analytical Queries
-- File: 04_queries_demo.sql
-- Description: Demonstrates dashboard views, role queries, and PL/SQL 
--              stored procedures execution.
-- ============================================================

SET SERVEROUTPUT ON;

PROMPT =========================================================
PROMPT 1. STUDENT DASHBOARD VIEW: Enrolled Courses & Progress
PROMPT =========================================================

SELECT 
    u.name AS student_name,
    c.title AS course_title,
    instr.name AS instructor_name,
    e.status AS enrollment_status,
    e.progress_percent || '%' AS completion_progress,
    e.enrolled_at
FROM ENROLLMENT e
JOIN USERS u ON e.user_id = u.user_id
JOIN COURSE c ON e.course_id = c.course_id
JOIN USERS instr ON c.instructor_id = instr.user_id
ORDER BY e.enrolled_at DESC;

PROMPT =========================================================
PROMPT 2. INSTRUCTOR DASHBOARD: Course Stats & Revenue
PROMPT =========================================================

SELECT 
    instr.name AS instructor_name,
    c.title AS course_title,
    c.price,
    c.approval_status,
    COUNT(e.enrollment_id) AS total_enrolled_students,
    NVL(SUM(p.amount), 0) AS total_revenue_generated
FROM COURSE c
JOIN USERS instr ON c.instructor_id = instr.user_id
LEFT JOIN ENROLLMENT e ON c.course_id = e.course_id
LEFT JOIN PAYMENT p ON c.course_id = p.course_id AND p.status = 'completed'
GROUP BY instr.name, c.title, c.price, c.approval_status;

PROMPT =========================================================
PROMPT 3. ADMIN QUEUE: Pending Course Approvals
PROMPT =========================================================

SELECT 
    c.course_id,
    c.title AS course_title,
    instr.name AS instructor_name,
    c.level_name,
    c.price,
    c.created_at
FROM COURSE c
JOIN USERS instr ON c.instructor_id = instr.user_id
WHERE c.approval_status = 'pending';

PROMPT =========================================================
PROMPT 4. DEMO: Testing PL/SQL Workflow (Register -> Enroll -> Complete -> Certify)
PROMPT =========================================================

DECLARE
    v_new_student_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Step 1: Registering new student "Carlos Mendez" ---');
    register_user(
        p_name          => 'Carlos Mendez',
        p_email         => 'carlos.mendez@example.com',
        p_password_hash => '$2b$12$KIXp7V/a.g9Zp3J1Q9q/1e5m.W9kQ5v.',
        p_role          => 'student',
        p_user_id       => v_new_student_id
    );
    DBMS_OUTPUT.PUT_LINE('Successfully registered! New User ID: ' || v_new_student_id);

    DBMS_OUTPUT.PUT_LINE('--- Step 2: Enrolling student in Course 1 ---');
    enroll_student(
        p_user_id   => v_new_student_id,
        p_course_id => 1
    );

    DBMS_OUTPUT.PUT_LINE('--- Step 3: Student Submits Assignment 1 & 2 ---');
    INSERT INTO SUBMISSION (user_id, assignment_id, file_url, score) 
    VALUES (v_new_student_id, 1, '/sub/carlos_assign1.sql', 98);

    INSERT INTO SUBMISSION (user_id, assignment_id, file_url, score) 
    VALUES (v_new_student_id, 2, '/sub/carlos_assign2.sql', 92);

    DBMS_OUTPUT.PUT_LINE('--- Step 4: Student Attempts Quiz 1 ---');
    INSERT INTO QUIZ_ATTEMPT (user_id, quiz_id, score) 
    VALUES (v_new_student_id, 1, 85);

    DBMS_OUTPUT.PUT_LINE('--- Step 5: Approving Pending Course 4 by Admin 1 ---');
    approve_course(p_course_id => 4, p_admin_id => 1, p_action => 'approved');

END;
/

PROMPT =========================================================
PROMPT 5. VERIFICATION: Student Progress & Certificate Check
PROMPT =========================================================

SELECT 
    u.name AS student_name,
    c.title AS course_title,
    e.progress_percent || '%' AS new_progress,
    e.status AS course_status,
    cert.certificate_url,
    cert.issued_at
FROM ENROLLMENT e
JOIN USERS u ON e.user_id = u.user_id
JOIN COURSE c ON e.course_id = c.course_id
LEFT JOIN CERTIFICATE cert ON e.user_id = cert.user_id AND e.course_id = cert.course_id
WHERE u.email = 'carlos.mendez@example.com';

COMMIT;
