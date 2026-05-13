from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..models.problem import Problem
from ..models.progress import SpacedRep
from ..models.user import User
from ..schemas.progress import (
    CategoryStatusItem,
    OnboardingRequest,
    ProgressResponse,
    ReviewQueueItem,
    UpdateSettingsRequest,
)
from ..services.auth_service import get_current_user
from ..services.progress_service import (
    get_category_statuses,
    get_solved_slugs,
    get_user_stats,
    save_onboarding,
    update_settings,
)
from ..utils.logging import get_logger

log = get_logger("routers.progress")
router = APIRouter(prefix="/progress", tags=["progress"])


@router.get("/me", response_model=ProgressResponse)
async def get_my_progress(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Home screen stats — XP, streak, solve counts."""
    log.info("get_my_progress user=%s", user.id)
    stats = await get_user_stats(db, user)
    return ProgressResponse(**stats)


@router.patch("/me/settings", response_model=ProgressResponse)
async def patch_settings(
    body: UpdateSettingsRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update daily goal, experience level, or focus."""
    log.info("patch_settings user=%s body=%s", user.id, body.model_dump(exclude_none=True))
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
    log.info("complete_onboarding user=%s", user.id)
    await save_onboarding(
        db,
        user,
        daily_goal_minutes=body.daily_goal_minutes,
        experience_level=body.experience_level,
        focus=body.focus,
    )
    stats = await get_user_stats(db, user)
    return ProgressResponse(**stats)


@router.get("/me/solved-slugs")
async def get_my_solved_slugs(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return slugs of all problems this user has solved."""
    log.info("get_my_solved_slugs user=%s", user.id)
    slugs = await get_solved_slugs(db, user)
    return {"slugs": slugs}


@router.get("/me/category-status", response_model=list[CategoryStatusItem])
async def get_my_category_status(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return per-category lock/progress status based on user progress."""
    log.info("get_my_category_status user=%s", user.id)
    return await get_category_statuses(db, user)


@router.get("/me/queue", response_model=list[ReviewQueueItem])
async def get_review_queue(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return problems due for spaced-rep review today."""
    log.info("get_review_queue user=%s", user.id)
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

    log.info("get_review_queue user=%s returning %d items", user.id, len(rows))
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
