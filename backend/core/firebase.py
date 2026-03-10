import os
import firebase_admin
from firebase_admin import credentials, firestore
from .config import settings

def initialize_firebase():

    if not firebase_admin._apps:
        try:
            if os.path.exists(settings.FIREBASE_CREDENTIALS_PATH):
                cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
                firebase_admin.initialize_app(cred)
                print("Firebase Admin SDK initialized successfully.")

            else:
                firebase_admin.initialize_app()
                print(
                    f"Warning: {settings.FIREBASE_CREDENTIALS_PATH} not found. "
                    "using default credentials."
                )
        except Exception as e:
            print(f"Failed to initialize Firebase: {e}")

initialize_firebase()

def get_db():
    return firestore.client()