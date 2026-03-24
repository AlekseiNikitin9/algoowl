"""Sandbox runner for Python user code.

Receives JSON on stdin:
{
    "code": "def two_sum(nums, target): ...",
    "test_cases": [
        {"input": "[2,7,11,15], target=9", "expected_output": "[0,1]"},
        ...
    ],
    "function_name": "two_sum"
}

Outputs JSON on stdout:
{
    "status": "accepted" | "wrong_answer" | "runtime_error",
    "test_results": [
        {"input": "...", "expected": "...", "actual": "...", "passed": true},
        ...
    ],
    "error": null | "error message"
}
"""

import json
import sys
import traceback
import time
import resource


def set_resource_limits():
    """Restrict memory and CPU at the process level."""
    # 256 MB memory limit
    mem_limit = 256 * 1024 * 1024
    resource.setrlimit(resource.RLIMIT_AS, (mem_limit, mem_limit))
    # No new processes
    resource.setrlimit(resource.RLIMIT_NPROC, (0, 0))
    # No file creation beyond 1MB
    resource.setrlimit(resource.RLIMIT_FSIZE, (1024 * 1024, 1024 * 1024))


def normalize_output(val) -> str:
    """Normalize a Python value to a comparable string."""
    if isinstance(val, bool):
        return "true" if val else "false"
    if isinstance(val, list):
        return json.dumps(val, separators=(",", ":"))
    if val is None:
        return "null"
    return str(val)


def parse_expected(expected: str) -> str:
    """Normalize expected output string for comparison."""
    expected = expected.strip()
    # Try parsing as JSON for consistent formatting
    try:
        parsed = json.loads(expected)
        return normalize_output(parsed)
    except (json.JSONDecodeError, ValueError):
        return expected


def run_test_case(user_globals: dict, func_name: str, test_input: str) -> str:
    """Execute a single test case. Returns the string output."""
    # Build the call expression
    # Input format: "arg1, arg2" or "[1,2,3], target=5"
    call_expr = f"{func_name}({test_input})"
    result = eval(call_expr, user_globals)
    return normalize_output(result)


def main():
    set_resource_limits()

    payload = json.loads(sys.stdin.read())
    code = payload["code"]
    test_cases = payload["test_cases"]
    func_name = payload.get("function_name", "solution")

    results = []
    overall_status = "accepted"
    error_msg = None

    # Compile + exec user code
    try:
        user_globals = {"__builtins__": __builtins__}
        exec(compile(code, "<user_code>", "exec"), user_globals)
    except Exception as e:
        # Code doesn't even compile/run
        error_msg = f"{type(e).__name__}: {e}"
        overall_status = "runtime_error"
        for tc in test_cases:
            results.append({
                "input": tc["input"],
                "expected": tc["expected_output"],
                "actual": None,
                "passed": False,
            })
        print(json.dumps({
            "status": overall_status,
            "test_results": results,
            "error": error_msg,
        }))
        return

    # Run each test case
    for tc in test_cases:
        test_input = tc["input"]
        expected = parse_expected(tc["expected_output"])

        try:
            actual = run_test_case(user_globals, func_name, test_input)
            passed = actual == expected
            if not passed:
                overall_status = "wrong_answer"
            results.append({
                "input": test_input,
                "expected": expected,
                "actual": actual,
                "passed": passed,
            })
        except MemoryError:
            overall_status = "runtime_error"
            error_msg = "MemoryError: solution exceeded memory limit"
            results.append({
                "input": test_input,
                "expected": expected,
                "actual": None,
                "passed": False,
            })
            break
        except Exception as e:
            overall_status = "runtime_error"
            error_msg = f"{type(e).__name__}: {e}"
            results.append({
                "input": test_input,
                "expected": expected,
                "actual": None,
                "passed": False,
            })

    print(json.dumps({
        "status": overall_status,
        "test_results": results,
        "error": error_msg,
    }))


if __name__ == "__main__":
    main()
