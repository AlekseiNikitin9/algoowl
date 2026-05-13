import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .database import engine, Base
from .utils.redis import close_redis, get_redis
from .utils.logging import get_logger, setup_logging
from .routers import auth, problems, submissions, progress, ai

setup_logging()
log = get_logger("api")


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    r = await get_redis()
    await r.ping()
    log.info("✓ Redis connected")
    log.info("✓ Database tables ready")

    yield

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

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    ms = (time.perf_counter() - start) * 1000
    client = request.client.host if request.client else "unknown"
    log.info(
        "%s %s %s — %dms [%s]",
        request.method,
        request.url.path,
        response.status_code,
        int(ms),
        client,
    )
    return response


# Routers
app.include_router(auth.router)
app.include_router(problems.router)
app.include_router(submissions.router)
app.include_router(progress.router)
app.include_router(ai.router)


@app.get("/health")
async def health():
    return {"status": "ok", "service": "algoowl-api"}
