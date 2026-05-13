from datetime import datetime

from pydantic import BaseModel, EmailStr


class RegisterRequest(BaseModel):
    email: str
    password: str
    name: str


class LoginRequest(BaseModel):
    email: str
    password: str


class RefreshRequest(BaseModel):
    refresh_token: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user_id: str


class GoogleTokenRequest(BaseModel):
    id_token: str


class AppleTokenRequest(BaseModel):
    identity_token: str
    full_name: str | None = None


class UserResponse(BaseModel):
    id: str
    email: str
    name: str
    xp: int
    streak: int
    daily_goal_minutes: int
    experience_level: str
    focus: str
    onboarding_complete: bool
    avatar_url: str | None = None
    created_at: datetime | None = None

    class Config:
        from_attributes = True
