from google.cloud import firestore
from app.schemas.schemas import UserCreate, ChildCreate, ChildUpdateLocation
from core.firebase import get_db
from datetime import datetime
import pytz

def get_user(uid: str):
    db = get_db()
    user_ref = db.collection('users').document(uid)
    user = user_ref.get()
    if user.exists:
        data = user.to_dict()
        data['uid'] = user.id
        return data
    return None

def create_user(uid: str, user_data: UserCreate):
    db = get_db()
    user_ref = db.collection('users').document(uid)
    data = user_data.model_dump()
    data['created_at'] = datetime.now(pytz.utc)
    user_ref.set(data)
    data['uid'] = uid
    return data

def get_children_for_guardian(guardian_id: str):
    db = get_db()
    # Note: This query requires an index in Firestore
    children_ref = (
        db.collection('children')
        .where(filter=firestore.FieldFilter('guardian_id', '==', guardian_id))
        .order_by('last_updated', direction=firestore.Query.DESCENDING)
    )
    children = children_ref.stream()
    result = []
    for child in children:
        data = child.to_dict()
        data['id'] = child.id
        result.append(data)
    return result