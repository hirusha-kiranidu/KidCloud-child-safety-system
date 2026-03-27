"""
JWT access token creation for KidCloud.

Uses HS256. Set JWT_SECRET_KEY in the environment (e.g. .env) for production.
"""

import os
from datetime import datetime, timedelta, timezone

from dotenv import load_dotenv
from jose import jwt

load_dotenv()

ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_DAYS = 1

SECRET_KEY = os.getenv("JWT_SECRET_KEY")
if not SECRET_KEY:
    raise ValueError(
        "JWT_SECRET_KEY is not set. Add it to your environment or .env file."
    )


def create_access_token(data: dict) -> str:
    """
    Encode a JWT access token with the given claims.

    Merges `data` with `exp` (expiration, UTC, 1 day from now) and returns
    the signed token string.
    """
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=ACCESS_TOKEN_EXPIRE_DAYS)
    to_encode["exp"] = int(expire.timestamp())

    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
