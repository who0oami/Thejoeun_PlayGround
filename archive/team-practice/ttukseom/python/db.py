import hashlib

import config
import pymysql


def connect():
    return pymysql.connect(
        host=config.hostip,
        user=config.hostuser,
        password=config.hostpassword,
        database=config.hostdatabase,
        charset="utf8",
        cursorclass=pymysql.cursors.DictCursor,
    )


def hash_password(password: str) -> str:
    return hashlib.sha1(password.strip().encode("utf-8")).hexdigest()


def verify_password(password: str, stored_password: str) -> bool:
    password = password.strip()
    stored_password = str(stored_password).strip()
    return hash_password(password) == stored_password or password == stored_password


def normalize_gender(value):
    if value is None:
        return None

    gender = str(value).strip().lower()
    if gender in {"male", "m", "man", "1", "남"}:
        return 1
    if gender in {"female", "f", "woman", "2", "여"}:
        return 2
    return None
