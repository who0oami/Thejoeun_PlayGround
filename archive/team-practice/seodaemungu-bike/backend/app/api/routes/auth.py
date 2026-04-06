from __future__ import annotations

from fastapi import APIRouter, Header

from app.schemas.auth import LoginRequest, SendCodeRequest, VerifyCodeRequest
from app.services.auth_service import AuthService

router = APIRouter()
auth_service = AuthService()


@router.post("/send-code")
def send_code(payload: SendCodeRequest) -> dict:
    return auth_service.send_code(payload)


@router.post("/verify")
def verify_email(payload: VerifyCodeRequest) -> dict:
    return auth_service.verify_email(payload)


@router.post("/login")
def login(payload: LoginRequest) -> dict:
    return auth_service.login(payload)


@router.get("/me")
def me(x_session_token: str = Header(...)) -> dict:
    user = auth_service.get_current_user(x_session_token)
    return {
        "user": {
            "id": user["id"],
            "name": user["name"],
            "email": user["email"],
            "role": user["role"],
        }
    }


@router.post("/logout")
def logout(x_session_token: str = Header(...)) -> dict:
    return auth_service.logout(x_session_token)
