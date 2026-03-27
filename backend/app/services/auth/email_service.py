"""
SMTP email delivery for KidCloud (OTP and related messages).

Configure EMAIL_HOST, EMAIL_PORT, EMAIL_USER, EMAIL_PASSWORD in .env.
"""

import logging
import os
from email.mime.text import MIMEText
import smtplib


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
    
    try:
        port = int(EMAIL_PORT_STR)
    except ValueError:
        logger.error("EMAIL_PORT must be an integer, got: %s", EMAIL_PORT_STR)
        print(f"[email_service] FAILURE: invalid EMAIL_PORT={EMAIL_PORT_STR!r}")
        return False

    body = (
        f"Your OTP code is: {otp_code}. It will expire in 5 minutes."
    )

    msg = MIMEText(body, "plain", "utf-8")
    msg["Subject"] = OTP_SUBJECT
    msg["From"] = EMAIL_USER
    msg["To"] = to_email

    try:
        with smtplib.SMTP(EMAIL_HOST, port, timeout=30) as server:
            server.starttls()
            server.login(EMAIL_USER, EMAIL_PASSWORD)
            server.send_message(msg)

        logger.info("OTP email sent successfully to %s", to_email)
        print(f"[email_service] SUCCESS: OTP email sent to {to_email}")
        return True

    except smtplib.SMTPAuthenticationError as e:
        logger.exception("SMTP authentication failed: %s", e)
        print("[email_service] FAILURE: SMTP authentication failed.")
        return False
    except smtplib.SMTPException as e:
        logger.exception("SMTP error while sending OTP email: %s", e)
        print(f"[email_service] FAILURE: SMTP error: {e}")
        return False
    except OSError as e:
        logger.exception("Network error while sending OTP email: %s", e)
        print(f"[email_service] FAILURE: network error: {e}")
        return False
    except Exception as e:
        logger.exception("Unexpected error while sending OTP email: %s", e)
        print(f"[email_service] FAILURE: unexpected error: {e}")
        return False