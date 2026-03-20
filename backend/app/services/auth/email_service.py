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
