from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from models.schemas import ChildCreate, ChildResponse, ChildUpdateLocation
from service import firestore_crud
from core.security import get_current_user_id

router = APIRouter()