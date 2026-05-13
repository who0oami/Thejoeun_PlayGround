from __future__ import annotations

import os
from pathlib import Path


def _load_env_file(path: Path) -> None:
    if not path.exists():
        return

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue

        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


_CURRENT_DIR = Path(__file__).resolve().parent
_load_env_file(_CURRENT_DIR / ".env")
_load_env_file(_CURRENT_DIR.parent / ".env")

hostip = os.getenv("DB_HOST", "127.0.0.1")
hostuser = os.getenv("DB_USER", "root")
hostpassword = os.getenv("DB_PASSWORD", "")
hostdatabase = os.getenv("DB_NAME", "hanriver")

# Local development address. Use 0.0.0.0 again when teammates need LAN access.
userAddress = os.getenv("APP_HOST", "127.0.0.1")

# SMTP settings for verification mail.
SMTP_HOST = os.getenv("SMTP_HOST", "")
SMTP_PORT = int(os.getenv("SMTP_PORT", "587"))
SMTP_USE_TLS = os.getenv("SMTP_USE_TLS", "true").lower() != "false"
SMTP_USER = os.getenv("SMTP_USER", "")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "")
SMTP_FROM = os.getenv("SMTP_FROM", SMTP_USER)
SMTP_FROM_NAME = os.getenv("SMTP_FROM_NAME", "Hanriver")

# Public parking lot source page used by the live crawler.
PARKINGLOT_SOURCE_URL = os.getenv(
    "PARKINGLOT_SOURCE_URL",
    "https://www.ihangangpark.kr/parking/region/region3",
)
PARKINGLOT_DIV_CD = os.getenv("PARKINGLOT_DIV_CD", "PLT-005")
