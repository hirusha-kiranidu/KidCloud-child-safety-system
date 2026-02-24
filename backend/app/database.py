from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv
import os


# ---------------------------------------------------
# Load Environment Variables
# ---------------------------------------------------
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL is not set in the environment variables.")


# ---------------------------------------------------
# Database Engine
# ---------------------------------------------------
engine = create_engine(
    DATABASE_URL,
    echo=True,              # Show SQL queries (disable in production)
    pool_pre_ping=True      # Prevent stale connections
)


# ---------------------------------------------------
# Session Configuration
# ---------------------------------------------------
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)


# ---------------------------------------------------
# Base Model
# ---------------------------------------------------
Base = declarative_base()


# ---------------------------------------------------
# Dependency for FastAPI Routes
# ---------------------------------------------------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

