"""Execution worker — dequeues jobs from Redis and runs them in sandbox containers.

Run standalone:
    python -m app.worker.main
"""

import asyncio
import json
import logging
import os
import sys
import uuid

import redis.asyncio as redis
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from app.database import async_session, engine
from app.models.submission import Submission
from app.models.progress import UserProgress
from app.models.user import User
from app.worker.executor import run_in_container
from app.config import settings

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [worker] %(levelname)s: %(message)s",
)
logger = logging.getLogger("exec-worker")

XP_REWARD = {
    "easy": 10,
    "medium": 20,
    "hard": 35,
}


async def process_submission(redis_client: redis.Redis, job_data: dict):
    submission_id = job_data["submission_id"]
    problem_id = job_data["problem_id"]
    language = job_data["language"]
    code = job_data["code"]
    test_cases = job_data["test_cases"]

    logger.info(f"Processing submission {submission_id} ({language})")

    loop = asyncio.get_event_loop()
    result = await loop.run_in_executor(
        None,
        run_in_container,
        language,
        code,
        test_cases,
    )

    status = result["status"]
    test_results = result.get("test_results", [])
    passed = sum(1 for t in test_results if t.get("passed"))
    total = len(test_cases)
    runtime_ms = result.get("runtime_ms")
    memory_mb = result.get("memory_mb")
    error = result.get("error")
    stdout = result.get("stdout")

    logger.info(
        f"Submission {submission_id}: {status} "
        f"({passed}/{total} passed, {runtime_ms}ms)"
    )

    async with async_session() as db:
        await db.execute(
            update(Submission)
            .where(Submission.id == uuid.UUID(submission_id))
            .values(
                status=status,
                test_cases_passed=passed,
                test_cases_total=total,
                runtime_ms=runtime_ms,
                memory_mb=memory_mb,
                ai_feedback={
                    "test_results": test_results,
                    "error": error,
                    "stdout": stdout,
                },
            )
        )

        if status == "accepted":
            sub_result = await db.execute(
                select(Submission).where(Submission.id == uuid.UUID(submission_id))
            )
            submission = sub_result.scalar_one()

            prog_result = await db.execute(
                select(UserProgress).where(
                    UserProgress.user_id == submission.user_id,
                    UserProgress.problem_id == submission.problem_id,
                )
            )
            progress = prog_result.scalar_one_or_none()

            already_solved = progress is not None and progress.status == "solved"

            if progress is None:
                from datetime import datetime, timezone
                progress = UserProgress(
                    user_id=submission.user_id,
                    problem_id=submission.problem_id,
                    status="solved",
                    attempts=1,
                    last_attempt_at=datetime.now(timezone.utc),
                )
                db.add(progress)
                logger.info(f"Created solved UserProgress for submission {submission_id}")
            elif progress.status != "solved":
                progress.status = "solved"

            if not already_solved:
                from app.models.problem import Problem
                prob_result = await db.execute(
                    select(Problem).where(Problem.id == submission.problem_id)
                )
                problem = prob_result.scalar_one_or_none()
                xp_award = XP_REWARD.get(problem.difficulty, 10) if problem else 10

                await db.execute(
                    update(User)
                    .where(User.id == submission.user_id)
                    .values(xp=User.xp + xp_award)
                )
                logger.info(f"Awarded {xp_award} XP to user {submission.user_id}")

        await db.commit()


async def worker_loop():
    logger.info("Execution worker starting...")

    redis_client = redis.from_url(settings.redis_url, decode_responses=True)
    await redis_client.ping()
    logger.info("Connected to Redis")

    while True:
        try:
            result = await redis_client.brpop("exec:queue", timeout=5)
            if result is None:
                continue

            _, raw_data = result
            job_data = json.loads(raw_data)
            await process_submission(redis_client, job_data)

        except redis.ConnectionError:
            logger.error("Redis connection lost, retrying in 5s...")
            await asyncio.sleep(5)
        except json.JSONDecodeError as e:
            logger.error(f"Invalid job data: {e}")
        except Exception as e:
            logger.exception(f"Unexpected error processing job: {e}")
            await asyncio.sleep(1)


def main():
    try:
        asyncio.run(worker_loop())
    except KeyboardInterrupt:
        logger.info("Worker shutting down...")


if __name__ == "__main__":
    main()
