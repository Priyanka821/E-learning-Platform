import os

BASE_DIR = os.path.abspath(os.path.dirname(__file__))

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'elearning-secret-key-2026-prod-dev')
    DB_PATH = os.path.join(BASE_DIR, 'database', 'elearning.db')
    SCHEMA_PATH = os.path.join(BASE_DIR, 'database', 'schema.sql')
    SEED_PATH = os.path.join(BASE_DIR, 'database', 'seed_data.sql')
    UPLOAD_FOLDER = os.path.join(BASE_DIR, 'static', 'uploads')
