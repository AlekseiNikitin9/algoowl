from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .database import engine, Base
from .utils.redis import close_redis, get_redis
from .routers import auth, problems, submissions, progress


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: create tables (dev only — use Alembic in prod)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    # Verify Redis connection
    r = await get_redis()
    await r.ping()
    print("✓ Redis connected")
    print("✓ Database tables ready")

    yield

    # Shutdown
    await close_redis()
    await engine.dispose()


app = FastAPI(
    title="AlgoOwl API",
    description="Backend for the AlgoOwl DSA learning app",
    version="0.1.0",
    lifespan=lifespan,
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(auth.router)
app.include_router(problems.router)
app.include_router(submissions.router)
app.include_router(progress.router)


@app.get("/health")
async def health():
    return {"status": "ok", "service": "algoowl-api"}
