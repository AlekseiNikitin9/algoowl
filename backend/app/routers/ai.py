"""AI tutoring endpoint - Gemini-powered Socratic chat."""

import json
import re
from typing import Literal

import httpx
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from ..config import settings
from ..models.user import User
from ..services.auth_service import get_current_user
from ..utils.logging import get_logger
from ..utils.redis import get_redis

router = APIRouter(prefix="/ai", tags=["ai"])
log = get_logger("ai")

# ---------------------------------------------------------------------------
# Prompt injection detection
# ---------------------------------------------------------------------------

_INJECTION_PATTERNS = [
    re.compile(r"ignore\s+(previous|all|above|your)\s+instructions?", re.I),
    re.compile(r"(forget|disregard|override)\s+.{0,30}\s*instructions?", re.I),
    re.compile(r"you\s+are\s+now\b", re.I),
    re.compile(r"\bpretend\s+(to\s+be|you(\s+are)?)\b", re.I),
    re.compile(r"\bact\s+as\s+(if\s+)?a\b", re.I),
    re.compile(r"system\s*prompt", re.I),
    re.compile(r"\bDAN\b"),
    re.compile(r"jailbreak", re.I),
    re.compile(r"reveal\s+.{0,20}\s+prompt", re.I),
    re.compile(r"new\s+instructions?\b", re.I),
]

# Patterns where someone is trying to extract the answer directly
_ANSWER_GRAB_PATTERNS = [
    re.compile(r"\bgive\s+(me\s+)?(the\s+)?(code|answer|solution)\b", re.I),
    re.compile(r"\b(show|tell)\s+(me\s+)?(the\s+)?(code|answer|solution)\b", re.I),
    re.compile(r"\bwrite\s+(the\s+)?(code|solution)\b", re.I),
    re.compile(r"\bwhat\s+is\s+the\s+(code|solution|answer)\b", re.I),
    re.compile(r"\bjust\s+(tell|give)\s+(me|the)\b", re.I),
]

_MAX_USER_MSG_CHARS = 600
_MAX_HISTORY_TURNS = 6   # keep last 3 pairs in Gemini context
_MAX_USER_MESSAGES = 10  # per-problem session cap
_SESSION_TTL = 600       # 10-minute cooldown window (seconds)


def _is_injection(text: str) -> bool:
    return any(p.search(text) for p in _INJECTION_PATTERNS)


def _is_answer_grab(text: str) -> bool:
    return any(p.search(text) for p in _ANSWER_GRAB_PATTERNS)


# ---------------------------------------------------------------------------
# System prompt
# ---------------------------------------------------------------------------

_SYSTEM_PROMPT = """\
You are a warm, Socratic coding tutor inside Codekata - a Duolingo-like DSA learning app.
The student is working on this problem:

Problem: {title}
Description: {description}

YOUR ABSOLUTE RULES:
1. NEVER write code, pseudocode, or step-by-step algorithm instructions - not even a single line.
   If asked directly, reply: "My job is to help YOU figure it out - not hand you the answer!"
2. Ask only ONE guiding question per response to gently push their thinking forward.
3. Keep replies short: 2-4 sentences max.
4. Be warm and encouraging - celebrate small wins. Think Duolingo, not a stern professor.
5. If they mention the right data structure or approach, affirm it enthusiastically and nudge them to the next detail.
6. If they are wrong or stuck, ask a smaller, more targeted question to break the problem down.
7. Goal: guide them to their own "AHA!" moment. Never rob them of that discovery.

RESPONSE FORMAT - you MUST always return valid JSON with exactly these two fields:
{{"reply": "<your 2-4 sentence Socratic response>", "approach_unlocked": <true or false>}}

Set approach_unlocked to true ONLY when the student has clearly and correctly identified
the core algorithm or data structure needed to solve this specific problem.
Set it to false if there is any vagueness, partial understanding, or doubt.\
"""


# ---------------------------------------------------------------------------
# Request / response schemas
# ---------------------------------------------------------------------------


class ComplexityRequest(BaseModel):
    code: str = Field(..., min_length=1, max_length=4000)
    language: str = Field(..., max_length=20)


class ComplexityResponse(BaseModel):
    time: str
    space: str


class ChatMessage(BaseModel):
    role: Literal["user", "model"]
    text: str = Field(..., max_length=800)


class ChatRequest(BaseModel):
    problem_slug: str = Field(..., max_length=200)
    problem_title: str = Field(..., max_length=200)
    problem_description: str = Field(..., max_length=800)
    # Conversation so far (not including new_message) — trimmed server-side
    messages: list[ChatMessage] = Field(default=[])
    new_message: str = Field(..., min_length=1, max_length=_MAX_USER_MSG_CHARS)


class ChatResponse(BaseModel):
    reply: str
    refused: bool = False
    approach_unlocked: bool = False
    limit_exceeded: bool = False
    messages_remaining: int = _MAX_USER_MESSAGES


# ---------------------------------------------------------------------------
# Route
# ---------------------------------------------------------------------------

_GEMINI_MODEL = "gemini-2.5-flash-lite"
_GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta/models"


@router.post("/chat", response_model=ChatResponse)
async def chat(
    body: ChatRequest,
    _user: User = Depends(get_current_user),
) -> ChatResponse:
    """Socratic AI tutor — unlocks coding when student demonstrates the right approach."""

    # Sanitize & gate
    user_text = body.new_message.strip()
    log.info("ai/chat user=%s problem=%r msg_len=%d", _user.id, body.problem_title, len(user_text))

    if _is_injection(user_text):
        log.warning("ai/chat INJECTION_BLOCKED user=%s", _user.id)
        return ChatResponse(
            reply="Ha, nice try! Let's keep focused - what's your thinking on the algorithm?",
            refused=True,
        )

    if _is_answer_grab(user_text):
        log.warning("ai/chat ANSWER_GRAB_BLOCKED user=%s", _user.id)
        return ChatResponse(
            reply="My job is to help YOU figure it out, not hand you the answer! "
                  "What part are you stuck on?",
            refused=True,
        )

    # Per-problem session rate limit
    r = await get_redis()
    session_key = f"ai_session:{_user.id}:{body.problem_slug}"
    raw = await r.get(session_key)
    current_count = int(raw) if raw else 0

    if current_count >= _MAX_USER_MESSAGES:
        log.info("ai/chat LIMIT_EXCEEDED user=%s problem=%s", _user.id, body.problem_slug)
        return ChatResponse(
            reply=(
                "You've reached the message limit for this problem right now. "
                "No worries — sometimes the best way to learn is to just start coding. "
                "Give it a shot!"
            ),
            limit_exceeded=True,
            messages_remaining=0,
        )

    new_count = await r.incr(session_key)
    if new_count == 1:
        await r.expire(session_key, _SESSION_TTL)
    remaining = max(0, _MAX_USER_MESSAGES - new_count)
    log.info("ai/chat user=%s problem=%s msg=%d/%d", _user.id, body.problem_slug, new_count, _MAX_USER_MESSAGES)

    if not settings.gemini_api_key or settings.gemini_api_key in ("placeholder", ""):
        log.warning("ai/chat GEMINI_KEY_MISSING")
        return ChatResponse(
            reply="(AI tutor not configured - set GEMINI_API_KEY in .env) "
                  "Hint: think about what data structure lets you look up a value in O(1) time.",
            messages_remaining=remaining,
        )

    # Build system prompt
    system_text = _SYSTEM_PROMPT.format(
        title=body.problem_title[:200],
        description=body.problem_description[:600],
    )

    # Build conversation history (trimmed to recent turns)
    history = body.messages[-_MAX_HISTORY_TURNS:]
    contents = [
        {"role": m.role, "parts": [{"text": m.text[:800]}]}
        for m in history
    ]

    contents.append({
        "role": "user",
        "parts": [{"text": user_text}],
    })

    payload = {
        "system_instruction": {
            "parts": [{"text": system_text}],
        },
        "contents": contents,
        "generationConfig": {
            "maxOutputTokens": 300,
            "temperature": 0.75,
            "topP": 0.92,
            "responseMimeType": "application/json",
            "responseSchema": {
                "type": "object",
                "properties": {
                    "reply": {"type": "string"},
                    "approach_unlocked": {"type": "boolean"},
                },
                "required": ["reply", "approach_unlocked"],
            },
        },
        "safetySettings": [
            {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
            {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
        ],
    }

    url = f"{_GEMINI_BASE}/{_GEMINI_MODEL}:generateContent"

    try:
        async with httpx.AsyncClient(timeout=20) as client:
            resp = await client.post(
                url,
                json=payload,
                params={"key": settings.gemini_api_key},
            )
    except httpx.TimeoutException:
        raise HTTPException(504, "AI tutor timed out - please try again")
    except httpx.RequestError as exc:
        raise HTTPException(502, f"AI service unreachable: {exc}")

    if resp.status_code != 200:
        log.error("ai/chat GEMINI_ERROR status=%d body=%s", resp.status_code, resp.text[:200])
        return ChatResponse(
            reply="The AI tutor is temporarily unavailable — Google's servers are under high demand. "
                  "Try again in a moment, or skip ahead to the code editor!",
            messages_remaining=remaining,
        )

    data = resp.json()
    try:
        raw = data["candidates"][0]["content"]["parts"][0]["text"].strip()
        parsed = json.loads(raw)
        reply = str(parsed["reply"]).strip()
        approach_unlocked = bool(parsed.get("approach_unlocked", False))
    except (KeyError, IndexError, json.JSONDecodeError, ValueError) as exc:
        log.error("ai/chat GEMINI_BAD_RESPONSE exc=%s data=%s", exc, str(data)[:300])
        return ChatResponse(
            reply="The AI tutor couldn't generate a response right now. "
                  "Try again or skip ahead to the code editor!",
            messages_remaining=remaining,
        )

    log.info("ai/chat OK reply_len=%d approach_unlocked=%s", len(reply), approach_unlocked)

    # Hard safety: strip any code blocks the model might have snuck in
    reply = re.sub(r"```[\s\S]*?```", "[code removed]", reply)
    reply = re.sub(r"`[^`\n]{1,60}`", lambda m: m.group(), reply)

    return ChatResponse(reply=reply, approach_unlocked=approach_unlocked, messages_remaining=remaining)


_COMPLEXITY_PROMPT = """\
Analyze this {language} code and return ONLY a JSON object with the time and space complexity.
Format: {{"time": "O(...)", "space": "O(...)"}}
Use standard Big-O notation. No explanation, no markdown — just the JSON.

Code:
{code}
"""


@router.post("/complexity", response_model=ComplexityResponse)
async def analyze_complexity(
    body: ComplexityRequest,
    _user: User = Depends(get_current_user),
) -> ComplexityResponse:
    """Analyze time and space complexity of submitted code using Gemini."""

    if not settings.gemini_api_key or settings.gemini_api_key in ("placeholder", ""):
        return ComplexityResponse(time="O(n)", space="O(n)")

    prompt = _COMPLEXITY_PROMPT.format(
        language=body.language,
        code=body.code[:3000],
    )

    payload = {
        "contents": [{"role": "user", "parts": [{"text": prompt}]}],
        "generationConfig": {"maxOutputTokens": 60, "temperature": 0.1},
    }

    url = f"{_GEMINI_BASE}/{_GEMINI_MODEL}:generateContent"
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            resp = await client.post(url, json=payload, params={"key": settings.gemini_api_key})
    except (httpx.TimeoutException, httpx.RequestError):
        return ComplexityResponse(time="O(n)", space="O(1)")

    if resp.status_code != 200:
        log.warning("ai/complexity GEMINI_ERROR status=%d", resp.status_code)
        return ComplexityResponse(time="O(n)", space="O(1)")

    try:
        raw = resp.json()["candidates"][0]["content"]["parts"][0]["text"].strip()
        raw = re.sub(r"```[^\n]*\n?", "", raw).strip()
        data = __import__("json").loads(raw)
        return ComplexityResponse(
            time=str(data.get("time", "O(n)"))[:20],
            space=str(data.get("space", "O(1)"))[:20],
        )
    except Exception:
        log.warning("ai/complexity BAD_RESPONSE raw=%s", resp.text[:200])
        return ComplexityResponse(time="O(n)", space="O(1)")
