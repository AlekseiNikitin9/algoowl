"""Seed categories + problems for MVP.

Run inside the API container:
    python -m scripts.seed
"""

import asyncio
import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import async_session, engine, Base
from app.models.problem import Category, Lesson, Problem, TestCase


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


# ── Problems (MVP: first 3 categories) ────────────────────

PROBLEMS = [
    # ── Arrays & Strings ──
    {
        "title": "Two Sum",
        "slug": "two-sum",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.",
        "constraints": "2 ≤ nums.length ≤ 10⁴\n-10⁹ ≤ nums[i] ≤ 10⁹\nExactly one solution exists.",
        "starter_code": {
            "python": "def two_sum(nums, target):\n    # your code here\n    pass",
            "javascript": "function twoSum(nums, target) {\n    // your code here\n}",
        },
        "order_index": 0,
        "test_cases": [
            {"input": "[2,7,11,15], target=9", "expected_output": "[0,1]", "is_hidden": False},
            {"input": "[3,2,4], target=6", "expected_output": "[1,2]", "is_hidden": False},
            {"input": "[3,3], target=6", "expected_output": "[0,1]", "is_hidden": True},
        ],
    },
    {
        "title": "Best Time to Buy and Sell Stock",
        "slug": "best-time-buy-sell-stock",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Given an array prices where prices[i] is the price of a stock on the ith day, return the maximum profit you can achieve. You may choose a single day to buy and a single day to sell.",
        "constraints": "1 ≤ prices.length ≤ 10⁵\n0 ≤ prices[i] ≤ 10⁴",
        "starter_code": {
            "python": "def max_profit(prices):\n    # your code here\n    pass",
            "javascript": "function maxProfit(prices) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": "[7,1,5,3,6,4]", "expected_output": "5", "is_hidden": False},
            {"input": "[7,6,4,3,1]", "expected_output": "0", "is_hidden": False},
            {"input": "[2,4,1]", "expected_output": "2", "is_hidden": True},
        ],
    },
    {
        "title": "Maximum Subarray",
        "slug": "maximum-subarray",
        "category_slug": "arrays-strings",
        "difficulty": "medium",
        "description": "Given an integer array nums, find the subarray with the largest sum, and return its sum.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\n-10⁴ ≤ nums[i] ≤ 10⁴",
        "starter_code": {
            "python": "def max_sub_array(nums):\n    # your code here\n    pass",
            "javascript": "function maxSubArray(nums) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[-2,1,-3,4,-1,2,1,-5,4]", "expected_output": "6", "is_hidden": False},
            {"input": "[1]", "expected_output": "1", "is_hidden": False},
            {"input": "[5,4,-1,7,8]", "expected_output": "23", "is_hidden": True},
        ],
    },
    {
        "title": "Product of Array Except Self",
        "slug": "product-of-array-except-self",
        "category_slug": "arrays-strings",
        "difficulty": "medium",
        "description": "Given an integer array nums, return an array answer such that answer[i] is equal to the product of all elements of nums except nums[i]. You must solve it in O(n) time without using division.",
        "constraints": "2 ≤ nums.length ≤ 10⁵\n-30 ≤ nums[i] ≤ 30",
        "starter_code": {
            "python": "def product_except_self(nums):\n    # your code here\n    pass",
            "javascript": "function productExceptSelf(nums) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[1,2,3,4]", "expected_output": "[24,12,8,6]", "is_hidden": False},
            {"input": "[-1,1,0,-3,3]", "expected_output": "[0,0,9,0,0]", "is_hidden": False},
            {"input": "[2,3]", "expected_output": "[3,2]", "is_hidden": True},
        ],
    },
    {
        "title": "Valid Palindrome",
        "slug": "valid-palindrome",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Given a string s, return true if it is a palindrome after converting all uppercase letters to lowercase and removing all non-alphanumeric characters.",
        "constraints": "1 ≤ s.length ≤ 2 × 10⁵",
        "starter_code": {
            "python": "def is_palindrome(s):\n    # your code here\n    pass",
            "javascript": "function isPalindrome(s) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": '"A man, a plan, a canal: Panama"', "expected_output": "true", "is_hidden": False},
            {"input": '"race a car"', "expected_output": "false", "is_hidden": False},
            {"input": '" "', "expected_output": "true", "is_hidden": True},
        ],
    },

    # ── Hashing ──
    {
        "title": "Contains Duplicate",
        "slug": "contains-duplicate",
        "category_slug": "hashing",
        "difficulty": "easy",
        "description": "Given an integer array nums, return true if any value appears at least twice in the array.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\n-10⁹ ≤ nums[i] ≤ 10⁹",
        "starter_code": {
            "python": "def contains_duplicate(nums):\n    # your code here\n    pass",
            "javascript": "function containsDuplicate(nums) {\n    // your code here\n}",
        },
        "order_index": 0,
        "test_cases": [
            {"input": "[1,2,3,1]", "expected_output": "true", "is_hidden": False},
            {"input": "[1,2,3,4]", "expected_output": "false", "is_hidden": False},
            {"input": "[1,1,1,3,3,4,3,2,4,2]", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Valid Anagram",
        "slug": "valid-anagram",
        "category_slug": "hashing",
        "difficulty": "easy",
        "description": "Given two strings s and t, return true if t is an anagram of s, and false otherwise.",
        "constraints": "1 ≤ s.length, t.length ≤ 5 × 10⁴\ns and t consist of lowercase English letters.",
        "starter_code": {
            "python": "def is_anagram(s, t):\n    # your code here\n    pass",
            "javascript": "function isAnagram(s, t) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": 's="anagram", t="nagaram"', "expected_output": "true", "is_hidden": False},
            {"input": 's="rat", t="car"', "expected_output": "false", "is_hidden": False},
            {"input": 's="a", t="a"', "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Group Anagrams",
        "slug": "group-anagrams",
        "category_slug": "hashing",
        "difficulty": "medium",
        "description": "Given an array of strings strs, group the anagrams together. You can return the answer in any order.",
        "constraints": "1 ≤ strs.length ≤ 10⁴\n0 ≤ strs[i].length ≤ 100",
        "starter_code": {
            "python": "def group_anagrams(strs):\n    # your code here\n    pass",
            "javascript": "function groupAnagrams(strs) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": '["eat","tea","tan","ate","nat","bat"]', "expected_output": '[["bat"],["nat","tan"],["ate","eat","tea"]]', "is_hidden": False},
            {"input": '[""]', "expected_output": '[[""]]', "is_hidden": False},
            {"input": '["a"]', "expected_output": '[["a"]]', "is_hidden": True},
        ],
    },
    {
        "title": "Top K Frequent Elements",
        "slug": "top-k-frequent",
        "category_slug": "hashing",
        "difficulty": "medium",
        "description": "Given an integer array nums and an integer k, return the k most frequent elements. You may return the answer in any order.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\n-10⁴ ≤ nums[i] ≤ 10⁴\n1 ≤ k ≤ number of unique elements",
        "starter_code": {
            "python": "def top_k_frequent(nums, k):\n    # your code here\n    pass",
            "javascript": "function topKFrequent(nums, k) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[1,1,1,2,2,3], k=2", "expected_output": "[1,2]", "is_hidden": False},
            {"input": "[1], k=1", "expected_output": "[1]", "is_hidden": False},
            {"input": "[4,1,-1,2,-1,2,3], k=2", "expected_output": "[-1,2]", "is_hidden": True},
        ],
    },

    # ── Two Pointers ──
    {
        "title": "Valid Palindrome II",
        "slug": "valid-palindrome-ii",
        "category_slug": "two-pointers",
        "difficulty": "easy",
        "description": "Given a string s, return true if the s can be a palindrome after deleting at most one character from it.",
        "constraints": "1 ≤ s.length ≤ 10⁵\ns consists of lowercase English letters.",
        "starter_code": {
            "python": "def valid_palindrome(s):\n    # your code here\n    pass",
            "javascript": "function validPalindrome(s) {\n    // your code here\n}",
        },
        "order_index": 0,
        "test_cases": [
            {"input": '"aba"', "expected_output": "true", "is_hidden": False},
            {"input": '"abca"', "expected_output": "true", "is_hidden": False},
            {"input": '"abc"', "expected_output": "false", "is_hidden": True},
        ],
    },
    {
        "title": "Two Sum II - Sorted Array",
        "slug": "two-sum-ii",
        "category_slug": "two-pointers",
        "difficulty": "medium",
        "description": "Given a 1-indexed sorted array numbers, find two numbers such that they add up to target. Return the indices of the two numbers (1-indexed).",
        "constraints": "2 ≤ numbers.length ≤ 3 × 10⁴\n-1000 ≤ numbers[i] ≤ 1000\n-1000 ≤ target ≤ 1000",
        "starter_code": {
            "python": "def two_sum_sorted(numbers, target):\n    # your code here\n    pass",
            "javascript": "function twoSum(numbers, target) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": "[2,7,11,15], target=9", "expected_output": "[1,2]", "is_hidden": False},
            {"input": "[2,3,4], target=6", "expected_output": "[1,3]", "is_hidden": False},
            {"input": "[-1,0], target=-1", "expected_output": "[1,2]", "is_hidden": True},
        ],
    },
    {
        "title": "3Sum",
        "slug": "three-sum",
        "category_slug": "two-pointers",
        "difficulty": "medium",
        "description": "Given an integer array nums, return all the triplets [nums[i], nums[j], nums[k]] such that i ≠ j ≠ k and nums[i] + nums[j] + nums[k] == 0. The solution set must not contain duplicate triplets.",
        "constraints": "3 ≤ nums.length ≤ 3000\n-10⁵ ≤ nums[i] ≤ 10⁵",
        "starter_code": {
            "python": "def three_sum(nums):\n    # your code here\n    pass",
            "javascript": "function threeSum(nums) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[-1,0,1,2,-1,-4]", "expected_output": "[[-1,-1,2],[-1,0,1]]", "is_hidden": False},
            {"input": "[0,1,1]", "expected_output": "[]", "is_hidden": False},
            {"input": "[0,0,0]", "expected_output": "[[0,0,0]]", "is_hidden": True},
        ],
    },
    {
        "title": "Container With Most Water",
        "slug": "container-most-water",
        "category_slug": "two-pointers",
        "difficulty": "medium",
        "description": "Given n non-negative integers a1, a2, ..., an where each represents a point at coordinate (i, ai), find two lines that together with the x-axis form a container that holds the most water.",
        "constraints": "2 ≤ height.length ≤ 10⁵\n0 ≤ height[i] ≤ 10⁴",
        "starter_code": {
            "python": "def max_area(height):\n    # your code here\n    pass",
            "javascript": "function maxArea(height) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[1,8,6,2,5,4,8,3,7]", "expected_output": "49", "is_hidden": False},
            {"input": "[1,1]", "expected_output": "1", "is_hidden": False},
            {"input": "[4,3,2,1,4]", "expected_output": "16", "is_hidden": True},
        ],
    },
]


async def seed():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with async_session() as db:
        # Check if already seeded
        result = await db.execute(select(Category))
        if result.scalars().first():
            print("⚠ Database already seeded, skipping.")
            return

        # Insert categories
        cat_map: dict[str, uuid.UUID] = {}
        for cat_data in CATEGORIES:
            cat = Category(**cat_data)
            db.add(cat)
            await db.flush()
            cat_map[cat.slug] = cat.id

        print(f"✓ Seeded {len(CATEGORIES)} categories")

        # Insert problems + test cases
        problem_count = 0
        tc_count = 0
        for p_data in PROBLEMS:
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
        print(f"✓ Seeded {problem_count} problems with {tc_count} test cases")


if __name__ == "__main__":
    asyncio.run(seed())
