from pydantic import BaseModel, Field


class ProgressResponse(BaseModel):
    user_id: str
    xp: int
    streak: int
    problems_solved: int
    problems_attempted: int
    daily_goal_minutes: int
    experience_level: str
    focus: str
    onboarding_complete: bool

    class Config:
        from_attributes = True


class UpdateSettingsRequest(BaseModel):
    daily_goal_minutes: int | None = Field(None, ge=5, le=120)
    experience_level: str | None = Field(None, pattern="^(beginner|intermediate|advanced)$")
    focus: str | None = Field(None, pattern="^(algorithms|data_structures|both)$")


class OnboardingRequest(BaseModel):
    daily_goal_minutes: int = Field(..., ge=5, le=120)
    experience_level: str = Field(..., pattern="^(beginner|intermediate|advanced)$")
    focus: str = Field(..., pattern="^(algorithms|data_structures|both)$")


class ReviewQueueItem(BaseModel):
    problem_id: str
    title: str
    slug: str
    difficulty: str
    category_id: str
    ease_factor: float
    next_review_at: str

    class Config:
        from_attributes = True
