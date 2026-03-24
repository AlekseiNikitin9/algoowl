from pydantic import BaseModel, Field


class SubmitCodeRequest(BaseModel):
    problem_id: str
    language: str = Field(..., pattern="^(python|javascript)$")
    code: str = Field(..., max_length=10240)  # 10KB max


class TestResultResponse(BaseModel):
    input: str
    expected: str
    actual: str | None = None
    passed: bool


class SubmissionResponse(BaseModel):
    submission_id: str
    status: str  # pending, accepted, wrong_answer, runtime_error, time_limit
    test_cases_passed: int
    test_cases_total: int
    runtime_ms: int | None = None
    memory_mb: int | None = None
    test_results: list[TestResultResponse] = []

    class Config:
        from_attributes = True
