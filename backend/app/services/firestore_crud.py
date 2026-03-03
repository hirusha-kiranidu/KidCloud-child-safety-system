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

    def add_child(guardian_id: str, child_data: ChildCreate):
    db = get_db()
    data = child_data.model_dump()
    data['guardian_id'] = guardian_id
    data['status'] = 'Idle'
    data['speed_kmh'] = 0.0
    data['location'] = {'latitude': 0.0, 'longitude': 0.0}
    data['last_updated'] = datetime.now(pytz.utc)
    
    _, doc_ref = db.collection('children').add(data)
    data['id'] = doc_ref.id
    return data


def update_child_location(child_id: str, location_data: ChildUpdateLocation):
    db = get_db()
    child_ref = db.collection('children').document(child_id)
    child = child_ref.get()
    if not child.exists:
        return None
    
    update_data = location_data.model_dump()
    update_data['last_updated'] = datetime.now(pytz.utc)
    child_ref.update(update_data)
    
    updated_child = child_ref.get().to_dict()
    updated_child['id'] = child.id
    return updated_child