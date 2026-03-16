"""
Authentication router for KidCloud.
"""

from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.parent import Parent
from app.models.parent_otp import ParentOTP
from app.schemas.auth_schema import OTPVerifyRequest, ParentRegister
from app.services.auth.otp_service import create_otp
from app.services.auth.password_service import hash_password

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register")
def register(data: ParentRegister, db: Session = Depends(get_db)):
    """Register a new parent."""
    # Check if email already exists
    existing = db.query(Parent).filter(Parent.email == data.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Hash the password
    hashed = hash_password(data.password)

    # Combine first_name and last_name into name
    name = f"{data.first_name} {data.last_name}"

    # Create Parent object
    parent = Parent(
        name=name,
        email=data.email,
        phone_number=data.phone_number,
        password_hash=hashed,
    )

    # Save to database
    db.add(parent)
    db.commit()
    db.refresh(parent)

    # Generate OTP
    otp_code = create_otp(db, parent.id)
    print(f"Generated OTP for {parent.email}: {otp_code}")

    return {"message": "Account created. OTP sent to your email."}

@router.post("/verify-otp")
def verify_otp(data: OTPVerifyRequest, db: Session = Depends(get_db)):
    """Verify OTP sent to parent's email.""" 