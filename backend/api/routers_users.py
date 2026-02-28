from fastapi import APIRouter, Depends, HTTPException, status
from models.schemas import UserCreate, UserResponse
from service import firestore_crud
from core.security import get_current_user_id

router = APIRouter()