from pydantic import BaseModel


class TestCaseResponse(BaseModel):
    input: str
    expected_output: str
    is_hidden: bool

    class Config:
        from_attributes = True


class ProblemResponse(BaseModel):
    id: str
    title: str
    slug: str
    category_id: str
    category_slug: str = ""
    difficulty: str
    description: str
    constraints: str | None
    starter_code: dict
    lesson_content: dict | None = None
    test_cases: list[TestCaseResponse] = []

    class Config:
        from_attributes = True


class ProblemListItem(BaseModel):
    id: str
    title: str
    slug: str
    difficulty: str
    category_id: str
    category_slug: str = ""

    class Config:
        from_attributes = True


class CategoryResponse(BaseModel):
    id: str
    name: str
    slug: str
    icon: str | None
    order_index: int

    class Config:
        from_attributes = True
