import smtplib

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel

import config
from db import connect, hash_password, normalize_gender, verify_password
from email_auth import generate_code_record, pop_code, require_code_or_422, send_verification_email

router = APIRouter()


class UserSendCodeRequest(BaseModel):
    email: str


class UserSignupRequest(BaseModel):
    email: str
    password: str
    age: int | None = None
    gender: str | None = None
    code: str


class UserLoginRequest(BaseModel):
    email: str
    password: str


def _get_user(cursor, email: str):
    cursor.execute(
        "SELECT userid, useremail, userpassword, userage, usersex FROM `user` WHERE useremail = %s",
        (email,),
    )
    return cursor.fetchone()


def _smtp_ready() -> bool:
    required_keys = ("SMTP_HOST", "SMTP_USER", "SMTP_PASSWORD", "SMTP_FROM")
    return all(str(getattr(config, key, "")).strip() for key in required_keys)


@router.post("/send-code")
def send_code(data: UserSendCodeRequest):
    email = data.email.strip().lower()
    if not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email is required.",
        )

    conn = connect()
    try:
        with conn.cursor() as cursor:
            existing = _get_user(cursor, email)
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Email already exists.",
                )
    finally:
        conn.close()

    record = generate_code_record(email)
    if not _smtp_ready():
        return {
            "message": "Verification code generated for testing.",
            "data": {
                "expiresAt": record["expires_at"].isoformat(),
                "code": record["code"],
            },
        }

    try:
        send_verification_email(email, record["code"])
    except smtplib.SMTPAuthenticationError:
        pop_code(email)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="SMTP authentication failed. Check your email address and app password.",
        )
    except Exception:
        pop_code(email)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Failed to send verification email.",
        )

    return {
        "message": "Verification code sent.",
        "data": {
            "expiresAt": record["expires_at"].isoformat(),
        },
    }


@router.post("/signup")
def signup(data: UserSignupRequest):
    email = data.email.strip().lower()
    if not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email is required.",
        )
    if not data.password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password is required.",
        )

    require_code_or_422(email, data.code)

    conn = connect()
    try:
        with conn.cursor() as cursor:
            existing = _get_user(cursor, email)
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Email already exists.",
                )

            cursor.execute(
                """
                INSERT INTO `user` (useremail, userpassword, userage, usersex)
                VALUES (%s, %s, %s, %s)
                """,
                (
                    email,
                    hash_password(data.password),
                    data.age,
                    normalize_gender(data.gender),
                ),
            )
            conn.commit()

        pop_code(email)
        return {"message": "Signup successful."}
    finally:
        conn.close()


@router.post("/login")
def login(data: UserLoginRequest):
    email = data.email.strip().lower()
    password = data.password.strip()

    conn = connect()
    try:
        with conn.cursor() as cursor:
            user = _get_user(cursor, email)

        if not user:
            print(f"[user/login] email not found: {email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User email not found.",
            )

        if not verify_password(password, user["userpassword"]):
            print(
                "[user/login] password mismatch:",
                {
                    "email": email,
                    "stored_length": len(str(user["userpassword"]).strip()),
                    "input_length": len(password),
                },
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
            )

        return {
            "message": "Login successful.",
            "data": {
                "userid": user["userid"],
                "useremail": user["useremail"],
                "userage": user["userage"],
                "usersex": user["usersex"],
            },
        }
    finally:
        conn.close()
