-- ============================================================
-- E-Learning Platform Business Logic (PL/SQL)
-- File: 02_procedures_triggers.sql
-- Description: Contains stored procedures, functions, and triggers 
--              for student progress tracking, enrollment, & course approval.
-- ============================================================

-- ---------------------------------------------------------
-- 1. Helper Function: Get Course ID from Lesson ID
-- ---------------------------------------------------------
CREATE OR REPLACE FUNCTION get_course_from_lesson(p_lesson_id IN NUMBER) 
RETURN NUMBER IS
    v_course_id NUMBER;
BEGIN
    SELECT m.course_id INTO v_course_id
    FROM LESSON l
    JOIN MODULE m ON l.module_id = m.module_id
    WHERE l.lesson_id = p_lesson_id;
    
    RETURN v_course_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

-- ---------------------------------------------------------
-- 2. Procedure: Recalculate Student Progress Percent
-- ---------------------------------------------------------
CREATE OR REPLACE PROCEDURE recalculate_progress (
    p_user_id   IN NUMBER,
    p_course_id IN NUMBER
) IS
    v_total_assignments     NUMBER := 0;
    v_submitted_assignments NUMBER := 0;
    v_total_quizzes         NUMBER := 0;
    v_attempted_quizzes     NUMBER := 0;
    
    v_assign_ratio          NUMBER := 0;
    v_quiz_ratio            NUMBER := 0;
    v_new_progress          NUMBER(5,2) := 0.00;
    v_cert_exists           NUMBER := 0;
BEGIN
    -- 1. Count total assignments in the course
    SELECT COUNT(a.assignment_id)
    INTO v_total_assignments
    FROM ASSIGNMENT a
    JOIN LESSON l ON a.lesson_id = l.lesson_id
    JOIN MODULE m ON l.module_id = m.module_id
    WHERE m.course_id = p_course_id;

    -- 2. Count distinct submitted assignments by student
    SELECT COUNT(DISTINCT s.assignment_id)
    INTO v_submitted_assignments
    FROM SUBMISSION s
    JOIN ASSIGNMENT a ON s.assignment_id = a.assignment_id
    JOIN LESSON l ON a.lesson_id = l.lesson_id
    JOIN MODULE m ON l.module_id = m.module_id
    WHERE s.user_id = p_user_id AND m.course_id = p_course_id;

    -- 3. Count total quizzes in the course
    SELECT COUNT(q.quiz_id)
    INTO v_total_quizzes
    FROM QUIZ q
    JOIN LESSON l ON q.lesson_id = l.lesson_id
    JOIN MODULE m ON l.module_id = m.module_id
    WHERE m.course_id = p_course_id;

    -- 4. Count distinct attempted quizzes by student
    SELECT COUNT(DISTINCT qa.quiz_id)
    INTO v_attempted_quizzes
    FROM QUIZ_ATTEMPT qa
    JOIN QUIZ q ON qa.quiz_id = q.quiz_id
    JOIN LESSON l ON q.lesson_id = l.lesson_id
    JOIN MODULE m ON l.module_id = m.module_id
    WHERE qa.user_id = p_user_id AND m.course_id = p_course_id;

    -- Calculate weighted progress based on course items available
    IF v_total_assignments > 0 AND v_total_quizzes > 0 THEN
        v_assign_ratio := (v_submitted_assignments / v_total_assignments) * 0.5;
        v_quiz_ratio   := (v_attempted_quizzes / v_total_quizzes) * 0.5;
        v_new_progress := (v_assign_ratio + v_quiz_ratio) * 100;
    ELSIF v_total_assignments > 0 THEN
        v_new_progress := (v_submitted_assignments / v_total_assignments) * 100;
    ELSIF v_total_quizzes > 0 THEN
        v_new_progress := (v_attempted_quizzes / v_total_quizzes) * 100;
    ELSE
        v_new_progress := 0.00;
    END IF;

    -- Cap progress at 100%
    IF v_new_progress > 100 THEN
        v_new_progress := 100.00;
    END IF;

    -- Update Enrollment
    UPDATE ENROLLMENT
    SET progress_percent = v_new_progress,
        status = CASE WHEN v_new_progress >= 100 THEN 'completed' ELSE 'active' END
    WHERE user_id = p_user_id AND course_id = p_course_id;

    -- Auto-issue Certificate on completion
    IF v_new_progress >= 100 THEN
        SELECT COUNT(*) INTO v_cert_exists 
        FROM CERTIFICATE 
        WHERE user_id = p_user_id AND course_id = p_course_id;
        
        IF v_cert_exists = 0 THEN
            INSERT INTO CERTIFICATE (user_id, course_id, certificate_url)
            VALUES (p_user_id, p_course_id, '/certs/cert_' || p_user_id || '_' || p_course_id || '.pdf');
        END IF;
    END IF;

    COMMIT;
END recalculate_progress;
/

-- ---------------------------------------------------------
-- 3. Triggers to Auto-Update Progress on Submission / Quiz
-- ---------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_after_submission
AFTER INSERT OR UPDATE ON SUBMISSION
FOR EACH ROW
DECLARE
    v_course_id NUMBER;
BEGIN
    SELECT m.course_id INTO v_course_id
    FROM ASSIGNMENT a
    JOIN LESSON l ON a.lesson_id = l.lesson_id
    JOIN MODULE m ON l.module_id = m.module_id
    WHERE a.assignment_id = :NEW.assignment_id;

    recalculate_progress(:NEW.user_id, v_course_id);
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Prevents transaction rollback if progress sync fails
END;
/

CREATE OR REPLACE TRIGGER trg_after_quiz_attempt
AFTER INSERT OR UPDATE ON QUIZ_ATTEMPT
FOR EACH ROW
DECLARE
    v_course_id NUMBER;
BEGIN
    SELECT m.course_id INTO v_course_id
    FROM QUIZ q
    JOIN LESSON l ON q.lesson_id = l.lesson_id
    JOIN MODULE m ON l.module_id = m.module_id
    WHERE q.quiz_id = :NEW.quiz_id;

    recalculate_progress(:NEW.user_id, v_course_id);
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- ---------------------------------------------------------
-- 4. Procedure: User Registration
-- ---------------------------------------------------------
CREATE OR REPLACE PROCEDURE register_user (
    p_name          IN  VARCHAR2,
    p_email         IN  VARCHAR2,
    p_password_hash IN  VARCHAR2,
    p_role          IN  VARCHAR2,
    p_user_id       OUT NUMBER
) IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM USERS WHERE email = LOWER(p_email);
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Email address already registered.');
    END IF;

    INSERT INTO USERS (name, email, password_hash, role)
    VALUES (p_name, LOWER(p_email), p_password_hash, p_role)
    RETURNING user_id INTO p_user_id;

    COMMIT;
END register_user;
/

-- ---------------------------------------------------------
-- 5. Procedure: Student Course Enrollment
-- ---------------------------------------------------------
CREATE OR REPLACE PROCEDURE enroll_student (
    p_user_id   IN NUMBER,
    p_course_id IN NUMBER
) IS
    v_status VARCHAR2(20);
BEGIN
    -- Check if course is approved
    SELECT approval_status INTO v_status FROM COURSE WHERE course_id = p_course_id;
    IF v_status != 'approved' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot enroll in an unapproved course.');
    END IF;

    INSERT INTO ENROLLMENT (user_id, course_id, status, progress_percent)
    VALUES (p_user_id, p_course_id, 'active', 0.00);

    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('User is already enrolled in this course.');
END enroll_student;
/

-- ---------------------------------------------------------
-- 6. Procedure: Admin Course Approval
-- ---------------------------------------------------------
CREATE OR REPLACE PROCEDURE approve_course (
    p_course_id IN NUMBER,
    p_admin_id  IN NUMBER,
    p_action    IN VARCHAR2 -- 'approved' or 'rejected'
) IS
BEGIN
    UPDATE COURSE
    SET approval_status = LOWER(p_action),
        approved_by_admin_id = p_admin_id,
        approved_at = CURRENT_TIMESTAMP
    WHERE course_id = p_course_id;

    COMMIT;
END approve_course;
/
