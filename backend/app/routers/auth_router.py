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
from app.services.auth.email_service import send_otp_email
from app.services.auth.jwt_service import create_access_token
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
    send_otp_email(parent.email, otp_code)

    return {"message": "Account created. OTP sent to your email."}

@router.post("/verify-otp")
def verify_otp(data: OTPVerifyRequest, db: Session = Depends(get_db)):
    """Verify OTP sent to parent's email.""" 
    parent = db.query(Parent).filter(Parent.email == data.email).first()
    if not parent:
        raise HTTPException(status_code=404, detail="Parent not found")
    otp = (
        db.query(ParentOTP)
        .filter(ParentOTP.parent_id == parent.id)
        .order_by(ParentOTP.created_at.desc())
        .first()
    )

    if not otp:
        raise HTTPException(status_code=400, detail="OTP not found")
    
    if datetime.utcnow() > otp.expires_at:
        raise HTTPException(status_code=400, detail="OTP expired")
    
    if otp.otp_code != data.otp_code:
        raise HTTPException(status_code=400, detail="Invalide OTP")
    

    parent.is_verified
    db.commit ()

    access_token = create_access_token(
        {"id": parent.id, "email": parent.email}
    )

    return {
        "message": "Email verified successfully",
        "access_token": access_token,
        "token_type": "bearer",
    }

    