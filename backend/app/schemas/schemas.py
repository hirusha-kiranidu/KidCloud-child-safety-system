from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime

class UserBase(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone_number: Optional[str] = None

class UserCreate(UserBase):
    pass

class UserResponse(UserBase):
    uid: str
    created_at: datetime

class Location(BaseModel):
    latitude: float
    longitude: float

class ChildBase(BaseModel):
    name: str
    
class ChildCreate(ChildBase):
    pass