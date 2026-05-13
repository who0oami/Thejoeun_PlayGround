import smtplib
from typing import Any

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel

import config
from db import connect, hash_password, verify_password
from email_auth import generate_code_record, pop_code, require_code_or_422, send_verification_email

router = APIRouter()


class SendCodeRequest(BaseModel):
    email: str


class VerifySignupRequest(BaseModel):
    adminname: str
    email: str
    password: str
    code: str


class LoginRequest(BaseModel):
    id: str
    password: str


def _fetch_admin(cursor, admin_id: str) -> dict[str, Any] | None:
    identifier = admin_id.strip()

    if identifier.isdigit():
        cursor.execute(
            "SELECT adminid, adminname, adminemail, adminpassword FROM admin WHERE adminid = %s",
            (int(identifier),),
        )
        row = cursor.fetchone()
        if row:
            return row

    cursor.execute(
        "SELECT adminid, adminname, adminemail, adminpassword FROM admin WHERE adminemail = %s",
        (identifier.lower(),),
    )
    row = cursor.fetchone()
    if row:
        return row

    cursor.execute(
        "SELECT adminid, adminname, adminemail, adminpassword FROM admin WHERE adminname = %s",
        (identifier,),
    )
    return cursor.fetchone()


def _get_admin_by_email(cursor, email: str):
    cursor.execute(
        "SELECT adminid, adminname, adminemail, adminpassword FROM admin WHERE adminemail = %s",
        (email,),
    )
    return cursor.fetchone()


def _smtp_ready() -> bool:
    required_keys = ("SMTP_HOST", "SMTP_USER", "SMTP_PASSWORD", "SMTP_FROM")
    return all(str(getattr(config, key, "")).strip() for key in required_keys)


@router.post("/send-code")
def send_code(data: SendCodeRequest):
    email = data.email.strip().lower()
    if not _smtp_ready():
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="SMTP settings are not configured.",
        )

    record = generate_code_record(email)
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
        "expires_at": record["expires_at"].isoformat(),
    }


@router.post("/verify")
def verify_and_signup(data: VerifySignupRequest):
    email = data.email.strip().lower()
    adminname = data.adminname.strip()

    if not adminname:
      raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Admin name is required.",
        )

    require_code_or_422(email, data.code)

    conn = connect()
    try:
        with conn.cursor() as cursor:
            existing = _get_admin_by_email(cursor, email)
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Email already exists.",
                )

            cursor.execute(
                """
                INSERT INTO admin (adminname, adminemail, adminpassword)
                VALUES (%s, %s, %s)
                """,
                (
                    adminname,
                    email,
                    hash_password(data.password),
                ),
            )
            conn.commit()

        pop_code(email)
        return {"message": "Signup successful."}
    finally:
        conn.close()


@router.post("/login")
def login(data: LoginRequest):
    conn = connect()
    try:
        with conn.cursor() as cursor:
            admin = _fetch_admin(cursor, data.id)

        if not admin or not verify_password(data.password, admin["adminpassword"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid admin credentials.",
            )

        return {
            "message": "Admin login successful.",
            "data": {
                "adminid": admin["adminid"],
                "adminname": admin["adminname"],
                "adminemail": admin["adminemail"],
            },
        }
    finally:
        conn.close()
