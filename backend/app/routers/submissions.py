from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..models.user import User
from ..schemas.submission import SubmissionResponse, SubmitCodeRequest
from ..services.auth_service import get_current_user
from ..services.submission_service import create_submission, get_submission

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
    """Poll for submission result. Frontend calls this every 500ms until status != pending."""
    submission = await get_submission(db, submission_id, user.id)

    # Build test_results from stored data if available
    test_results = []
    if submission.ai_feedback and "test_results" in submission.ai_feedback:
        test_results = submission.ai_feedback["test_results"]

    return SubmissionResponse(
        submission_id=str(submission.id),
        status=submission.status,
        test_cases_passed=submission.test_cases_passed,
        test_cases_total=submission.test_cases_total,
        runtime_ms=submission.runtime_ms,
        memory_mb=submission.memory_mb,
        test_results=test_results,
    )
