from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parents[2]
ENV_PATH = BASE_DIR / ".env"

load_dotenv(ENV_PATH)


class Settings:
    db_host = os.getenv("DB_HOST", "127.0.0.1")
    db_port = int(os.getenv("DB_PORT", "3306"))
    db_user = os.getenv("DB_USER", "root")
    db_password = os.getenv("DB_PASSWORD", "")
    db_name = os.getenv("DB_NAME", "bike_predict_db")
    db_charset = os.getenv("DB_CHARSET", "utf8mb4")
    db_connection_timeout = int(os.getenv("DB_CONNECTION_TIMEOUT", "5"))
    db_read_timeout = int(os.getenv("DB_READ_TIMEOUT", "5"))
    prediction_backend = os.getenv("PREDICTION_BACKEND", "auto")

    app_title = os.getenv("APP_TITLE", "Ttareungyi Neo Auth API")

    smtp_host = os.getenv("SMTP_HOST", "")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USER", "")
    smtp_password = os.getenv("SMTP_PASSWORD", "")
    from_name = os.getenv("FROM_NAME", "Ttareungyi Neo")


settings = Settings()
