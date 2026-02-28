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

@router.post("/", response_model=ChildResponse, status_code=status.HTTP_201_CREATED)
def register_child(child_data: ChildCreate, uid: str = Depends(get_current_user_id)):
    """
    Register a new child to the current guardian.
    """
    child = firestore_crud.add_child(uid, child_data)
    return child

@router.put("/{child_id}/location", response_model=ChildResponse)
def update_location(child_id: str, location_data: ChildUpdateLocation):
    """
    Update a child's live location.
    """
    updated_child = firestore_crud.update_child_location(child_id, location_data)
    if not updated_child:
        raise HTTPException(status_code=404, detail="Child not found")
    return updated_child

@router.get("/{child_id}", response_model=ChildResponse)
def get_child_details(child_id: str, uid: str = Depends(get_current_user_id)):
    """
    Get details of a specific child.
    """
    child = firestore_crud.get_child(child_id, uid)
    if not child:
        raise HTTPException(status_code=404, detail="Child not found or not authorized")
    return child