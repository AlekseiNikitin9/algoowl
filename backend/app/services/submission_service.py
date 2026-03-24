"""Submission service — enqueues code for execution, retrieves results."""

import json
import uuid

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.problem import Problem, TestCase
from ..models.submission import Submission
from ..models.progress import UserProgress
from ..utils.redis import get_redis


async def create_submission(
    db: AsyncSession,
    user_id: uuid.UUID,
    problem_id: str,
    language: str,
    code: str,
) -> Submission:
    """Validate, persist, and enqueue a code submission."""
    # Verify problem exists
    result = await db.execute(
        select(Problem).where(Problem.id == uuid.UUID(problem_id))
    )
    problem = result.scalar_one_or_none()
    if not problem:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Problem not found",
        )

    # Get all test cases for this problem (including hidden)
    tc_result = await db.execute(
        select(TestCase)
        .where(TestCase.problem_id == problem.id)
        .order_by(TestCase.order_index)
    )
    test_cases = tc_result.scalars().all()

    # Create submission record
    submission = Submission(
        user_id=user_id,
        problem_id=problem.id,
        language=language,
        code=code,
        status="pending",
        test_cases_total=len(test_cases),
    )
    db.add(submission)
    await db.flush()

    # Update user_progress — mark as attempted
    prog_result = await db.execute(
        select(UserProgress).where(
            UserProgress.user_id == user_id,
            UserProgress.problem_id == problem.id,
        )
    )
    progress = prog_result.scalar_one_or_none()
    if progress:
        progress.attempts += 1
        from datetime import datetime, timezone
        progress.last_attempt_at = datetime.now(timezone.utc)
    else:
        from datetime import datetime, timezone
        db.add(UserProgress(
            user_id=user_id,
            problem_id=problem.id,
            status="attempted",
            attempts=1,
            last_attempt_at=datetime.now(timezone.utc),
        ))

    # Enqueue job to Redis for execution worker
    redis = await get_redis()
    job_payload = {
        "submission_id": str(submission.id),
        "problem_id": str(problem.id),
        "language": language,
        "code": code,
        "test_cases": [
            {
                "input": tc.input,
                "expected_output": tc.expected_output,
                "is_hidden": tc.is_hidden,
            }
            for tc in test_cases
        ],
    }
    await redis.lpush("exec:queue", json.dumps(job_payload))

    return submission


async def get_submission(
    db: AsyncSession,
    submission_id: str,
    user_id: uuid.UUID,
) -> Submission:
    """Retrieve a submission by ID, scoped to the requesting user."""
    result = await db.execute(
        select(Submission).where(
            Submission.id == uuid.UUID(submission_id),
            Submission.user_id == user_id,
        )
    )
    submission = result.scalar_one_or_none()
    if not submission:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Submission not found",
        )
    return submission
