-- E-Learning Platform Schema (15 Tables)

CREATE TABLE IF NOT EXISTS ADMIN (
    admin_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    access_level TEXT DEFAULT 'standard',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS USER (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    managed_by_admin_id INTEGER,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT CHECK(role IN ('student', 'instructor')) NOT NULL DEFAULT 'student',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (managed_by_admin_id) REFERENCES ADMIN(admin_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS COURSE (
    course_id INTEGER PRIMARY KEY AUTOINCREMENT,
    instructor_id INTEGER NOT NULL,
    managed_by_admin_id INTEGER,
    approved_by_admin_id INTEGER,
    title TEXT NOT NULL,
    description TEXT,
    price REAL DEFAULT 0.00,
    level TEXT DEFAULT 'Beginner',
    approval_status TEXT CHECK(approval_status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
    approved_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instructor_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    FOREIGN KEY (managed_by_admin_id) REFERENCES ADMIN(admin_id) ON DELETE SET NULL,
    FOREIGN KEY (approved_by_admin_id) REFERENCES ADMIN(admin_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS MODULE (
    module_id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    order_index INTEGER DEFAULT 0,
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS LESSON (
    lesson_id INTEGER PRIMARY KEY AUTOINCREMENT,
    module_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    content_type TEXT DEFAULT 'video',
    video_url TEXT,
    duration_minutes INTEGER DEFAULT 0,
    order_index INTEGER DEFAULT 0,
    FOREIGN KEY (module_id) REFERENCES MODULE(module_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ASSIGNMENT (
    assignment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    lesson_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    instructions TEXT,
    due_date DATETIME,
    max_score INTEGER DEFAULT 100,
    FOREIGN KEY (lesson_id) REFERENCES LESSON(lesson_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS QUIZ (
    quiz_id INTEGER PRIMARY KEY AUTOINCREMENT,
    lesson_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    time_limit_minutes INTEGER DEFAULT 30,
    passing_score INTEGER DEFAULT 50,
    FOREIGN KEY (lesson_id) REFERENCES LESSON(lesson_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS QUESTION (
    question_id INTEGER PRIMARY KEY AUTOINCREMENT,
    quiz_id INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    question_type TEXT DEFAULT 'mcq',
    points INTEGER DEFAULT 1,
    FOREIGN KEY (quiz_id) REFERENCES QUIZ(quiz_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ANSWER_OPTION (
    option_id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id INTEGER NOT NULL,
    option_text TEXT NOT NULL,
    is_correct INTEGER DEFAULT 0,
    FOREIGN KEY (question_id) REFERENCES QUESTION(question_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ENROLLMENT (
    enrollment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    enrolled_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status TEXT CHECK(status IN ('active', 'completed', 'dropped')) DEFAULT 'active',
    progress_percent REAL DEFAULT 0.00,
    UNIQUE(user_id, course_id),
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS REVIEW (
    review_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    rating INTEGER CHECK(rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, course_id),
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS PAYMENT (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    status TEXT CHECK(status IN ('pending', 'completed', 'refunded')) DEFAULT 'pending',
    paid_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CERTIFICATE (
    certificate_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    issued_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    certificate_url TEXT,
    UNIQUE(user_id, course_id),
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS SUBMISSION (
    submission_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    assignment_id INTEGER NOT NULL,
    file_url TEXT,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    score INTEGER,
    feedback TEXT,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    FOREIGN KEY (assignment_id) REFERENCES ASSIGNMENT(assignment_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS QUIZ_ATTEMPT (
    attempt_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    quiz_id INTEGER NOT NULL,
    score INTEGER,
    attempted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    FOREIGN KEY (quiz_id) REFERENCES QUIZ(quiz_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_course_instructor ON COURSE(instructor_id);
CREATE INDEX IF NOT EXISTS idx_module_course ON MODULE(course_id);
CREATE INDEX IF NOT EXISTS idx_lesson_module ON LESSON(module_id);
CREATE INDEX IF NOT EXISTS idx_enrollment_user ON ENROLLMENT(user_id);
CREATE INDEX IF NOT EXISTS idx_submission_user ON SUBMISSION(user_id);
