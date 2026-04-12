import asyncio

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..models.user import User
from ..schemas.submission import (
    RunCodeRequest,
    RunCodeResponse,
    SubmissionResponse,
    SubmitCodeRequest,
)
from ..services.auth_service import get_current_user
from ..services.submission_service import create_submission, get_submission
from ..worker.executor import run_in_container

router = APIRouter(prefix="/submissions", tags=["submissions"])


@router.post("", response_model=SubmissionResponse, status_code=201)
async def submit_code(
    body: SubmitCodeRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Submit code for execution. Returns immediately with pending status."""
    submission = await create_submission(
        db=db,
        user_id=user.id,
        problem_id=body.problem_id,
        language=body.language,
        code=body.code,
    )
    return SubmissionResponse(
        submission_id=str(submission.id),
        status=submission.status,
        test_cases_passed=submission.test_cases_passed,
        test_cases_total=submission.test_cases_total,
        runtime_ms=submission.runtime_ms,
        memory_mb=submission.memory_mb,
    )


@router.get("/{submission_id}", response_model=SubmissionResponse)
async def get_submission_result(
    submission_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Poll for submission result. Frontend calls this every 600ms until status != pending."""
    submission = await get_submission(db, submission_id, user.id)

    feedback = submission.ai_feedback or {}
    test_results = feedback.get("test_results", [])
    stdout = feedback.get("stdout")
    error = feedback.get("error")

    return SubmissionResponse(
        submission_id=str(submission.id),
        status=submission.status,
        test_cases_passed=submission.test_cases_passed,
        test_cases_total=submission.test_cases_total,
        runtime_ms=submission.runtime_ms,
        memory_mb=submission.memory_mb,
        test_results=test_results,
        stdout=stdout,
        error=error,
    )


@router.post("/run", response_model=RunCodeResponse)
async def run_custom(
    body: RunCodeRequest,
    user: User = Depends(get_current_user),
):
    """Run code against a single custom test case — no DB storage, instant response."""
    loop = asyncio.get_event_loop()
    result = await loop.run_in_executor(
        None,
        run_in_container,
        body.language,
        body.code,
        [{"input": body.test_input, "expected_output": body.expected_output}],
    )

    test_results = result.get("test_results", [])
    actual = test_results[0].get("actual") if test_results else None

    return RunCodeResponse(
        status=result.get("status", "runtime_error"),
        actual=actual,
        stdout=result.get("stdout"),
        error=result.get("error"),
        runtime_ms=result.get("runtime_ms"),
    )
