-- ============================================================
-- E-Learning Platform Master Execution Script
-- File: run_all.sql
-- Description: Runs schema creation, PL/SQL logic, seed data, 
--              and demo queries sequentially.
-- ============================================================

SET ECHO ON;
SET FEEDBACK ON;
SET SERVEROUTPUT ON;

PROMPT =========================================================
PROMPT Executing 01_schema.sql (Table DDL & Constraints)...
PROMPT =========================================================
@01_schema.sql

PROMPT =========================================================
PROMPT Executing 02_procedures_triggers.sql (PL/SQL Logic)...
PROMPT =========================================================
@02_procedures_triggers.sql

PROMPT =========================================================
PROMPT Executing 03_seed_data.sql (Sample Seed Data)...
PROMPT =========================================================
@03_seed_data.sql

PROMPT =========================================================
PROMPT Executing 04_queries_demo.sql (Dashboard Queries & Tests)...
PROMPT =========================================================
@04_queries_demo.sql

PROMPT =========================================================
PROMPT Master Execution Complete! All tables, procedures, triggers,
PROMPT and seed data loaded successfully.
PROMPT =========================================================
