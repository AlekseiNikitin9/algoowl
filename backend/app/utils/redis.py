import logging

import redis.asyncio as redis

from ..config import settings

log = logging.getLogger("utils.redis")
redis_client: redis.Redis | None = None


async def get_redis() -> redis.Redis:
    global redis_client
    if redis_client is None:
        log.info("Initializing Redis client: %s", settings.redis_url)
        redis_client = redis.from_url(
            settings.redis_url,
            decode_responses=True,
        )
    return redis_client


async def close_redis():
    global redis_client
    if redis_client:
        log.info("Closing Redis client")
        await redis_client.close()
        redis_client = None
