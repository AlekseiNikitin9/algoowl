# AlgoOwl Backend Plan

> Implementation plan for the FastAPI backend, code execution engine, and infrastructure.

---

## 1. Infrastructure — What We Need

### VPS Recommendation

**Provider:** Hetzner Cloud (best price/performance for Docker workloads in this tier)

| Component | Spec | Monthly Cost (est.) | Why |
|---|---|---|---|
| **API Server** | CPX31 — 4 vCPU, 8GB RAM, 160GB SSD | ~€15/mo | FastAPI + PostgreSQL + Redis all on one box for MVP |
| **Domain** | `api.algoowl.com` | ~$12/yr | API endpoint, SSL via Let's Encrypt |

**Why one box for MVP:** We're not at scale. Running everything on a single VPS with Docker Compose keeps ops simple and cheap. Move to multi-node when we hit ~500 concurrent users or execution queue backs up.

**Alternative VPS options:**
- Contabo VPS S (already have one — could colocate, but separating is cleaner)
- DigitalOcean $24/mo droplet (4 vCPU, 8GB)
- Railway.app if we want zero-ops managed (more expensive at scale but nice for MVP)

### Domain & SSL

- API domain: `api.algoowl.com`
- SSL: Caddy reverse proxy (auto Let's Encrypt) or nginx + certbot
- CORS: allow Flutter web + mobile origins

---

## 2. Containers — Docker Compose Stack

**6 containers** for MVP:

| # | Container | Image | Purpose | Resources |
|---|---|---|---|---|
| 1 | **api** | Custom (FastAPI) | Main API server | 1 vCPU, 2GB RAM |
| 2 | **postgres** | `postgres:16-alpine` | Primary database | 1 vCPU, 1GB RAM |
| 3 | **redis** | `redis:7-alpine` | Session cache, job queue, streak tracking | 0.5 vCPU, 512MB |
| 4 | **exec-worker** | Custom (FastAPI worker) | Picks jobs from Redis, manages execution containers | 0.5 vCPU, 1GB |
| 5 | **exec-python** | Custom (Python 3.12 sandbox) | Runs Python user code in isolation | 0.5 vCPU, 256MB per exec |
| 6 | **exec-javascript** | Custom (Node 20 sandbox) | Runs JavaScript user code in isolation | 0.5 vCPU, 256MB per exec |

**Phase 2 additions:**
- `exec-java` (OpenJDK 21 sandbox)
- `exec-cpp` (GCC 13 sandbox)
- `exec-go` (Go 1.22 sandbox)

### Execution Container Design

Each language container:
- Runs as **non-root** user with no network access
- Filesystem: read-only except `/tmp` (capped at 50MB)
- Timeout: hard kill at 5 seconds
- Memory: capped at 256MB via Docker `--memory`
- CPU: limited to 0.5 cores via `--cpus`
- No access to host Docker socket
- Spawned per-execution, destroyed after (no warm pool in MVP — simpler, safer)

---

## 3. API Endpoints — Full Inventory

These are the **exact stubs** from the Flutter frontend `api_service.dart` that need real implementations:

### Auth (4 endpoints)

| Method | Path | Frontend Usage | Notes |
|---|---|---|---|
| `POST` | `/auth/login` | `ApiService.login()` — email/password login | Returns JWT access + refresh token |
| `POST` | `/auth/register` | `ApiService.register()` — new account | Creates user row, returns tokens |
| `POST` | `/auth/google` | `ApiService.loginWithGoogle()` — OAuth | Validates Google ID token server-side |
| `POST` | `/auth/apple` | `ApiService.loginWithApple()` — OAuth | Validates Apple identity token server-side |

**Token scheme:**
- Access token: 15 min expiry, JWT with `user_id` + `email`
- Refresh token: 7 day expiry, stored in DB, rotated on use
- Middleware: `Depends(get_current_user)` on all protected routes

### Problems (2 endpoints)

| Method | Path | Frontend Usage | Notes |
|---|---|---|---|
| `GET` | `/problems` | `ApiService.getProblems()` — practice screen list | Query params: `category`, `difficulty`, `page`, `per_page` |
| `GET` | `/problems/{slug}` | `ApiService.getProblem()` — lesson/editor screens | Returns full problem with test cases (public only), starter code, constraints |

**Data flow:** Frontend models `Problem`, `TestCase`, `Difficulty` all map 1:1 to the API response. Hidden test cases are never sent to the client — only `is_hidden: true` flag + count.

### Submissions (3 endpoints)

| Method | Path | Frontend Usage | Notes |
|---|---|---|---|
| `POST` | `/submissions` | `ApiService.submitCode()` — code editor "Check" button | Accepts `problem_id`, `language`, `code`. Enqueues job in Redis. Returns `submission_id`. |
| `GET` | `/submissions/{id}` | `ApiService.getSubmissionResult()` — polling fallback | Returns status, test results, runtime, memory |
| `WS` | `/ws/submissions/{id}` | Not yet in Flutter (Phase 2) | Streams real-time execution progress |

**Submission flow:**
1. `POST /submissions` → validates code length (<10KB), enqueues to Redis `exec:queue`
2. Exec worker dequeues, spins Docker container, pipes code + test cases in via stdin
3. Container runs each test case, outputs JSON results to stdout
4. Worker parses results, writes to `submissions` table
5. Client polls `GET /submissions/{id}` every 500ms until `status != 'pending'`

**Response shape** (matches frontend mock):
```json
{
  "submissionId": "uuid",
  "status": "accepted" | "wrong_answer" | "runtime_error" | "time_limit" | "pending",
  "testCasesPassed": 3,
  "testCasesTotal": 3,
  "runtimeMs": 12,
  "memoryMb": 14,
  "testResults": [
    {"input": "[2,7,11,15]", "expected": "[0,1]", "actual": "[0,1]", "passed": true},
    ...
  ]
}
```

### AI Review (1 endpoint)

| Method | Path | Frontend Usage | Notes |
|---|---|---|---|
| `POST` | `/ai/review` | `ApiService.getAiReview()` — "Get Hint" button in code editor | Accepts `problem_id`, `code`, `language` |

**Implementation:**
- Calls OpenAI `gpt-4o-mini` (cheap, fast) or Anthropic Haiku
- System prompt: "You are a DSA tutor. Review this code for [problem]. Give: what's correct, what's wrong, one concrete suggestion. Never give the full solution."
- Response cached per (problem_id, code_hash) in Redis for 1 hour
- Rate limit: 10 hints per user per day (prevent abuse)

**Response shape** (matches frontend mock):
```json
{
  "correct": ["Good use of hash map for O(n) lookup."],
  "issues": ["Consider edge case: empty input array."],
  "suggestion": "Add a check for len(nums) < 2 at the start."
}
```

### Progress (3 endpoints)

| Method | Path | Frontend Usage | Notes |
|---|---|---|---|
| `GET` | `/progress/me` | `ApiService.getProgress()` — home screen stats (XP, streak) | Also used by profile screen |
| `GET` | `/progress/me/queue` | `ApiService.getReviewQueue()` — home screen "Today's Review" card | Returns problems due for spaced rep review today |
| `POST` | `/progress/me/review` | `ApiService.submitReview()` — after solving, rate difficulty | Updates SM-2 ease_factor + interval, computes next_review_at |

**Streak logic:**
- Redis key `streak:{user_id}` with daily TTL
- On any successful submission: set today's flag
- Cron job at midnight UTC: for each user, if yesterday's flag exists → increment streak, else reset to 0
- Frontend reads streak from `GET /progress/me`

**SM-2 spaced repetition:**
- `POST /progress/me/review` body: `{ "problem_id": "...", "quality": "easy" | "hard" | "again" }`
- Quality maps to SM-2 grades: easy=5, hard=3, again=1
- Algorithm updates `ease_factor`, `interval`, `next_review_at` in `spaced_reps` table
- `GET /progress/me/queue` returns problems where `next_review_at <= now()`, ordered by ease_factor ASC

### Leaderboard (1 endpoint)

| Method | Path | Frontend Usage | Notes |
|---|---|---|---|
| `GET` | `/leaderboard` | `ApiService.getLeaderboard()` — leaderboard screen | Weekly XP ranking, top 50 |

**Implementation:**
- Redis sorted set `leaderboard:week:{week_number}` with `user_id` → `xp_this_week`
- Updated on every XP gain
- Reset every Monday at midnight UTC
- `GET /leaderboard` returns sorted list with rank, name, xp, is_current_user flag

### Additional Endpoints (not yet in frontend but needed)

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/auth/refresh` | Refresh access token |
| `GET` | `/categories` | Full category list with user progress per category |
| `GET` | `/categories/{slug}/lessons` | Lessons within a category |
| `PATCH` | `/progress/me/settings` | Update daily goal, experience level, focus |
| `PUT` | `/progress/me/onboarding` | Save onboarding selections server-side |
| `GET` | `/progress/me/stats` | Detailed stats (problems by category, solve rate, avg time) |

---

## 4. Database Schema

```sql
-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),          -- null for OAuth-only users
    oauth_provider VARCHAR(20),          -- 'google', 'apple', null
    oauth_id VARCHAR(255),
    name VARCHAR(100) NOT NULL,
    xp INTEGER DEFAULT 0,
    streak INTEGER DEFAULT 0,
    daily_goal_minutes INTEGER DEFAULT 10,
    experience_level VARCHAR(20) DEFAULT 'beginner',
    focus VARCHAR(20) DEFAULT 'both',
    onboarding_complete BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Categories (skill tree)
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon VARCHAR(50),
    order_index INTEGER NOT NULL,
    unlock_threshold FLOAT DEFAULT 0.7   -- % of prev category to unlock
);

-- Lessons within categories
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES categories(id),
    title VARCHAR(200) NOT NULL,
    order_index INTEGER NOT NULL,
    xp_reward INTEGER DEFAULT 15
);

-- Problems
CREATE TABLE problems (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE NOT NULL,
    category_id UUID REFERENCES categories(id),
    lesson_id UUID REFERENCES lessons(id),
    difficulty VARCHAR(10) NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
    description TEXT NOT NULL,
    constraints TEXT,
    starter_code JSONB DEFAULT '{}',     -- {"python": "...", "javascript": "..."}
    order_index INTEGER NOT NULL
);

-- Test cases (never send hidden ones to client)
CREATE TABLE test_cases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    problem_id UUID REFERENCES problems(id) ON DELETE CASCADE,
    input TEXT NOT NULL,
    expected_output TEXT NOT NULL,
    is_hidden BOOLEAN DEFAULT FALSE,
    order_index INTEGER NOT NULL
);

-- Submissions
CREATE TABLE submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    problem_id UUID REFERENCES problems(id),
    language VARCHAR(20) NOT NULL,
    code TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',  -- pending, accepted, wrong_answer, runtime_error, time_limit
    test_cases_passed INTEGER DEFAULT 0,
    test_cases_total INTEGER DEFAULT 0,
    runtime_ms INTEGER,
    memory_mb INTEGER,
    ai_feedback JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User progress per problem
CREATE TABLE user_progress (
    user_id UUID REFERENCES users(id),
    problem_id UUID REFERENCES problems(id),
    status VARCHAR(20) DEFAULT 'unseen',   -- unseen, attempted, solved
    attempts INTEGER DEFAULT 0,
    last_attempt_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, problem_id)
);

-- Spaced repetition (SM-2)
CREATE TABLE spaced_reps (
    user_id UUID REFERENCES users(id),
    problem_id UUID REFERENCES problems(id),
    ease_factor FLOAT DEFAULT 2.5,
    interval_days INTEGER DEFAULT 1,
    repetitions INTEGER DEFAULT 0,
    next_review_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, problem_id)
);

-- Refresh tokens
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_submissions_user ON submissions(user_id, created_at DESC);
CREATE INDEX idx_submissions_status ON submissions(status) WHERE status = 'pending';
CREATE INDEX idx_spaced_reps_due ON spaced_reps(user_id, next_review_at);
CREATE INDEX idx_problems_category ON problems(category_id, order_index);
CREATE INDEX idx_user_progress_user ON user_progress(user_id);
```

---

## 5. Tech Stack Details

| Layer | Choice | Why |
|---|---|---|
| **API Framework** | FastAPI (Python 3.12) | Async, fast, auto-generated OpenAPI docs, Pydantic validation |
| **ORM** | SQLAlchemy 2.0 + Alembic | Async support, mature migrations |
| **Auth** | python-jose (JWT) + passlib (bcrypt) | Standard, well-tested |
| **OAuth** | httpx + provider SDKs | Validate Google/Apple tokens server-side |
| **Task Queue** | Redis + custom worker (or arq) | Lightweight, no Celery overhead for MVP |
| **AI Client** | openai SDK (works for both OpenAI and Anthropic) | Hint generation |
| **Testing** | pytest + httpx (async test client) | FastAPI native |
| **Containerization** | Docker + Docker Compose | All services defined in one compose file |
| **Reverse Proxy** | Caddy | Auto SSL, simpler config than nginx |

---

## 6. Project Structure

```
backend/
├── docker-compose.yml
├── Dockerfile                    # API server image
├── Dockerfile.worker             # Execution worker image
├── containers/
│   ├── python/
│   │   └── Dockerfile            # Python sandbox image
│   └── javascript/
│       └── Dockerfile            # Node sandbox image
├── alembic/                      # DB migrations
│   └── versions/
├── app/
│   ├── main.py                   # FastAPI app, CORS, middleware
│   ├── config.py                 # Settings (env vars, secrets)
│   ├── database.py               # Async SQLAlchemy engine + session
│   ├── models/                   # SQLAlchemy models
│   │   ├── user.py
│   │   ├── problem.py
│   │   ├── submission.py
│   │   ├── progress.py
│   │   └── spaced_rep.py
│   ├── schemas/                  # Pydantic request/response models
│   │   ├── auth.py
│   │   ├── problem.py
│   │   ├── submission.py
│   │   ├── progress.py
│   │   └── leaderboard.py
│   ├── routers/                  # API route handlers
│   │   ├── auth.py               # /auth/*
│   │   ├── problems.py           # /problems/*
│   │   ├── submissions.py        # /submissions/*
│   │   ├── ai_review.py          # /ai/review
│   │   ├── progress.py           # /progress/*
│   │   └── leaderboard.py        # /leaderboard
│   ├── services/                 # Business logic
│   │   ├── auth_service.py
│   │   ├── execution_service.py  # Enqueue + manage code execution
│   │   ├── ai_service.py         # LLM hint generation
│   │   ├── spaced_rep_service.py # SM-2 algorithm
│   │   └── leaderboard_service.py
│   ├── worker/                   # Execution worker process
│   │   ├── main.py               # Worker loop (dequeue from Redis)
│   │   └── executor.py           # Docker container management
│   └── utils/
│       ├── security.py           # JWT encode/decode, password hash
│       └── redis.py              # Redis connection + helpers
├── scripts/
│   ├── seed_problems.py          # Load initial problem set
│   └── seed_categories.py        # Load category tree
├── tests/
│   ├── test_auth.py
│   ├── test_submissions.py
│   └── ...
├── requirements.txt
└── .env.example
```

---

## 7. Security Considerations

| Concern | Mitigation |
|---|---|
| **Code injection** | Execution containers have no network, no host access, read-only FS, 256MB RAM cap, 5s timeout |
| **Fork bombs** | `--pids-limit 50` on execution containers |
| **Disk abuse** | `/tmp` capped at 50MB via tmpfs mount |
| **API abuse** | Rate limiting via Redis: 60 req/min general, 10 hints/day, 30 submissions/hour |
| **SQL injection** | SQLAlchemy parameterized queries (never raw SQL with user input) |
| **Auth** | bcrypt hashing, JWT with short expiry, refresh token rotation |
| **CORS** | Whitelist only `algoowl.com` + localhost dev origins |
| **Secrets** | All secrets via env vars, never committed. `.env.example` with placeholders only |

---

## 8. Seed Data Plan

MVP ships with **3 categories, ~30 problems**:

| Category | Problem Count | Difficulty Mix |
|---|---|---|
| Arrays & Strings | 12 | 6 easy, 4 medium, 2 hard |
| Hashing | 10 | 5 easy, 3 medium, 2 hard |
| Two Pointers | 8 | 4 easy, 3 medium, 1 hard |

Each problem needs:
- Title, slug, description, constraints
- 3–5 public test cases + 2–3 hidden test cases
- Starter code templates (Python + JavaScript)
- Correct solution (for validation, never sent to client)

Source: curated from LeetCode-style problems, rewritten to avoid copyright.

---

## 9. Build Order (Implementation Phases)

### Phase A — Foundation (Week 1)
1. Docker Compose with Postgres + Redis + FastAPI shell
2. Database schema + Alembic migrations
3. Auth endpoints (register, login, refresh, Google OAuth)
4. Seed script for categories + problems

### Phase B — Core API (Week 2)
5. Problems endpoints (list, get by slug)
6. Progress endpoints (stats, update settings, onboarding save)
7. Submissions endpoint (POST — enqueue only, no execution yet)
8. Wire Flutter frontend to real API (replace all stubs)

### Phase C — Code Execution (Week 3)
9. Python sandbox container (Dockerfile, runner script)
10. JavaScript sandbox container
11. Execution worker (dequeue from Redis, manage Docker containers)
12. Submissions result endpoint (poll status)

### Phase D — Smart Features (Week 4)
13. AI review endpoint (LLM integration)
14. Spaced repetition service (SM-2 implementation)
15. Review queue endpoint
16. Leaderboard (Redis sorted set)

### Phase E — Polish (Week 5)
17. Rate limiting middleware
18. Error handling + logging (structured JSON logs)
19. Health check endpoint (`/health`)
20. CI/CD: GitHub Actions → build Docker images → deploy to VPS

---

## 10. Cost Estimate (Monthly — MVP)

| Item | Cost |
|---|---|
| VPS (Hetzner CPX31) | ~$16 |
| Domain | ~$1 (amortized) |
| OpenAI API (hints, ~1000 req/day) | ~$5–15 |
| Total | **~$22–32/mo** |

Scales to ~500 DAU before needing a second box or Kubernetes.

---

## 11. Open Questions

- [ ] **Which AI provider for hints?** OpenAI (gpt-4o-mini) is cheapest. Anthropic (Haiku) is an option. Could offer both via config.
- [ ] **Apple OAuth:** Requires Apple Developer account ($99/yr). Skip for MVP and add later?
- [ ] **Problem content:** Write our own or license? Need ~30 problems for MVP launch.
- [ ] **WebSocket vs polling:** Frontend currently doesn't have WS support. Polling is fine for MVP (submissions take <5s). Add WS in Phase 2.
- [ ] **Warm container pool:** MVP spawns fresh containers per execution (simpler, more secure). Pool for performance later.

---

*Backend Plan v1.0 — Linus 💻 — March 2026*
