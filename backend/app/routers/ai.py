"""AI tutoring endpoint - Gemini-powered Socratic chat."""

import re
from typing import Literal

import httpx
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from ..config import settings
from ..models.user import User
from ..services.auth_service import get_current_user

router = APIRouter(prefix="/ai", tags=["ai"])

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
_MAX_HISTORY_TURNS = 6  # keep last 3 pairs in context


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
8. If this is marked [FINAL ROUND], wrap up warmly: summarize what they've figured out and send them to code with confidence.\
"""


# ---------------------------------------------------------------------------
# Request / response schemas
# ---------------------------------------------------------------------------


class ChatMessage(BaseModel):
    role: Literal["user", "model"]
    text: str = Field(..., max_length=800)


class ChatRequest(BaseModel):
    problem_title: str = Field(..., max_length=200)
    problem_description: str = Field(..., max_length=800)
    # Conversation so far (not including new_message)
    messages: list[ChatMessage] = Field(default=[], max_length=_MAX_HISTORY_TURNS)
    new_message: str = Field(..., min_length=1, max_length=_MAX_USER_MSG_CHARS)
    is_final_round: bool = False


class ChatResponse(BaseModel):
    reply: str
    refused: bool = False  # True when we blocked an injection / answer-grab


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
    """Socratic AI tutor - up to 3 exchanges per lesson step."""

    # Sanitize & gate
    user_text = body.new_message.strip()

    if _is_injection(user_text):
        return ChatResponse(
            reply="Ha, nice try! Let's keep focused - what's your thinking on the algorithm?",
            refused=True,
        )

    if _is_answer_grab(user_text):
        return ChatResponse(
            reply="My job is to help YOU figure it out, not hand you the answer! "
                  "What part are you stuck on?",
            refused=True,
        )

    if not settings.gemini_api_key or settings.gemini_api_key in ("placeholder", ""):
        return ChatResponse(
            reply="(AI tutor not configured - set GEMINI_API_KEY in .env) "
                  "Hint: think about what data structure lets you look up a value in O(1) time.",
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

    # Append the new user message, with final-round marker if needed
    final_marker = "\n\n[FINAL ROUND]" if body.is_final_round else ""
    contents.append({
        "role": "user",
        "parts": [{"text": user_text + final_marker}],
    })

    payload = {
        "system_instruction": {
            "parts": [{"text": system_text}],
        },
        "contents": contents,
        "generationConfig": {
            "maxOutputTokens": 200,
            "temperature": 0.75,
            "topP": 0.92,
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
        raise HTTPException(502, f"Gemini error {resp.status_code}: {resp.text[:200]}")

    data = resp.json()
    try:
        reply = data["candidates"][0]["content"]["parts"][0]["text"].strip()
    except (KeyError, IndexError):
        raise HTTPException(502, "Unexpected response from AI service")

    # Hard safety: strip any code blocks the model might have snuck in
    reply = re.sub(r"```[\s\S]*?```", "[code removed]", reply)
    reply = re.sub(r"`[^`\n]{1,60}`", lambda m: m.group(), reply)  # allow inline code references

    return ChatResponse(reply=reply)
