from __future__ import annotations

from pydantic import BaseModel, EmailStr


class SendCodeRequest(BaseModel):
    email: EmailStr


class VerifyCodeRequest(BaseModel):
    name: str
    gender: str
    email: EmailStr
    password: str
    role: str
    code: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    role: str
