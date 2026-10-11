-- ============================================================
-- E-Learning Platform Sample Seed Data
-- File: 03_seed_data.sql
-- Description: Populates realistic seed data for testing DB features.
-- ============================================================

SET DEFINE OFF;

-- ---------------------------------------------------------
-- Admins
-- ---------------------------------------------------------
INSERT INTO ADMIN (admin_id, name, email, password_hash, access_level) VALUES
(1, 'System Super Admin', 'admin@elearning.org', '$2b$12$KIXp7V/a.g9Zp3J1Q9q/1e5m.W9kQ5v.', 'superadmin');

INSERT INTO ADMIN (admin_id, name, email, password_hash, access_level) VALUES
(2, 'Sarah Admin', 'sarah.admin@elearning.org', '$2b$12$KIXp7V/a.g9Zp3J1Q9q/1e5m.W9kQ5v.', 'moderator');

-- ---------------------------------------------------------
-- Users (Instructors & Students)
-- ---------------------------------------------------------
-- Instructors (IDs 1-3)
INSERT INTO USERS (user_id, name, email, password_hash, role) VALUES
(1, 'Dr. Aris Vance', 'vance@university.edu', '$2b$12$KIXp7V/a.g9Zp3J1Q9q/1e5m.W9kQ5v.', 'instructor');

INSERT INTO USERS (user_id, name, email, password_hash, role) VALUES
(2, 'Elena Rostova', 'elena@techacademy.io', '$2b$12$KIXp7V/a.g9Zp3J1Q9q/1e5m.W9kQ5v.', 'instructor');

INSERT INTO USERS (user_id, name, email, password_hash, role) VALUES
(3, 'Marcus Chen', 'marcus@codecampus.org', '$2b$12$KIXp7V/a.g9Zp3J1Q9q/1e5m.W9kQ5v.', 'instructor');

-- Students (IDs 4-7)
INSERT INTO USERS (user_id, name, email, password_hash, role) VALUES
(4, 'David Miller', 'david.m@gmail.com', '$2b$12$KIXp7V/a.g9Zp3J1Q9q/1e5m.W9kQ5v.', 'student');

INSERT INTO USERS (user_id, name, email, password_hash, role) VALUES
(5, 'Sophia Patel', 'sophia.p@outlook.com', '$2b$12$KIXp7V/a.g9Zp3J1Q9q/1e5m.W9kQ5v.', 'student');

INSERT INTO USERS (user_id, name, email, password_hash, role) VALUES
(6, 'James Wilson', 'jwilson@yahoo.com', '$2b$12$KIXp7V/a.g9Zp3J1Q9q/1e5m.W9kQ5v.', 'student');

INSERT INTO USERS (user_id, name, email, password_hash, role) VALUES
(7, 'Aisha Khan', 'aisha.k@gmail.com', '$2b$12$KIXp7V/a.g9Zp3J1Q9q/1e5m.W9kQ5v.', 'student');

-- ---------------------------------------------------------
-- Courses
-- ---------------------------------------------------------
INSERT INTO COURSE (course_id, instructor_id, approved_by_admin_id, title, description, price, level_name, approval_status, approved_at) VALUES
(1, 1, 1, 'Database Systems & SQL Fundamentals', 'Comprehensive masterclass on relational database modeling, normalization, SQL queries, indexing, and PL/SQL stored procedures.', 49.99, 'Beginner', 'approved', CURRENT_TIMESTAMP);

INSERT INTO COURSE (course_id, instructor_id, approved_by_admin_id, title, description, price, level_name, approval_status, approved_at) VALUES
(2, 2, 1, 'Full-Stack Web Development with Flask & JS', 'Build scalable web applications with Flask, PyMySQL REST APIs, vanilla JS, and modern CSS frameworks.', 79.99, 'Intermediate', 'approved', CURRENT_TIMESTAMP);

INSERT INTO COURSE (course_id, instructor_id, approved_by_admin_id, title, description, price, level_name, approval_status, approved_at) VALUES
(3, 3, 1, 'Data Structures & Algorithms Essentials', 'Master big-O notation, linked lists, binary trees, graphs, sorting, and dynamic programming.', 29.99, 'Intermediate', 'approved', CURRENT_TIMESTAMP);

INSERT INTO COURSE (course_id, instructor_id, approved_by_admin_id, title, description, price, level_name, approval_status, approved_at) VALUES
(4, 1, NULL, 'Advanced Oracle PL/SQL & Performance Tuning', 'In-depth guide to package optimization, bulk collection, ref cursors, and query execution plans.', 89.99, 'Advanced', 'pending', NULL);

-- ---------------------------------------------------------
-- Modules
-- ---------------------------------------------------------
-- Modules for Course 1
INSERT INTO MODULE (module_id, course_id, title, order_index) VALUES (1, 1, 'Module 1: Relational Modeling & ERD', 1);
INSERT INTO MODULE (module_id, course_id, title, order_index) VALUES (2, 1, 'Module 2: Advanced SQL & DML Operations', 2);

-- Modules for Course 2
INSERT INTO MODULE (module_id, course_id, title, order_index) VALUES (3, 2, 'Module 1: Flask Routing & Architecture', 1);

-- ---------------------------------------------------------
-- Lessons
-- ---------------------------------------------------------
-- Lessons for Module 1
INSERT INTO LESSON (lesson_id, module_id, title, content_type, video_url, duration_minutes, order_index) VALUES
(1, 1, 'Introduction to Relational Databases', 'video', 'https://cdn.elearning.org/videos/db_intro.mp4', 25, 1);
INSERT INTO LESSON (lesson_id, module_id, title, content_type, video_url, duration_minutes, order_index) VALUES
(2, 1, 'Designing ER Diagrams & Normalization', 'video', 'https://cdn.elearning.org/videos/erd_norm.mp4', 40, 2);

-- Lessons for Module 2
INSERT INTO LESSON (lesson_id, module_id, title, content_type, video_url, duration_minutes, order_index) VALUES
(3, 2, 'Complex SQL Joins and Aggregates', 'video', 'https://cdn.elearning.org/videos/sql_joins.mp4', 35, 1);

-- ---------------------------------------------------------
-- Assignments
-- ---------------------------------------------------------
INSERT INTO ASSIGNMENT (assignment_id, lesson_id, title, instructions, due_date, max_score) VALUES
(1, 2, 'Assignment 1: ERD Normalization Exercise', 'Design a 3NF relational schema for a library management database. Submit your SQL script.', SYSDATE + 7, 100);

INSERT INTO ASSIGNMENT (assignment_id, lesson_id, title, instructions, due_date, max_score) VALUES
(2, 3, 'Assignment 2: Write Complex SQL Analytical Queries', 'Write SQL queries using GROUP BY, HAVING, and INNER/LEFT JOINs on the dataset provided.', SYSDATE + 14, 100);

-- ---------------------------------------------------------
-- Quizzes, Questions, & Answer Options
-- ---------------------------------------------------------
INSERT INTO QUIZ (quiz_id, lesson_id, title, time_limit_minutes, passing_score) VALUES
(1, 1, 'Quiz 1: Database Basics & Terminology', 15, 70);

INSERT INTO QUESTION (question_id, quiz_id, question_text, points) VALUES
(1, 1, 'Which SQL constraint guarantees uniqueness across rows in a column?', 10);

INSERT INTO ANSWER_OPTION (option_id, question_id, option_text, is_correct) VALUES
(1, 1, 'FOREIGN KEY', 0);
INSERT INTO ANSWER_OPTION (option_id, question_id, option_text, is_correct) VALUES
(2, 1, 'UNIQUE', 1);
INSERT INTO ANSWER_OPTION (option_id, question_id, option_text, is_correct) VALUES
(3, 1, 'CHECK', 0);

INSERT INTO QUESTION (question_id, quiz_id, question_text, points) VALUES
(2, 1, 'What is the primary function of a FOREIGN KEY constraint?', 10);

INSERT INTO ANSWER_OPTION (option_id, question_id, option_text, is_correct) VALUES
(4, 2, 'Enforce referential integrity between tables', 1);
INSERT INTO ANSWER_OPTION (option_id, question_id, option_text, is_correct) VALUES
(5, 2, 'Speed up string comparison', 0);

-- ---------------------------------------------------------
-- Enrollments
-- ---------------------------------------------------------
INSERT INTO ENROLLMENT (enrollment_id, user_id, course_id, enrolled_at, status, progress_percent) VALUES
(1, 4, 1, CURRENT_TIMESTAMP - 10, 'active', 0.00);

INSERT INTO ENROLLMENT (enrollment_id, user_id, course_id, enrolled_at, status, progress_percent) VALUES
(2, 5, 1, CURRENT_TIMESTAMP - 5, 'active', 0.00);

INSERT INTO ENROLLMENT (enrollment_id, user_id, course_id, enrolled_at, status, progress_percent) VALUES
(3, 5, 2, CURRENT_TIMESTAMP - 3, 'active', 0.00);

-- ---------------------------------------------------------
-- Payments
-- ---------------------------------------------------------
INSERT INTO PAYMENT (payment_id, user_id, course_id, amount, status, paid_at) VALUES
(1, 4, 1, 49.99, 'completed', CURRENT_TIMESTAMP - 10);

INSERT INTO PAYMENT (payment_id, user_id, course_id, amount, status, paid_at) VALUES
(2, 5, 1, 49.99, 'completed', CURRENT_TIMESTAMP - 5);

INSERT INTO PAYMENT (payment_id, user_id, course_id, amount, status, paid_at) VALUES
(3, 5, 2, 79.99, 'completed', CURRENT_TIMESTAMP - 3);

-- ---------------------------------------------------------
-- Submissions & Quiz Attempts (Triggers will auto-update progress)
-- ---------------------------------------------------------
INSERT INTO SUBMISSION (submission_id, user_id, assignment_id, file_url, score, feedback) VALUES
(1, 4, 1, '/submissions/david_m_assignment1.sql', 95, 'Great normalization design with proper foreign keys!');

INSERT INTO QUIZ_ATTEMPT (attempt_id, user_id, quiz_id, score) VALUES
(1, 4, 1, 90);

-- ---------------------------------------------------------
-- Reviews
-- ---------------------------------------------------------
INSERT INTO REVIEW (review_id, user_id, course_id, rating, comment_text) VALUES
(1, 4, 1, 5, 'Excellent course! The section on indexing and PL/SQL triggers was super clear.');

COMMIT;
