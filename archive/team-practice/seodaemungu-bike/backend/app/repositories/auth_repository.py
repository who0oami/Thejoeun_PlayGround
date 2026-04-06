from __future__ import annotations

from app.database.connection import connect_db


class AuthRepository:
    def get_latest_email_code(self, email: str):
        with connect_db() as connection:
            return connection.execute(
                """
                SELECT id, email, code, expires_at, verified, created_at
                FROM email_codes
                WHERE email = %s
                ORDER BY id DESC
                LIMIT 1
                """,
                (email,),
            ).fetchone()

    def replace_email_code(
        self,
        email: str,
        code: str,
        expires_at,
        created_at,
    ) -> None:
        with connect_db() as connection:
            connection.execute("DELETE FROM email_codes WHERE email = %s", (email,))
            connection.execute(
                """
                INSERT INTO email_codes (email, code, expires_at, verified, created_at)
                VALUES (%s, %s, %s, 0, %s)
                """,
                (email, code, expires_at, created_at),
            )
            connection.commit()

    def get_user_by_email(self, email: str):
        with connect_db() as connection:
            return connection.execute(
                """
                SELECT id, name, email, password, role, age, gender, email_verified
                FROM users
                WHERE email = %s
                LIMIT 1
                """,
                (email,),
            ).fetchone()

    def get_user_by_email_and_role(self, email: str, role: str):
        with connect_db() as connection:
            return connection.execute(
                """
                SELECT id, name, email, password, role, age, gender, email_verified
                FROM users
                WHERE email = %s AND role = %s
                LIMIT 1
                """,
                (email, role),
            ).fetchone()

    def create_user(
        self,
        name: str,
        gender: str,
        email: str,
        password_hash: str,
        role: str,
    ) -> None:
        with connect_db() as connection:
            connection.execute(
                """
                INSERT INTO users (name, age, gender, email, password, role, email_verified)
                VALUES (%s, %s, %s, %s, %s, %s, 1)
                """,
                (name, None, gender, email, password_hash, role),
            )
            connection.execute(
                "UPDATE email_codes SET verified = 1 WHERE email = %s",
                (email,),
            )
            connection.commit()

    def create_session(self, user_id: int, session_token: str, expires_at) -> None:
        with connect_db() as connection:
            connection.execute(
                """
                INSERT INTO sessions (user_id, session_token, expires_at, revoked)
                VALUES (%s, %s, %s, 0)
                """,
                (user_id, session_token, expires_at),
            )
            connection.commit()

    def get_session_user(self, session_token: str):
        with connect_db() as connection:
            return connection.execute(
                """
                SELECT
                    users.id,
                    users.name,
                    users.email,
                    users.role,
                    sessions.session_token,
                    sessions.expires_at,
                    sessions.revoked
                FROM sessions
                JOIN users ON users.id = sessions.user_id
                WHERE sessions.session_token = %s
                LIMIT 1
                """,
                (session_token,),
            ).fetchone()

    def revoke_session(self, session_token: str) -> None:
        with connect_db() as connection:
            connection.execute(
                "UPDATE sessions SET revoked = 1 WHERE session_token = %s",
                (session_token,),
            )
            connection.commit()
