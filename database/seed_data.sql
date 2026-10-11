-- Seed Data for E-Learning Platform

-- Password for all seed users is: password123
INSERT INTO ADMIN (admin_id, name, email, password_hash, access_level) VALUES
(1, 'System Super Admin', 'admin@elearning.org', 'scrypt:32768:8:1$nMyBvi4ejCqjYt2k$6b49190ad67f3de7306de20020c92d9739d522795245d5673aa2bef02f66fcd1835bac76406eaa55220b9ffc562a675dcff6961627e1ccdf02402aad3fd027fe', 'superadmin');

INSERT INTO USER (user_id, name, email, password_hash, role) VALUES
(1, 'Dr. Aris Vance', 'vance@university.edu', 'scrypt:32768:8:1$nMyBvi4ejCqjYt2k$6b49190ad67f3de7306de20020c92d9739d522795245d5673aa2bef02f66fcd1835bac76406eaa55220b9ffc562a675dcff6961627e1ccdf02402aad3fd027fe', 'instructor'),
(2, 'Elena Rostova', 'elena@techacademy.io', 'scrypt:32768:8:1$nMyBvi4ejCqjYt2k$6b49190ad67f3de7306de20020c92d9739d522795245d5673aa2bef02f66fcd1835bac76406eaa55220b9ffc562a675dcff6961627e1ccdf02402aad3fd027fe', 'instructor'),
(3, 'Marcus Chen', 'marcus@codecampus.org', 'scrypt:32768:8:1$nMyBvi4ejCqjYt2k$6b49190ad67f3de7306de20020c92d9739d522795245d5673aa2bef02f66fcd1835bac76406eaa55220b9ffc562a675dcff6961627e1ccdf02402aad3fd027fe', 'instructor'),
(4, 'David Miller', 'david.m@gmail.com', 'scrypt:32768:8:1$nMyBvi4ejCqjYt2k$6b49190ad67f3de7306de20020c92d9739d522795245d5673aa2bef02f66fcd1835bac76406eaa55220b9ffc562a675dcff6961627e1ccdf02402aad3fd027fe', 'student'),
(5, 'Sophia Patel', 'sophia.p@outlook.com', 'scrypt:32768:8:1$nMyBvi4ejCqjYt2k$6b49190ad67f3de7306de20020c92d9739d522795245d5673aa2bef02f66fcd1835bac76406eaa55220b9ffc562a675dcff6961627e1ccdf02402aad3fd027fe', 'student'),
(6, 'James Wilson', 'jwilson@yahoo.com', 'scrypt:32768:8:1$nMyBvi4ejCqjYt2k$6b49190ad67f3de7306de20020c92d9739d522795245d5673aa2bef02f66fcd1835bac76406eaa55220b9ffc562a675dcff6961627e1ccdf02402aad3fd027fe', 'student');

INSERT INTO COURSE (course_id, instructor_id, approved_by_admin_id, title, description, price, level, approval_status, approved_at) VALUES
(1, 1, 1, 'Database Systems & SQL Fundamentals', 'Master relational database modeling, normalization, SQL queries, indexing, and stored procedure execution.', 49.99, 'Beginner', 'approved', CURRENT_TIMESTAMP),
(2, 2, 1, 'Full-Stack Web Development with Flask & JS', 'Build scalable web applications with Flask, PyMySQL REST APIs, vanilla JS, and modern UI components.', 79.99, 'Intermediate', 'approved', CURRENT_TIMESTAMP),
(3, 3, 1, 'Data Structures & Algorithms Essentials', 'Master Big-O notation, linked lists, binary trees, graphs, sorting algorithms, and dynamic programming.', 29.99, 'Intermediate', 'approved', CURRENT_TIMESTAMP),
(4, 1, NULL, 'Advanced Oracle PL/SQL & Performance Tuning', 'In-depth guide to package optimization, bulk collection, ref cursors, and query execution plans.', 89.99, 'Advanced', 'pending', NULL);

INSERT INTO MODULE (module_id, course_id, title, order_index) VALUES
(1, 1, 'Module 1: Relational Modeling & ERD', 1),
(2, 1, 'Module 2: Advanced SQL & Joins', 2),
(3, 2, 'Module 1: Flask Routing & Architecture', 1);

INSERT INTO LESSON (lesson_id, module_id, title, content_type, video_url, duration_minutes, order_index) VALUES
(1, 1, 'Introduction to Relational Databases', 'video', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 1),
(2, 1, 'Designing ER Diagrams & Normalization', 'video', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 40, 2),
(3, 2, 'Complex SQL Joins and Aggregates', 'video', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 35, 1);

INSERT INTO ASSIGNMENT (assignment_id, lesson_id, title, instructions, due_date, max_score) VALUES
(1, 2, 'Assignment 1: ERD Normalization Exercise', 'Design a 3NF relational schema for a library management database. Submit your SQL script.', '2026-10-25 23:59:59', 100),
(2, 3, 'Assignment 2: Write Complex Analytical SQL Queries', 'Write SQL queries using GROUP BY, HAVING, and INNER/LEFT JOINs on the dataset provided.', '2026-11-05 23:59:59', 100);

INSERT INTO QUIZ (quiz_id, lesson_id, title, time_limit_minutes, passing_score) VALUES
(1, 1, 'Quiz 1: Database Basics & Terminology', 15, 70);

INSERT INTO QUESTION (question_id, quiz_id, question_text, points) VALUES
(1, 1, 'Which SQL constraint guarantees uniqueness across rows in a column?', 10),
(2, 1, 'What is the primary function of a FOREIGN KEY constraint?', 10);

INSERT INTO ANSWER_OPTION (option_id, question_id, option_text, is_correct) VALUES
(1, 1, 'FOREIGN KEY', 0),
(2, 1, 'UNIQUE', 1),
(3, 1, 'CHECK', 0),
(4, 2, 'Enforce referential integrity between tables', 1),
(5, 2, 'Speed up string comparison', 0);

INSERT INTO ENROLLMENT (enrollment_id, user_id, course_id, status, progress_percent) VALUES
(1, 4, 1, 'active', 50.00),
(2, 5, 1, 'active', 0.00),
(3, 5, 2, 'active', 0.00);

INSERT INTO SUBMISSION (submission_id, user_id, assignment_id, file_url, score, feedback) VALUES
(1, 4, 1, '/uploads/david_assignment1.sql', 95, 'Great normalization design with proper foreign keys!');

INSERT INTO PAYMENT (payment_id, user_id, course_id, amount, status, paid_at) VALUES
(1, 4, 1, 49.99, 'completed', CURRENT_TIMESTAMP),
(2, 5, 1, 49.99, 'completed', CURRENT_TIMESTAMP),
(3, 5, 2, 79.99, 'completed', CURRENT_TIMESTAMP);

INSERT INTO REVIEW (review_id, user_id, course_id, rating, comment) VALUES
(1, 4, 1, 5, 'Excellent course! The section on indexing and SQL normalization was super clear.');
