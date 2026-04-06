from __future__ import annotations

import random
import secrets
from datetime import datetime, timedelta, timezone

from fastapi import HTTPException

from app.repositories.auth_repository import AuthRepository
from app.schemas.auth import LoginRequest, SendCodeRequest, VerifyCodeRequest
from app.utils.email_service import EmailService
from app.utils.security import hash_password, verify_password


def parse_dt(value: datetime | str) -> datetime:
    if isinstance(value, datetime):
        dt = value
    else:
        dt = datetime.fromisoformat(value)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt


def utc_now() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


def to_isoformat(value: datetime | str) -> str:
    return parse_dt(value).isoformat()


class AuthService:
    def __init__(self, repository: AuthRepository | None = None) -> None:
        self.repository = repository or AuthRepository()
        self.email_service = EmailService()

    def send_code(self, payload: SendCodeRequest) -> dict:
        now = utc_now()
        code = f"{random.randint(0, 999999):06d}"
        expires_at = now + timedelta(minutes=5)

        latest = self.repository.get_latest_email_code(payload.email)
        if latest is not None:
            latest_created = parse_dt(latest["created_at"])
            if (datetime.now(timezone.utc) - latest_created).total_seconds() < 60:
                raise HTTPException(
                    status_code=429,
                    detail="Please wait at least 60 seconds before requesting another code.",
                )

        self.repository.replace_email_code(payload.email, code, expires_at, now)
        self.email_service.send_verification_code(
            payload.email,
            code,
            expires_at.replace(tzinfo=timezone.utc),
        )
        return {
            "message": "Verification code sent successfully.",
            "expires_at": to_isoformat(expires_at),
        }

    def verify_email(self, payload: VerifyCodeRequest) -> dict:
        if payload.role not in {"user", "admin"}:
            raise HTTPException(status_code=400, detail="role must be either user or admin.")
        if payload.gender not in {"male", "female"}:
            raise HTTPException(status_code=400, detail="gender must be either male or female.")

        row = self.repository.get_latest_email_code(payload.email)
        if row is None:
            raise HTTPException(status_code=404, detail="No verification code found for this email.")

        expires_at = parse_dt(row["expires_at"])
        now = datetime.now(timezone.utc)

        if expires_at < now:
            raise HTTPException(status_code=400, detail="Verification code has expired.")

        if row["code"] != payload.code:
            raise HTTPException(status_code=400, detail="Verification code does not match.")

        existing = self.repository.get_user_by_email(payload.email)
        if existing is not None:
            raise HTTPException(status_code=409, detail="This email is already registered.")

        self.repository.create_user(
            payload.name,
            payload.gender,
            payload.email,
            hash_password(payload.password),
            payload.role,
        )
        return {"message": "Email verification and signup completed successfully."}

    def login(self, payload: LoginRequest) -> dict:
        if payload.role not in {"user", "admin"}:
            raise HTTPException(status_code=400, detail="role must be either user or admin.")

        user = self.repository.get_user_by_email_and_role(payload.email, payload.role)
        if user is None:
            raise HTTPException(status_code=404, detail="No matching account was found.")

        if int(user["email_verified"]) != 1:
            raise HTTPException(status_code=403, detail="Email verification is required before login.")

        if not verify_password(payload.password, user["password"]):
            raise HTTPException(status_code=401, detail="Incorrect password.")

        session_token = secrets.token_urlsafe(32)
        expires_at = utc_now() + timedelta(days=7)
        self.repository.create_session(user["id"], session_token, expires_at)

        return {
            "message": "Login successful.",
            "session_token": session_token,
            "expires_at": to_isoformat(expires_at),
            "user": {
                "id": user["id"],
                "name": user["name"],
                "email": user["email"],
                "role": user["role"],
            },
        }

    def get_current_user(self, session_token: str):
        row = self.repository.get_session_user(session_token)
        if row is None:
            raise HTTPException(status_code=401, detail="Invalid session token.")

        if int(row["revoked"]) == 1:
            raise HTTPException(status_code=401, detail="Session has already been revoked.")

        if parse_dt(row["expires_at"]) < datetime.now(timezone.utc):
            raise HTTPException(status_code=401, detail="Session has expired.")

        return row

    def logout(self, session_token: str) -> dict:
        self.get_current_user(session_token)
        self.repository.revoke_session(session_token)
        return {"message": "Logout successful."}
