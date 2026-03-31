from __future__ import annotations

import hashlib
import hmac
import secrets


def hash_password(password: str) -> str:
    salt = secrets.token_hex(16)
    hashed = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt.encode("utf-8"),
        100_000,
    ).hex()
    return f"{salt}${hashed}"


def verify_password(password: str, stored_hash: str) -> bool:
    try:
        salt, original_hash = stored_hash.split("$", 1)
    except ValueError:
        return False

    hashed = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt.encode("utf-8"),
        100_000,
    ).hex()
    return hmac.compare_digest(hashed, original_hash)
