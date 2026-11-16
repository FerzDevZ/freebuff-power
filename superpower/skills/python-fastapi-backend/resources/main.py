# Production FastAPI Application Template
from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr, Field

class UserCreate(BaseModel):
    email: EmailStr
    full_name: str = Field(min_length=2, max_length=100)

class UserResponse(BaseModel):
    id: str
    email: EmailStr
    full_name: str

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Connect to DB / Warm caches
    yield
    # Shutdown: Close pools

app = FastAPI(title="Core API Service", lifespan=lifespan)

@app.get("/health", status_code=status.HTTP_200_OK)
async def health_check():
    return {"status": "healthy"}
