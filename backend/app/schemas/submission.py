from pydantic import BaseModel, Field


class SubmitCodeRequest(BaseModel):
    problem_id: str
    language: str = Field(..., pattern="^(python|javascript)$")
    code: str = Field(..., max_length=10240)


class RunCodeRequest(BaseModel):
    language: str = Field(..., pattern="^(python|javascript)$")
    code: str = Field(..., max_length=10240)
    test_input: str = Field(..., max_length=2000)
    expected_output: str = Field(default="", max_length=500)


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
    stdout: str | None = None
    error: str | None = None

    class Config:
        from_attributes = True


class RunCodeResponse(BaseModel):
    status: str
    actual: str | None = None
    stdout: str | None = None
    error: str | None = None
    runtime_ms: int | None = None
