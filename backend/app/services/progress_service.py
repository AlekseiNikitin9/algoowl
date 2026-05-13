"""Progress service — user stats, settings, onboarding."""

import uuid

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.user import User
from ..models.progress import UserProgress
from ..models.problem import Category, Problem
from ..utils.logging import get_logger

log = get_logger("services.progress")


async def get_user_stats(
    db: AsyncSession,
    user: User,
) -> dict:
    """Aggregate user progress stats."""
    log.info("get_user_stats user=%s", user.id)
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

    log.info("get_user_stats user=%s solved=%d attempted=%d xp=%d", user.id, solved, attempted, user.xp)
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


async def get_solved_slugs(db: AsyncSession, user: User) -> list[str]:
    """Return slugs of all problems the user has solved."""
    result = await db.execute(
        select(Problem.slug)
        .join(UserProgress, UserProgress.problem_id == Problem.id)
        .where(
            UserProgress.user_id == user.id,
            UserProgress.status == "solved",
        )
    )
    return [row[0] for row in result.all()]


async def get_category_statuses(db: AsyncSession, user: User) -> list[dict]:
    """Return per-category status (locked/current/completed) based on user progress."""
    cats_result = await db.execute(select(Category).order_by(Category.order_index))
    categories = cats_result.scalars().all()
    if not categories:
        return []

    # Total problems per category
    totals_result = await db.execute(
        select(Problem.category_id, func.count(Problem.id)).group_by(Problem.category_id)
    )
    totals: dict[str, int] = {str(row[0]): row[1] for row in totals_result.all()}

    # Solved problems per category for this user
    solved_result = await db.execute(
        select(Problem.category_id, func.count(Problem.id))
        .join(UserProgress, UserProgress.problem_id == Problem.id)
        .where(
            UserProgress.user_id == user.id,
            UserProgress.status == "solved",
        )
        .group_by(Problem.category_id)
    )
    solved: dict[str, int] = {str(row[0]): row[1] for row in solved_result.all()}

    statuses = []
    prev_unlocked = True  # first category always accessible

    for cat in categories:
        cat_id = str(cat.id)
        total = totals.get(cat_id, 0)
        s = solved.get(cat_id, 0)
        progress = s / total if total > 0 else 0.0

        if not prev_unlocked:
            statuses.append({
                "slug": cat.slug,
                "status": "locked",
                "progress": 0.0,
                "problems_total": total,
                "problems_solved": 0,
            })
            continue

        completed = total > 0 and progress >= cat.unlock_threshold
        statuses.append({
            "slug": cat.slug,
            "status": "completed" if completed else "current",
            "progress": round(progress, 4),
            "problems_total": total,
            "problems_solved": s,
        })
        prev_unlocked = completed

    return statuses


async def update_settings(
    db: AsyncSession,
    user: User,
    daily_goal_minutes: int | None = None,
    experience_level: str | None = None,
    focus: str | None = None,
) -> User:
    """Patch user settings. Only updates non-None fields."""
    log.info(
        "update_settings user=%s daily_goal_minutes=%s experience_level=%s focus=%s",
        user.id, daily_goal_minutes, experience_level, focus,
    )
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
    log.info(
        "save_onboarding user=%s goal=%dmin level=%s focus=%s",
        user.id, daily_goal_minutes, experience_level, focus,
    )
    user.daily_goal_minutes = daily_goal_minutes
    user.experience_level = experience_level
    user.focus = focus
    user.onboarding_complete = True
    return user
