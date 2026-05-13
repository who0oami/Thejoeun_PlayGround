import os
import secrets
import smtplib
from datetime import datetime, timedelta, timezone
from email.message import EmailMessage
from email.utils import formataddr
from typing import Any

from fastapi import HTTPException, status

import config

_verification_codes: dict[str, dict[str, Any]] = {}


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def generate_code_record(email: str) -> dict[str, Any]:
    code = f"{secrets.randbelow(1_000_000):06d}"
    expires_at = now_utc() + timedelta(minutes=5)
    _verification_codes[email.lower()] = {
        "code": code,
        "expires_at": expires_at,
    }
    return {"code": code, "expires_at": expires_at}


def is_code_valid(email: str, code: str | None) -> bool:
    record = _verification_codes.get(email.lower())
    if not record:
        return False

    if record["expires_at"] <= now_utc():
        _verification_codes.pop(email.lower(), None)
        return False

    return code == record["code"]


def pop_code(email: str) -> None:
    _verification_codes.pop(email.lower(), None)


def send_verification_email(email: str, code: str) -> None:
    smtp_host = os.getenv("SMTP_HOST", str(getattr(config, "SMTP_HOST", ""))).strip()
    smtp_user = os.getenv("SMTP_USER", str(getattr(config, "SMTP_USER", ""))).strip()
    smtp_password = os.getenv("SMTP_PASSWORD", str(getattr(config, "SMTP_PASSWORD", ""))).strip()
    smtp_port = int(os.getenv("SMTP_PORT", str(getattr(config, "SMTP_PORT", 587))))
    smtp_from = os.getenv(
        "SMTP_FROM",
        str(getattr(config, "SMTP_FROM", smtp_user or "no-reply@example.com")),
    ).strip()
    smtp_from_name = os.getenv(
        "SMTP_FROM_NAME",
        str(getattr(config, "SMTP_FROM_NAME", "Hanriver")),
    ).strip()
    use_tls = os.getenv(
        "SMTP_USE_TLS",
        "true" if bool(getattr(config, "SMTP_USE_TLS", True)) else "false",
    ).lower() != "false"

    if not smtp_host or not smtp_user or not smtp_password:
        return

    message = EmailMessage()
    message["Subject"] = "[Hanriver] Email verification"
    message["From"] = formataddr((smtp_from_name, smtp_from))
    message["To"] = email
    message.set_content(
        f"Your verification code is {code}.\n\n"
        "This code expires in 5 minutes.\n"
        "If you did not request this email, you can ignore it."
    )
    message.add_alternative(
        f"""\
<!doctype html>
<html>
  <body style="margin:0;background:#f7f8fb;font-family:Arial,Helvetica,sans-serif;">
    <div style="max-width:760px;margin:0 auto;padding:32px 20px;">
      <div style="background:#ffffff;border-radius:24px;box-shadow:0 10px 30px rgba(16,24,40,.08);overflow:hidden;">
        <div style="padding:32px 36px 20px 36px;">
          <div style="color:#1f8a4c;font-size:12px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;">
            Email verification
          </div>
          <div style="font-size:42px;line-height:1.1;font-weight:800;color:#111827;margin-top:12px;">
            Verify your email
          </div>
          <div style="display:inline-block;float:right;margin-top:-54px;background:#e7f8ec;color:#1f8a4c;border-radius:999px;padding:10px 18px;font-weight:700;">
            5 min
          </div>
        </div>
        <div style="padding:0 36px 36px 36px;">
          <div style="background:linear-gradient(135deg,#0f9d58,#34c759);border-radius:28px;padding:36px 28px;text-align:center;">
            <div style="color:rgba(255,255,255,.92);font-size:18px;margin-bottom:18px;">
              Enter this code in the app
            </div>
            <div style="color:#ffffff;font-size:56px;font-weight:800;letter-spacing:0.35em;font-family:'Courier New',monospace;">
              {code}
            </div>
          </div>
          <div style="margin-top:22px;color:#6b7280;font-size:14px;line-height:1.7;">
            This code expires in 5 minutes. If you did not request this email, you can ignore it.
          </div>
        </div>
      </div>
    </div>
  </body>
</html>
""",
        subtype="html",
    )

    with smtplib.SMTP(smtp_host, smtp_port, timeout=10) as server:
        if use_tls:
            server.starttls()
        server.login(smtp_user, smtp_password)
        server.send_message(message)


def require_code_or_422(email: str, code: str | None) -> None:
    if not is_code_valid(email, code):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired verification code.",
        )
