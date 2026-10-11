# LearnPulse — E-Learning Database Management System

A full-stack database-driven E-Learning web application featuring:
- **15-Table Relational Database Schema** (MySQL / SQLite / Oracle)
- **PL/SQL Stored Procedures, Triggers & Automated Calculations** (located in `/elearning_db`)
- **Python Flask Backend** with Parameterized SQL Queries
- **Modern Responsive Frontend** (HTML5, Tailwind CSS, Vanilla JS, Jinja2)

---

## 📁 Repository Structure

```
elearning-platform/
├── app.py                      # Flask Application entry point
├── config.py                   # Configuration settings
├── requirements.txt            # Python dependencies
├── database/                   # Schema DDL and Seed SQL files
│   ├── schema.sql
│   └── seed_data.sql
├── db/                         # Database connection & progress logic
│   └── connection.py
├── routes/                     # Application Blueprints
│   ├── auth.py
│   ├── student.py
│   ├── instructor.py
│   └── admin.py
├── templates/                  # Jinja2 HTML Templates
├── utils/                      # Security & password helpers
└── elearning_db/               # Pure Oracle SQL & PL/SQL Database Scripts
    ├── 01_schema.sql
    ├── 02_procedures_triggers.sql
    ├── 03_seed_data.sql
    ├── 04_queries_demo.sql
    └── run_all.sql
```

---

## 🚀 Running the Web Application Locally

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. Start the Flask application:
   ```bash
   python app.py
   ```
3. Open your browser and navigate to:
   ```
   http://127.0.0.1:5000
   ```

---

## 🔑 Demo Accounts (Password: `password123`)

- **Student:** `david.m@gmail.com`
- **Instructor:** `vance@university.edu`
- **Admin:** `admin@elearning.org`
