import random
from datetime import datetime, timedelta

OTP_EXPIRATION_MINUTES = 5


def generate_otp():
    """
    Generate a 6 digit OTP
    """
    return str(random.randint(100000, 999999))


def get_expiration_time():
    """
    Calculate OTP expiration time
    """
    return datetime.utcnow() + timedelta(minutes=OTP_EXPIRATION_MINUTES)