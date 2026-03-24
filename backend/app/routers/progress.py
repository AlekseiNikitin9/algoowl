from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..models.problem import Problem
from ..models.progress import SpacedRep
from ..models.user import User
from ..schemas.progress import (
    OnboardingRequest,
    ProgressResponse,
    ReviewQueueItem,
    UpdateSettingsRequest,
)
from ..services.auth_service import get_current_user
from ..services.progress_service import (
    get_user_stats,
    save_onboarding,
    update_settings,
)

router = APIRouter(prefix="/progress", tags=["progress"])


@router.get("/me", response_model=ProgressResponse)
async def get_my_progress(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Home screen stats — XP, streak, solve counts."""
    stats = await get_user_stats(db, user)
    return ProgressResponse(**stats)


@router.patch("/me/settings", response_model=ProgressResponse)
async def patch_settings(
    body: UpdateSettingsRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update daily goal, experience level, or focus."""
    await update_settings(
        db,
        user,
        daily_goal_minutes=body.daily_goal_minutes,
        experience_level=body.experience_level,
        focus=body.focus,
    )
    stats = await get_user_stats(db, user)
    return ProgressResponse(**stats)


@router.put("/me/onboarding", response_model=ProgressResponse)
async def complete_onboarding(
    body: OnboardingRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Save onboarding selections and mark complete."""
    await save_onboarding(
        db,
        user,
        daily_goal_minutes=body.daily_goal_minutes,
        experience_level=body.experience_level,
        focus=body.focus,
    )
    stats = await get_user_stats(db, user)
    return ProgressResponse(**stats)


@router.get("/me/queue", response_model=list[ReviewQueueItem])
async def get_review_queue(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return problems due for spaced-rep review today."""
    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(SpacedRep, Problem)
        .join(Problem, SpacedRep.problem_id == Problem.id)
        .where(
            SpacedRep.user_id == user.id,
            SpacedRep.next_review_at <= now,
        )
        .order_by(SpacedRep.ease_factor.asc())
        .limit(20)
    )
    rows = result.all()

    return [
        ReviewQueueItem(
            problem_id=str(sr.problem_id),
            title=p.title,
            slug=p.slug,
            difficulty=p.difficulty,
            category_id=str(p.category_id),
            ease_factor=sr.ease_factor,
            next_review_at=sr.next_review_at.isoformat(),
        )
        for sr, p in rows
    ]
