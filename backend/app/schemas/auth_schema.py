"""
    Authentication schemas for KidCloud child safety system.
"""


from datetime import datetime
from pydantic import BaseModel, EmailStr, model_validator


class ParentRegister(BaseModel):
    """Schema for parent registration."""

    first_name: str
    last_name: str
    email: EmailStr
    phone_number: str
    password: str
    confirm_password: str

    @model_validator(mode="after")
    def passwords_match(self) -> "ParentRegister":
        if self.password != self.confirm_password:
            raise ValueError("password and confirm_password do not match")
        return self


class ParentResponse(BaseModel):
    """Schema for parent response data."""

    id: int
    name: str
    email: str
    phone_number: str
    created_at: datetime


class OTPVerifyRequest(BaseModel):
    """Schema for OTP verification request."""

    email: EmailStr
    otp_code: str



class LoginRequest(BaseModel):
    """Schema for parent login."""

    email: EmailStr
    password: str
