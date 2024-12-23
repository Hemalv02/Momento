from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import Optional

class RegisterData(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    username: str
    name: str
    date_of_birth: str

class LoginData(BaseModel):
    email: EmailStr
    password: str

class ChatData(BaseModel):
    user_id: int
    event_id: int
    message: str
    created_at: Optional[datetime] = Field(default_factory=datetime.utcnow)

class FeedbackData(BaseModel):
    user_id: int
    event_id: int
    feedback: str
    rating: int
    created_at: Optional[datetime] = Field(default_factory=datetime.utcnow)
