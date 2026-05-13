from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..models.problem import Category, Problem, TestCase
from ..schemas.problem import (
    CategoryResponse,
    ProblemListItem,
    ProblemResponse,
    TestCaseResponse,
)
from ..utils.logging import get_logger

log = get_logger("routers.problems")
router = APIRouter(prefix="/problems", tags=["problems"])


@router.get("", response_model=list[ProblemListItem])
async def list_problems(
    category: str | None = Query(None),
    difficulty: str | None = Query(None),
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
):
    log.info("list_problems category=%s difficulty=%s page=%d per_page=%d", category, difficulty, page, per_page)
    query = select(Problem, Category.slug.label("cat_slug")).join(
        Category, Problem.category_id == Category.id
    ).order_by(Problem.order_index)

    if category:
        cat_result = await db.execute(
            select(Category.id).where(Category.slug == category)
        )
        cat_id = cat_result.scalar_one_or_none()
        if not cat_id:
            log.warning("Unknown category slug: %s", category)
        if cat_id:
            query = query.where(Problem.category_id == cat_id)

    if difficulty:
        query = query.where(Problem.difficulty == difficulty)

    query = query.offset((page - 1) * per_page).limit(per_page)
    result = await db.execute(query)
    rows = result.all()
    log.info("list_problems returning %d problems", len(rows))

    return [
        ProblemListItem(
            id=str(p.id),
            title=p.title,
            slug=p.slug,
            difficulty=p.difficulty,
            category_id=str(p.category_id),
            category_slug=cat_slug,
        )
        for p, cat_slug in rows
    ]


@router.get("/{slug}", response_model=ProblemResponse)
async def get_problem(slug: str, db: AsyncSession = Depends(get_db)):
    log.info("get_problem slug=%s", slug)
    result = await db.execute(
        select(Problem, Category.slug.label("cat_slug"))
        .join(Category, Problem.category_id == Category.id)
        .where(Problem.slug == slug)
    )
    row = result.first()

    if not row:
        log.warning("Problem not found: %s", slug)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Problem not found",
        )

    problem, cat_slug = row

    # Get test cases (send hidden ones with masked input/output)
    tc_result = await db.execute(
        select(TestCase)
        .where(TestCase.problem_id == problem.id)
        .order_by(TestCase.order_index)
    )
    test_cases = tc_result.scalars().all()

    return ProblemResponse(
        id=str(problem.id),
        title=problem.title,
        slug=problem.slug,
        category_id=str(problem.category_id),
        category_slug=cat_slug,
        difficulty=problem.difficulty,
        description=problem.description,
        constraints=problem.constraints,
        starter_code=problem.starter_code or {},
        lesson_content=problem.lesson_content,
        test_cases=[
            TestCaseResponse(
                input=tc.input if not tc.is_hidden else "hidden",
                expected_output=tc.expected_output if not tc.is_hidden else "hidden",
                is_hidden=tc.is_hidden,
            )
            for tc in test_cases
        ],
    )


@router.get("/categories/all", response_model=list[CategoryResponse])
async def list_categories(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Category).order_by(Category.order_index))
    categories = result.scalars().all()
    log.info("list_categories returning %d categories", len(categories))
    return [
        CategoryResponse(
            id=str(c.id),
            name=c.name,
            slug=c.slug,
            icon=c.icon,
            order_index=c.order_index,
        )
        for c in categories
    ]
