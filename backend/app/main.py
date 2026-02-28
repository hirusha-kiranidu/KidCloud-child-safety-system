from fastapi import FastAPI
from core.config import settings

app = FastAPI(
    title=settings.KidCloud,
    description="Backend API for KidCloud application",
    version="1.0.0",
)

@app.get("/")
def read_root():
    return {"message": "KidCloud Backend is running"}
