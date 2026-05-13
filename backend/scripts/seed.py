"""Seed categories + problems for MVP.

Run inside the API container:
    python -m scripts.seed
"""

import asyncio
import logging
import sys
import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import async_session, engine, Base
from app.models.problem import Category, Lesson, Problem, TestCase
from scripts.problems_data import PROBLEMS as PROBLEMS_DATA

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [seed] %(levelname)s: %(message)s",
    stream=sys.stdout,
)
log = logging.getLogger("seed")


# ── Categories ─────────────────────────────────────────────

CATEGORIES = [
    {"name": "Arrays & Strings", "slug": "arrays-strings", "icon": "grid_on", "order_index": 0},
    {"name": "Hashing", "slug": "hashing", "icon": "tag", "order_index": 1},
    {"name": "Two Pointers", "slug": "two-pointers", "icon": "compare_arrows", "order_index": 2},
    {"name": "Sliding Window", "slug": "sliding-window", "icon": "view_carousel", "order_index": 3},
    {"name": "Stack & Queue", "slug": "stack-queue", "icon": "stacked_line_chart", "order_index": 4},
    {"name": "Binary Search", "slug": "binary-search", "icon": "search", "order_index": 5},
    {"name": "Linked Lists", "slug": "linked-lists", "icon": "link", "order_index": 6},
    {"name": "Trees", "slug": "trees", "icon": "account_tree", "order_index": 7},
    {"name": "Graphs", "slug": "graphs", "icon": "hub", "order_index": 8},
    {"name": "Dynamic Programming", "slug": "dynamic-programming", "icon": "table_chart", "order_index": 9},
    {"name": "Backtracking", "slug": "backtracking", "icon": "undo", "order_index": 10},
    {"name": "Heap / Priority Queue", "slug": "heap", "icon": "filter_list", "order_index": 11},
    {"name": "Tries", "slug": "tries", "icon": "lan", "order_index": 12},
    {"name": "Bit Manipulation", "slug": "bit-manipulation", "icon": "memory", "order_index": 13},
]


PROBLEMS = PROBLEMS_DATA


async def seed():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with async_session() as db:
        # Check if already seeded
        result = await db.execute(select(Category))
        if result.scalars().first():
            log.warning("Database already seeded, skipping.")
            return

        # Insert categories
        cat_map: dict[str, uuid.UUID] = {}
        for cat_data in CATEGORIES:
            cat = Category(**cat_data)
            db.add(cat)
            await db.flush()
            cat_map[cat.slug] = cat.id

        log.info("Seeded %d categories", len(CATEGORIES))

        # Insert problems + test cases
        problem_count = 0
        tc_count = 0
        for p_data in PROBLEMS:
            p_data = dict(p_data)
            cat_slug = p_data.pop("category_slug")
            test_cases_data = p_data.pop("test_cases")

            problem = Problem(
                category_id=cat_map[cat_slug],
                **p_data,
            )
            db.add(problem)
            await db.flush()
            problem_count += 1

            for idx, tc_data in enumerate(test_cases_data):
                tc = TestCase(
                    problem_id=problem.id,
                    order_index=idx,
                    **tc_data,
                )
                db.add(tc)
                tc_count += 1

        await db.commit()
        log.info("Seeded %d problems with %d test cases", problem_count, tc_count)


if __name__ == "__main__":
    asyncio.run(seed())
