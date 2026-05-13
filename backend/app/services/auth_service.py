import uuid
from datetime import datetime, timedelta, timezone

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..models.user import RefreshToken, User
from ..utils.security import (
    create_access_token,
    create_refresh_token,
    decode_access_token,
    hash_password,
    hash_token,
    verify_apple_identity_token,
    verify_google_id_token,
    verify_password,
)
from ..config import settings
from ..utils.logging import get_logger

log = get_logger("auth")
security = HTTPBearer()


async def register_user(
    db: AsyncSession,
    email: str,
    password: str,
    name: str,
) -> tuple[User, str, str]:
    """Register a new user. Returns (user, access_token, refresh_token_raw)."""
    # Check if email exists
    existing = await db.execute(select(User).where(User.email == email))
    if existing.scalar_one_or_none():
        log.info("register CONFLICT email=%s", email)
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered",
        )

    user = User(
        email=email,
        password_hash=hash_password(password),
        name=name,
    )
    db.add(user)
    await db.flush()

    access_token = create_access_token(str(user.id))
    raw_refresh, refresh_hash = create_refresh_token()

    db.add(RefreshToken(
        user_id=user.id,
        token_hash=refresh_hash,
        expires_at=datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days),
    ))

    log.info("register OK email=%s user_id=%s", email, user.id)
    return user, access_token, raw_refresh


async def login_user(
    db: AsyncSession,
    email: str,
    password: str,
) -> tuple[User, str, str]:
    """Authenticate user. Returns (user, access_token, refresh_token_raw)."""
    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()

    if not user or not user.password_hash or not verify_password(password, user.password_hash):
        log.warning("login FAIL email=%s", email)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    access_token = create_access_token(str(user.id))
    raw_refresh, refresh_hash = create_refresh_token()

    db.add(RefreshToken(
        user_id=user.id,
        token_hash=refresh_hash,
        expires_at=datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days),
    ))

    log.info("login OK email=%s user_id=%s", email, user.id)
    return user, access_token, raw_refresh


async def refresh_tokens(
    db: AsyncSession,
    raw_token: str,
) -> tuple[str, str]:
    """Rotate refresh token. Returns (new_access_token, new_refresh_token_raw)."""
    token_hash = hash_token(raw_token)

    result = await db.execute(
        select(RefreshToken).where(RefreshToken.token_hash == token_hash)
    )
    stored = result.scalar_one_or_none()

    if not stored or stored.expires_at < datetime.now(timezone.utc):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token",
        )

    # Rotate: delete old, create new
    await db.delete(stored)

    access_token = create_access_token(str(stored.user_id))
    new_raw, new_hash = create_refresh_token()

    db.add(RefreshToken(
        user_id=stored.user_id,
        token_hash=new_hash,
        expires_at=datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days),
    ))

    return access_token, new_raw


async def _oauth_login_or_create(
    db: AsyncSession,
    provider: str,
    oauth_id: str,
    email: str,
    name: str,
    avatar_url: str | None = None,
) -> tuple[User, str, str]:
    """Find or create a user via OAuth. Returns (user, access_token, refresh_token_raw)."""
    # 1. Look up by provider + oauth_id (returning user)
    result = await db.execute(
        select(User).where(User.oauth_provider == provider, User.oauth_id == oauth_id)
    )
    user = result.scalar_one_or_none()

    if user is None:
        # 2. Look up by email (link existing email account)
        result = await db.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()
        if user is not None:
            user.oauth_provider = provider
            user.oauth_id = oauth_id
            if avatar_url:
                user.avatar_url = avatar_url
            log.info("oauth LINK email=%s provider=%s", email, provider)

    if user is None:
        # 3. Create new user
        user = User(email=email, name=name, oauth_provider=provider, oauth_id=oauth_id, avatar_url=avatar_url)
        db.add(user)
        await db.flush()
        log.info("oauth CREATE email=%s provider=%s user_id=%s", email, provider, user.id)

    access_token = create_access_token(str(user.id))
    raw_refresh, refresh_hash = create_refresh_token()
    db.add(RefreshToken(
        user_id=user.id,
        token_hash=refresh_hash,
        expires_at=datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days),
    ))
    log.info("oauth LOGIN OK email=%s provider=%s user_id=%s", email, provider, user.id)
    return user, access_token, raw_refresh


async def login_with_google(db: AsyncSession, id_token: str) -> tuple[User, str, str]:
    claims = await verify_google_id_token(id_token)
    oauth_id = claims["sub"]
    email = claims.get("email") or f"google_{oauth_id}@privaterelay.codekata.app"
    name = claims.get("name") or claims.get("given_name") or email.split("@")[0]
    avatar_url = claims.get("picture")
    return await _oauth_login_or_create(db, "google", oauth_id, email, name, avatar_url=avatar_url)


async def login_with_apple(
    db: AsyncSession,
    identity_token: str,
    full_name: str | None,
) -> tuple[User, str, str]:
    claims = await verify_apple_identity_token(identity_token)
    oauth_id = claims["sub"]
    email = claims.get("email") or f"apple_{oauth_id}@privaterelay.appleid.com"
    name = full_name or email.split("@")[0]
    return await _oauth_login_or_create(db, "apple", oauth_id, email, name)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db),
) -> User:
    """FastAPI dependency — extracts and validates the current user from JWT."""
    payload = decode_access_token(credentials.credentials)
    if not payload or "sub" not in payload:
        log.warning("token INVALID (bad/expired JWT)")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    result = await db.execute(
        select(User).where(User.id == uuid.UUID(payload["sub"]))
    )
    user = result.scalar_one_or_none()
    if not user:
        log.warning("token INVALID user_id=%s not in DB", payload["sub"])
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )
    return user
