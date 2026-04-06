from __future__ import annotations

import os
import smtplib
from datetime import datetime
from email.message import EmailMessage

from app.core.config import settings



class EmailService:
    def __init__(self) -> None:
        self.smtp_host = settings.smtp_host
        self.smtp_port = settings.smtp_port
        self.smtp_user = settings.smtp_user
        self.smtp_password = settings.smtp_password
        self.from_name = settings.from_name

    def send_verification_code(
        self,
        email: str,
        code: str,
        expires_at: datetime,
    ) -> None:
        if not self.smtp_host or not self.smtp_user or not self.smtp_password:
            raise RuntimeError(
                "SMTP configuration is missing. Fill in backend/.env or backend/email_env/.env."
            )

        expires_label = expires_at.astimezone().strftime("%Y-%m-%d %H:%M:%S")

        message = EmailMessage()
        message["Subject"] = "[Ttareungyi Neo] Email verification"
        message["From"] = f"{self.from_name} <{self.smtp_user}>"
        message["To"] = email
        message.set_content(
            f"Verification code: {code}\nExpires at: {expires_label}\nThis code is valid for 5 minutes."
        )

        html = f"""
        <html>
          <body style="margin:0;padding:0;background:#f3f7fd;font-family:Arial,sans-serif;color:#10233f;">
            <div style="max-width:600px;margin:32px auto;padding:32px;background:#ffffff;border-radius:28px;box-shadow:0 18px 50px rgba(17,35,63,0.08);">
              <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:24px;">
                <div>
                  <div style="font-size:14px;color:#118847;font-weight:700;letter-spacing:0.08em;">EMAIL VERIFICATION</div>
                  <div style="font-size:32px;font-weight:800;margin-top:8px;">Verify your email</div>
                </div>
                <div style="background:#eaf8ef;color:#118847;padding:10px 16px;border-radius:999px;font-weight:700;">5 min</div>
              </div>
              <div style="padding:28px;background:linear-gradient(135deg,#0f8a47,#31c86b);border-radius:24px;color:#ffffff;text-align:center;">
                <div style="font-size:14px;opacity:0.9;">Enter this code in the app</div>
                <div style="font-size:48px;font-weight:800;letter-spacing:0.4em;margin:18px 0 10px 0;">{code}</div>
                <div style="font-size:14px;opacity:0.92;">Expires at: {expires_label}</div>
              </div>
            </div>
          </body>
        </html>
        """
        message.add_alternative(html, subtype="html")

        with smtplib.SMTP(self.smtp_host, self.smtp_port) as server:
            server.starttls()
            server.login(self.smtp_user, self.smtp_password)
            server.send_message(message)
