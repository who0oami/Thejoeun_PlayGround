import os
from typing import Any

from fastapi import APIRouter, BackgroundTasks, HTTPException, status
from pydantic import BaseModel

import config
from db import connect, hash_password, verify_password
from email_auth import generate_code_record, pop_code, require_code_or_422, send_verification_email

router = APIRouter()


class AdminLoginRequest(BaseModel):
    id: str
    password: str


class AdminSendCodeRequest(BaseModel):
    email: str


class AdminSignupRequest(BaseModel):
    email: str
    password: str
    code: str


def _fetch_admin(cursor, admin_id: str) -> dict[str, Any] | None:
    if admin_id.isdigit():
        cursor.execute(
            "SELECT adminid, adminemail, adminpassword FROM admin WHERE adminid = %s",
            (int(admin_id),),
        )
        row = cursor.fetchone()
        if row:
            return row

    cursor.execute(
        "SELECT adminid, adminemail, adminpassword FROM admin WHERE adminemail = %s",
        (admin_id,),
    )
    return cursor.fetchone()


def _get_admin_by_email(cursor, email: str):
    cursor.execute(
        "SELECT adminid, adminemail, adminpassword FROM admin WHERE adminemail = %s",
        (email,),
    )
    return cursor.fetchone()


@router.post("/signup/send-code")
def admin_send_code(data: AdminSendCodeRequest, background_tasks: BackgroundTasks):
    email = data.email.strip().lower()
    record = generate_code_record(email)
    background_tasks.add_task(send_verification_email, email, record["code"])

    smtp_ready = all(
        str(getattr(config, key, "")).strip()
        for key in ("SMTP_HOST", "SMTP_USER", "SMTP_PASSWORD")
    )

    return {
        "message": "Verification code sent." if smtp_ready else "Verification code generated for testing.",
        "data": {
            "expiresAt": record["expires_at"].isoformat(),
            "code": record["code"],
        },
    }


@router.post("/signup/verify-and-signup")
def admin_verify_and_signup(data: AdminSignupRequest):
    email = data.email.strip().lower()
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
                INSERT INTO admin (adminemail, adminpassword)
                VALUES (%s, %s)
                """,
                (
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
def admin_login(data: AdminLoginRequest):
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
                "adminemail": admin["adminemail"],
            },
        }
    finally:
        conn.close()
