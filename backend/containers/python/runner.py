"""Persistent HTTP server inside the exec-python container.

Listens on :8001 and dispatches each submission to execute.py in a
fresh subprocess — gives isolation without the cold-start cost of
spinning up a new container per request.
"""

import json
import logging
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [runner] %(levelname)s: %(message)s",
    stream=sys.stdout,
)
log = logging.getLogger("runner")

EXECUTE_SCRIPT = "/opt/execute.py"
TIMEOUT_SECONDS = 7  # slightly over the 5s limit enforced inside execute.py


class RunHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        payload = self.rfile.read(length)
        log.info("Received execution request (%d bytes)", length)

        result = _run(payload)
        status = result.get("status", "unknown")
        log.info("Execution result: status=%s", status)

        body = json.dumps(result).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


def _run(payload_bytes: bytes) -> dict:
    try:
        proc = subprocess.run(
            [sys.executable, EXECUTE_SCRIPT],
            input=payload_bytes.decode(),
            capture_output=True,
            text=True,
            timeout=TIMEOUT_SECONDS,
        )
        if proc.returncode == 0 and proc.stdout.strip():
            return json.loads(proc.stdout)
        log.error("execute.py failed rc=%d stderr=%s", proc.returncode, proc.stderr[:200])
        return {
            "status": "runtime_error",
            "test_results": [],
            "error": proc.stderr[:500] or "Execution failed (no output)",
        }
    except subprocess.TimeoutExpired:
        log.warning("Subprocess timed out after %ds", TIMEOUT_SECONDS)
        return {
            "status": "time_limit",
            "test_results": [],
            "error": "Time limit exceeded (5s)",
        }
    except Exception as e:
        log.exception("Unexpected runner error: %s", e)
        return {
            "status": "runtime_error",
            "test_results": [],
            "error": f"Runner error: {e}",
        }


if __name__ == "__main__":
    log.info("exec-python runner listening on :8001")
    HTTPServer(("0.0.0.0", 8001), RunHandler).serve_forever()
