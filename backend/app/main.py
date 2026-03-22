from fastapi import FastAPI
from app.routers.auth_router import router as auth_router

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "KidCloud Backend is running"}

app.include_router(auth_router)

from dotenv import load_dotenv
load_dotenv
