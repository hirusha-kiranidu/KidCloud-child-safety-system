"""
Authentication router for KidCloud.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.parent import Parent
from app.schemas.auth_schema import ParentRegister, ParentResponse
from app.services.auth.password_service import hash_password

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=ParentResponse)
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

    # Return ParentResponse
    return ParentResponse(
        id=parent.id,
        name=parent.name,
        email=parent.email,
        phone_number=parent.phone_number,
        created_at=parent.created_at,
    )