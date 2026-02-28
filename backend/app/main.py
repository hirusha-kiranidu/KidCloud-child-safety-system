from fastapi import FastAPI
from core.config import settings
from fast.middleware.cors import CORSMiddleware

app = FastAPI(
    title=settings.KidCloud,
    description="Backend API for KidCloud application",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "KidCloud Backend is running"}
