"""Progress service — user stats, settings, onboarding."""

import uuid

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.user import User
from ..models.progress import UserProgress


async def get_user_stats(
    db: AsyncSession,
    user: User,
) -> dict:
    """Aggregate user progress stats."""
    # Count solved / attempted
    solved_result = await db.execute(
        select(func.count()).where(
            UserProgress.user_id == user.id,
            UserProgress.status == "solved",
        )
    )
    solved = solved_result.scalar() or 0

    attempted_result = await db.execute(
        select(func.count()).where(
            UserProgress.user_id == user.id,
            UserProgress.status.in_(["attempted", "solved"]),
        )
    )
    attempted = attempted_result.scalar() or 0

    return {
        "user_id": str(user.id),
        "xp": user.xp,
        "streak": user.streak,
        "problems_solved": solved,
        "problems_attempted": attempted,
        "daily_goal_minutes": user.daily_goal_minutes,
        "experience_level": user.experience_level,
        "focus": user.focus,
        "onboarding_complete": user.onboarding_complete,
    }


async def update_settings(
    db: AsyncSession,
    user: User,
    daily_goal_minutes: int | None = None,
    experience_level: str | None = None,
    focus: str | None = None,
) -> User:
    """Patch user settings. Only updates non-None fields."""
    if daily_goal_minutes is not None:
        user.daily_goal_minutes = daily_goal_minutes
    if experience_level is not None:
        user.experience_level = experience_level
    if focus is not None:
        user.focus = focus
    return user


async def save_onboarding(
    db: AsyncSession,
    user: User,
    daily_goal_minutes: int,
    experience_level: str,
    focus: str,
) -> User:
    """Save onboarding selections and mark complete."""
    user.daily_goal_minutes = daily_goal_minutes
    user.experience_level = experience_level
    user.focus = focus
    user.onboarding_complete = True
    return user
