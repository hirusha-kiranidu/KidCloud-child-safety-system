from google.cloud import firestore
from app.schemas.schemas import UserCreate, ChildCreate, ChildUpdateLocation
from core.firebase import get_db
from datetime import datetime
import pytz