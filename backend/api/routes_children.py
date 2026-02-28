from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from models.schemas import ChildCreate, ChildResponse, ChildUpdateLocation
from service import firestore_crud
from core.security import get_current_user_id

router = APIRouter()

@router.get("/", response_model=List[ChildResponse])
def get_my_children(uid: str = Depends(get_current_user_id)):
    """
    Get all children registered to the currently logged in guardian.
    """
    children = firestore_crud.get_children_for_guardian(uid)
    return children