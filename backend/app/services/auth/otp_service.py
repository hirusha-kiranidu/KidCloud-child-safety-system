"""
OTP generation and storage service for KidCloud.
"""

import random
from datetime import datetime, timedelta

from sqlalchemy.orm import Session

from app.models.parent_otp import ParentOTP

OTP_EXPIRY_MINUTES = 5


def generate_otp() -> str:
    """Generate a secure 6-digit numeric OTP."""
    return str(random.SystemRandom().randint(100000, 999999))


def create_otp(db: Session, parent_id: int) -> str:
    """
    Generate a new OTP, store it in the database with 5-minute expiry,
    and return the generated OTP.
    """
    otp_code = generate_otp()
    expires_at = datetime.utcnow() + timedelta(minutes=OTP_EXPIRY_MINUTES)

    parent_otp = ParentOTP(
        parent_id=parent_id,
        otp_code=otp_code,
        expires_at=expires_at,
    )

    db.add(parent_otp)
    db.commit()
    db.refresh(parent_otp)

    return otp_code