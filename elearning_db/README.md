# E-Learning Platform Database System (SQL & PL/SQL)

A complete database solution for an E-Learning platform implemented purely in **SQL** and **PL/SQL**.

---

## 📁 Directory & File Paths

All files are created in the following directory:
`C:\Users\Priyanka\.gemini\antigravity\scratch\elearning_db`

### Files Breakdown:
1. `01_schema.sql` — Full DDL defining 15 tables, PKs, FKs, constraints, and indexes.
2. `02_procedures_triggers.sql` — PL/SQL stored procedures, triggers, helper functions, and automated progress calculation.
3. `03_seed_data.sql` — Realistic demo data (Admins, Instructors, Students, Courses, Modules, Lessons, Assignments, Quizzes, Submissions, Reviews, Payments).
4. `04_queries_demo.sql` — Dashboards for Student, Instructor, & Admin roles, plus stored procedure verification tests.
5. `run_all.sql` — Master script to execute all scripts in sequence.

---

## 🛠️ How to Run

### Option 1: Oracle SQL Developer / Live SQL / DBeaver
1. Open your SQL client connected to your Oracle Database.
2. Open `run_all.sql` or run the scripts in order:
   - Run `01_schema.sql`
   - Run `02_procedures_triggers.sql`
   - Run `03_seed_data.sql`
   - Run `04_queries_demo.sql`

### Option 2: SQL*Plus (Command Line)
```bash
cd C:\Users\Priyanka\.gemini\antigravity\scratch\elearning_db
sqlplus username/password@localhost:1521/XEPDB1 @run_all.sql
```

---

## ⚙️ Key Database Features Implemented

1. **Automated Progress Tracking (PL/SQL Trigger & Procedure)**
   - When a student submits an assignment or completes a quiz attempt, PL/SQL triggers calculate `progress_percent` weighted dynamically.
   - Reaching 100% automatically updates enrollment status to `completed` and generates a certificate.

2. **User Registration & Enrollment (PL/SQL Stored Procedures)**
   - `register_user`: Enforces unique email check and creates new user.
   - `enroll_student`: Enforces course approval check before permitting enrollment.
   - `approve_course`: Admin stored procedure for course management.

3. **15 Core Relational Entities**
   - `ADMIN`, `USERS`, `COURSE`, `MODULE`, `LESSON`, `ASSIGNMENT`, `QUIZ`, `QUESTION`, `ANSWER_OPTION`, `ENROLLMENT`, `REVIEW`, `PAYMENT`, `CERTIFICATE`, `SUBMISSION`, `QUIZ_ATTEMPT`.
