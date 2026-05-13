from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Database
    database_url: str = "postgresql+asyncpg://algoowl:algoowl_secret@postgres:5432/algoowl"

    # Redis
    redis_url: str = "redis://redis:6379/0"

    # JWT
    jwt_secret_key: str = "change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 7

    # AI
    openai_api_key: str = "sk-placeholder"
    gemini_api_key: str = "placeholder"

    # OAuth
    google_client_id: str = ""
    apple_client_id: str = ""

    # App
    app_env: str = "development"
    cors_origins: str = "http://localhost:8080"

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",")]

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
