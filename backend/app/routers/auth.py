from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..schemas.auth import (
    AppleTokenRequest,
    GoogleTokenRequest,
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    TokenResponse,
    UserResponse,
)
from ..services.auth_service import (
    get_current_user,
    login_user,
    login_with_apple,
    login_with_google,
    refresh_tokens,
    register_user,
)
from ..models.user import User

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=TokenResponse)
async def register(body: RegisterRequest, db: AsyncSession = Depends(get_db)):
    user, access_token, refresh_token = await register_user(
        db, body.email, body.password, body.name
    )
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user_id=str(user.id),
    )


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest, db: AsyncSession = Depends(get_db)):
    user, access_token, refresh_token = await login_user(
        db, body.email, body.password
    )
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user_id=str(user.id),
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    access_token, refresh_token = await refresh_tokens(db, body.refresh_token)
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user_id="",  # not returned on refresh — client already knows
    )


@router.post("/google", response_model=TokenResponse)
async def google_login(body: GoogleTokenRequest, db: AsyncSession = Depends(get_db)):
    user, access_token, refresh_token = await login_with_google(db, body.id_token)
    return TokenResponse(access_token=access_token, refresh_token=refresh_token, user_id=str(user.id))


@router.post("/apple", response_model=TokenResponse)
async def apple_login(body: AppleTokenRequest, db: AsyncSession = Depends(get_db)):
    user, access_token, refresh_token = await login_with_apple(db, body.identity_token, body.full_name)
    return TokenResponse(access_token=access_token, refresh_token=refresh_token, user_id=str(user.id))


@router.get("/me", response_model=UserResponse)
async def me(user: User = Depends(get_current_user)):
    return UserResponse(
        id=str(user.id),
        email=user.email,
        name=user.name,
        xp=user.xp,
        streak=user.streak,
        daily_goal_minutes=user.daily_goal_minutes,
        experience_level=user.experience_level,
        focus=user.focus,
        onboarding_complete=user.onboarding_complete,
        avatar_url=user.avatar_url,
        created_at=user.created_at,
    )
