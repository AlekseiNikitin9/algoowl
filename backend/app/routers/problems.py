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

router = APIRouter(prefix="/problems", tags=["problems"])


@router.get("", response_model=list[ProblemListItem])
async def list_problems(
    category: str | None = Query(None),
    difficulty: str | None = Query(None),
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
):
    query = select(Problem).order_by(Problem.order_index)

    if category:
        # Join category by slug
        cat_result = await db.execute(
            select(Category.id).where(Category.slug == category)
        )
        cat_id = cat_result.scalar_one_or_none()
        if cat_id:
            query = query.where(Problem.category_id == cat_id)

    if difficulty:
        query = query.where(Problem.difficulty == difficulty)

    query = query.offset((page - 1) * per_page).limit(per_page)
    result = await db.execute(query)
    problems = result.scalars().all()

    return [
        ProblemListItem(
            id=str(p.id),
            title=p.title,
            slug=p.slug,
            difficulty=p.difficulty,
            category_id=str(p.category_id),
        )
        for p in problems
    ]


@router.get("/{slug}", response_model=ProblemResponse)
async def get_problem(slug: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Problem).where(Problem.slug == slug))
    problem = result.scalar_one_or_none()

    if not problem:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Problem not found",
        )

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
        difficulty=problem.difficulty,
        description=problem.description,
        constraints=problem.constraints,
        starter_code=problem.starter_code or {},
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
