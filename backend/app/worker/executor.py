"""Docker container executor — runs user code in isolated sandbox containers."""

import json
import subprocess
import time
import re
from typing import Any


# Language → Docker image mapping
LANGUAGE_IMAGES = {
    "python": "algoowl-exec-python",
    "javascript": "algoowl-exec-javascript",
}

# Function name extraction patterns
FUNCTION_PATTERNS = {
    "python": r"def\s+(\w+)\s*\(",
    "javascript": r"function\s+(\w+)\s*\(|(?:const|let|var)\s+(\w+)\s*=",
}

# Timeout for code execution (seconds)
EXEC_TIMEOUT = 5
# Memory limit for sandbox containers
MEMORY_LIMIT = "256m"
# CPU limit
CPU_LIMIT = "0.5"
# Max PIDs
PIDS_LIMIT = 50
# Tmpfs size
TMPFS_SIZE = "50m"


def detect_function_name(code: str, language: str) -> str:
    """Extract the main function name from user code."""
    pattern = FUNCTION_PATTERNS.get(language)
    if not pattern:
        return "solution"

    match = re.search(pattern, code)
    if match:
        # For JS, function name could be in group 1 or group 2
        return match.group(1) or (match.group(2) if match.lastindex >= 2 else "solution")
    return "solution"


def run_in_container(
    language: str,
    code: str,
    test_cases: list[dict],
) -> dict[str, Any]:
    """
    Run user code in a Docker sandbox container.

    Returns dict with:
        status: accepted | wrong_answer | runtime_error | time_limit
        test_results: list of {input, expected, actual, passed}
        runtime_ms: execution time
        memory_mb: estimated memory usage
        error: error message or None
    """
    image = LANGUAGE_IMAGES.get(language)
    if not image:
        return {
            "status": "runtime_error",
            "test_results": [],
            "runtime_ms": 0,
            "memory_mb": 0,
            "error": f"Unsupported language: {language}",
        }

    func_name = detect_function_name(code, language)

    # Prepare payload for the runner
    payload = json.dumps({
        "code": code,
        "test_cases": test_cases,
        "function_name": func_name,
    })

    # Docker run command with security constraints
    docker_cmd = [
        "docker", "run",
        "--rm",                              # Remove container after exit
        "--network=none",                    # No network access
        "--read-only",                       # Read-only filesystem
        "--tmpfs", f"/tmp:size={TMPFS_SIZE},noexec",  # Writable /tmp with size limit
        f"--memory={MEMORY_LIMIT}",          # Memory limit
        f"--cpus={CPU_LIMIT}",               # CPU limit
        f"--pids-limit={PIDS_LIMIT}",        # Fork bomb protection
        "--security-opt=no-new-privileges",  # No privilege escalation
        "-i",                                # Read from stdin
        image,
    ]

    start_time = time.monotonic()

    try:
        proc = subprocess.run(
            docker_cmd,
            input=payload,
            capture_output=True,
            text=True,
            timeout=EXEC_TIMEOUT + 2,  # Slight buffer over container timeout
        )
        elapsed_ms = int((time.monotonic() - start_time) * 1000)

        if proc.returncode != 0:
            stderr = proc.stderr.strip()
            # Check if it was an OOM kill
            if "killed" in stderr.lower() or proc.returncode == 137:
                return {
                    "status": "runtime_error",
                    "test_results": [],
                    "runtime_ms": elapsed_ms,
                    "memory_mb": 256,
                    "error": "Process killed: exceeded memory limit",
                }
            return {
                "status": "runtime_error",
                "test_results": [],
                "runtime_ms": elapsed_ms,
                "memory_mb": 0,
                "error": stderr[:500] if stderr else "Unknown execution error",
            }

        # Parse runner output
        stdout = proc.stdout.strip()
        if not stdout:
            return {
                "status": "runtime_error",
                "test_results": [],
                "runtime_ms": elapsed_ms,
                "memory_mb": 0,
                "error": "No output from execution",
            }

        result = json.loads(stdout)
        result["runtime_ms"] = elapsed_ms
        result["memory_mb"] = 0  # TODO: parse from docker stats if needed

        return result

    except subprocess.TimeoutExpired:
        elapsed_ms = int((time.monotonic() - start_time) * 1000)
        return {
            "status": "time_limit",
            "test_results": [],
            "runtime_ms": elapsed_ms,
            "memory_mb": 0,
            "error": f"Time limit exceeded ({EXEC_TIMEOUT}s)",
        }
    except json.JSONDecodeError as e:
        return {
            "status": "runtime_error",
            "test_results": [],
            "runtime_ms": int((time.monotonic() - start_time) * 1000),
            "memory_mb": 0,
            "error": f"Failed to parse execution output: {e}",
        }
    except Exception as e:
        return {
            "status": "runtime_error",
            "test_results": [],
            "runtime_ms": 0,
            "memory_mb": 0,
            "error": f"Executor error: {e}",
        }
