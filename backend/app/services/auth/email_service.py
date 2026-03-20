"""
SMTP email delivery for KidCloud (OTP and related messages).

Configure EMAIL_HOST, EMAIL_PORT, EMAIL_USER, EMAIL_PASSWORD in .env.
"""

import logging
import os
import smtplib
from email.mime.text import MIMEText

from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

EMAIL_HOST = os.getenv("EMAIL_HOST")
EMAIL_PORT_STR = os.getenv("EMAIL_PORT", "587")
EMAIL_USER = os.getenv("EMAIL_USER")
EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")

OTP_SUBJECT = "KidCloud OTP Verification"


def _smtp_config_ready() -> bool:
    return all([EMAIL_HOST, EMAIL_PORT_STR, EMAIL_USER, EMAIL_PASSWORD])


def send_otp_email(to_email: str, otp_code: str) -> bool:
    """
    Send OTP verification email via SMTP with STARTTLS.

    Returns True if the message was accepted by the server, False otherwise.
    """
    if not _smtp_config_ready():
        logger.error(
            "Email not sent: missing EMAIL_HOST, EMAIL_PORT, EMAIL_USER, or "
            "EMAIL_PASSWORD in environment."
        )
        print(
            "[email_service] FAILURE: SMTP not configured (check .env variables)."
        )
        return False
