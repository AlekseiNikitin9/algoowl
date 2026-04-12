# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**AlgoOwl** (branded as **Codekata** in-app) is a Duolingo-inspired mobile DSA learning platform. It has two main components:
- **Flutter frontend** (`lib/`) — cross-platform app (iOS, Android, web)
- **FastAPI backend** (`backend/`) — async API with PostgreSQL + Redis + sandboxed code execution

## Commands

### Flutter Frontend

```bash
flutter pub get           # Install dependencies
flutter run               # Run on connected device/emulator
flutter run -d web-server --web-port=8080  # Run on web
flutter test              # Run tests
flutter analyze           # Lint
flutter build apk         # Build Android
flutter build ios         # Build iOS
flutter build web         # Build web

# Regenerate Riverpod providers after modifying annotated providers
dart run build_runner build --delete-conflicting-outputs
```

### Backend

```bash
cd backend
cp .env.example .env      # First-time setup; fill in secrets

docker-compose up --build # Start all 6 services (postgres, redis, api, worker, exec-*)
docker-compose down       # Stop all services

# Inside running api container or with venv:
alembic upgrade head                         # Apply DB migrations
alembic revision --autogenerate -m "desc"   # Create new migration
python scripts/seed.py                       # Seed categories + problems

# Health check
curl http://localhost:8000/health
# API docs: http://localhost:8000/docs
```

## Architecture

### Frontend (`lib/`)

Feature-based module structure. State via **Riverpod**, routing via **GoRouter**.

```
lib/
├── core/
│   ├── theme/          # AppTheme, colors, typography (Nunito + JetBrains Mono)
│   ├── widgets/        # Shared components (OwlButton, ProgressBar, skeletons)
│   └── services/
│       └── api_service.dart   # All API calls — currently returns mock data with 300ms delay
├── features/           # One directory per screen group
│   ├── onboarding/     # 4-step preference flow
│   ├── home/           # Skill tree + AppShell (bottom nav)
│   ├── lesson/         # Concept explanation → quiz
│   ├── code_editor/    # Smart autofill editor + execution results
│   ├── practice/       # Problem list filtered by category/difficulty
│   ├── leaderboard/    # Weekly XP ranking
│   └── profile/        # Settings, stats, logout
├── models/             # Dart data models (Category, Problem, UserProfile)
├── providers/          # app_providers.dart — Riverpod state
├── router/             # app_router.dart — GoRouter config, onboarding redirect
└── main.dart
```

Navigation flow: `/onboarding` (redirected if `onboarding_complete`) → `/` (AppShell) → `/lesson/:slug` → `/editor/:slug`.

**`api_service.dart` is the integration seam** — all backend wiring goes here.

### Backend (`backend/app/`)

Layered FastAPI app: router → service → ORM → DB/Redis.

```
app/
├── main.py             # App creation, lifespan (create tables, ping Redis), CORS, router mount
├── config.py           # Pydantic Settings reading from .env
├── database.py         # Async SQLAlchemy engine, get_db dependency
├── models/             # ORM tables: user, problem, submission, progress
├── schemas/            # Pydantic request/response models per domain
├── routers/            # Route handlers: auth, problems, submissions, progress
├── services/           # Business logic: auth_service, submission_service, progress_service, leaderboard_service
├── worker/
│   ├── main.py         # Redis job queue listener
│   └── executor.py     # Docker container management for code execution
└── utils/
    ├── security.py     # JWT encode/decode, bcrypt
    └── redis.py        # Redis helpers
```

**Auth:** JWT access tokens (15 min) + rotating refresh tokens (7 days) stored in Redis.

**Code execution:** Submissions enqueued to Redis → worker dequeues → spawns isolated Docker container (no network, read-only FS, 256MB RAM, 5s timeout) → result written back.

**Docker Compose stack:** `postgres`, `redis`, `api`, `exec-worker`, `exec-python`, `exec-javascript`.

### Database (8 tables)

`users`, `categories`, `lessons`, `problems`, `test_cases`, `submissions`, `user_progress`, `spaced_reps`, `refresh_tokens`.

Migrations managed via Alembic (`backend/alembic/`). Seed data in `backend/scripts/seed.py`.

## Key Integration Points

- **Frontend → Backend:** `lib/core/services/api_service.dart` — all methods are stubbed with mock data; replace with real HTTP calls when wiring up.
- **Spaced repetition:** SM-2 algorithm in `backend/app/services/progress_service.py`.
- **AI hints:** Planned via OpenAI/Anthropic API (requires `OPENAI_API_KEY` in `.env`).
- **WebSocket submissions:** Planned at `WS /ws/submissions/{id}` for real-time execution status.
