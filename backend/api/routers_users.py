from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.schemas import UserCreate, UserResponse
from service import firestore_crud
from core.security import get_current_user_id

router = APIRouter()

@router.post("/profile", response_model=UserResponse)
def create_or_update_profile(
    user_data: UserCreate,
    uid: str = Depends(get_current_user_id)
):
    """
    Create or update the guardian's profile after Firebase auth registration.
    """
    user = firestore_crud.create_user(uid, user_data)
    return user

    @router.get("/me", response_model=UserResponse)
def get_my_profile(uid: str = Depends(get_current_user_id)):
    """
    Get the currently logged in guardian's profile.
    """
    user = firestore_crud.get_user(uid)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )
    return user