from fastapi import FastAPI
from core.config import settings
from fast.middleware.cors import CORSMiddleware

from api.routers_users import router as users_router
from api.routers_children import router as children_router

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

app.include_router(
    users_router,
    prefix=settings.API_V1_STR + "/users",
    tags=["Users"]
)

app.include_router(
    children_router,
    prefix=settings.API_V1_STR + "/children",
    tags=["Children"]
)