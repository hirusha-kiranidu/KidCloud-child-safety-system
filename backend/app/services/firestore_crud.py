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