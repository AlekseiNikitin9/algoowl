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
    "error": null | "error message",
    "stdout": "any print() output from user code"
}
"""

import contextlib
import io
import json
import resource
import sys
import traceback


def set_resource_limits():
    """Restrict memory and CPU at the process level."""
    mem_limit = 256 * 1024 * 1024
    resource.setrlimit(resource.RLIMIT_AS, (mem_limit, mem_limit))
    resource.setrlimit(resource.RLIMIT_NPROC, (0, 0))
    resource.setrlimit(resource.RLIMIT_FSIZE, (1024 * 1024, 1024 * 1024))


def normalize_output(val) -> str:
    if isinstance(val, bool):
        return "true" if val else "false"
    if isinstance(val, list):
        return json.dumps(val, separators=(",", ":"))
    if val is None:
        return "null"
    return str(val)


def parse_expected(expected: str) -> str:
    expected = expected.strip()
    try:
        parsed = json.loads(expected)
        return normalize_output(parsed)
    except (json.JSONDecodeError, ValueError):
        return expected


def run_test_case(user_globals: dict, func_name: str, test_input: str) -> str:
    call_expr = f"{func_name}({test_input})"
    result = eval(call_expr, user_globals)
    return normalize_output(result)


def _emit(status, results, error, stdout_text):
    # Truncate stdout to 2000 chars so we don't blow up the response
    stdout_out = stdout_text[:2000] if stdout_text else None
    print(json.dumps({
        "status": status,
        "test_results": results,
        "error": error,
        "stdout": stdout_out,
    }))


def main():
    set_resource_limits()

    payload = json.loads(sys.stdin.read())
    code = payload["code"]
    test_cases = payload["test_cases"]
    func_name = payload.get("function_name", "solution")

    results = []
    overall_status = "accepted"
    error_msg = None
    stdout_capture = io.StringIO()

    # Compile + exec user code (defines the function, may also run top-level prints)
    try:
        user_globals = {"__builtins__": __builtins__}
        with contextlib.redirect_stdout(stdout_capture):
            exec(compile(code, "<user_code>", "exec"), user_globals)
    except Exception as e:
        error_msg = f"{type(e).__name__}: {e}"
        overall_status = "runtime_error"
        for tc in test_cases:
            results.append({
                "input": tc["input"],
                "expected": tc["expected_output"],
                "actual": None,
                "passed": False,
            })
        _emit(overall_status, results, error_msg, stdout_capture.getvalue())
        return

    # Run each test case, capturing stdout across all runs
    for tc in test_cases:
        test_input = tc["input"]
        expected = parse_expected(tc["expected_output"])

        try:
            with contextlib.redirect_stdout(stdout_capture):
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

    _emit(overall_status, results, error_msg, stdout_capture.getvalue())


if __name__ == "__main__":
    main()
