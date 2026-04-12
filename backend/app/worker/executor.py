"""Executor — sends code to a persistent sandbox service over HTTP.

Instead of spinning up a fresh Docker container per submission (slow cold-start),
each language has a long-running service that processes requests in isolated
subprocesses.
"""

import json
import re
import time
from typing import Any

import httpx


# Language → sandbox service URL (within the Docker Compose network)
LANGUAGE_URLS = {
    "python": "http://exec-python:8001",
    # "javascript": "http://exec-javascript:8001",  # add when ready
}

# Function name extraction patterns
FUNCTION_PATTERNS = {
    "python": r"def\s+(\w+)\s*\(",
    "javascript": r"function\s+(\w+)\s*\(|(?:const|let|var)\s+(\w+)\s*=",
}

EXEC_TIMEOUT = 10  # seconds — generous since the sandbox enforces its own 5s limit


def detect_function_name(code: str, language: str) -> str:
    pattern = FUNCTION_PATTERNS.get(language)
    if not pattern:
        return "solution"
    match = re.search(pattern, code)
    if match:
        return match.group(1) or (match.group(2) if match.lastindex and match.lastindex >= 2 else "solution")
    return "solution"


def run_in_container(
    language: str,
    code: str,
    test_cases: list[dict],
) -> dict[str, Any]:
    """
    Send code to the persistent sandbox and return execution results.

    Returns dict with:
        status: accepted | wrong_answer | runtime_error | time_limit
        test_results: list of {input, expected, actual, passed}
        runtime_ms: wall-clock time in ms
        memory_mb: 0 (not tracked in persistent mode)
        error: error message or None
    """
    url = LANGUAGE_URLS.get(language)
    if not url:
        return {
            "status": "runtime_error",
            "test_results": [],
            "runtime_ms": 0,
            "memory_mb": 0,
            "error": f"Unsupported language: {language}",
        }

    payload = {
        "code": code,
        "test_cases": test_cases,
        "function_name": detect_function_name(code, language),
    }

    start = time.monotonic()

    try:
        response = httpx.post(
            f"{url}/",
            json=payload,
            timeout=EXEC_TIMEOUT,
        )
        elapsed_ms = int((time.monotonic() - start) * 1000)

        result = response.json()
        result["runtime_ms"] = elapsed_ms
        result.setdefault("memory_mb", 0)
        return result

    except httpx.TimeoutException:
        elapsed_ms = int((time.monotonic() - start) * 1000)
        return {
            "status": "time_limit",
            "test_results": [],
            "runtime_ms": elapsed_ms,
            "memory_mb": 0,
            "error": f"Time limit exceeded ({EXEC_TIMEOUT}s)",
        }
    except httpx.ConnectError as e:
        return {
            "status": "runtime_error",
            "test_results": [],
            "runtime_ms": 0,
            "memory_mb": 0,
            "error": f"Sandbox unreachable: {e}",
        }
    except Exception as e:
        return {
            "status": "runtime_error",
            "test_results": [],
            "runtime_ms": 0,
            "memory_mb": 0,
            "error": f"Executor error: {e}",
        }
