import os
from pydantic import BaseModel

class Settings(BaseModel):
    app_name: str = os.getenv("APP_NAME", "NeuroPulseAI Backend")
    environment: str = os.getenv("ENVIRONMENT", "development")
    debug: bool = os.getenv("DEBUG", "true").lower() in ("true", "1", "yes")
    database_url: str = os.getenv("DATABASE_URL", "sqlite:///./neuropulse.db")
    jwt_secret_key: str = os.getenv(
        "JWT_SECRET_KEY", 
        "neuropulse-dev-secret-key-change-in-production-minimum-32-chars"
    )
    jwt_algorithm: str = os.getenv("JWT_ALGORITHM", "HS256")
    access_token_expire_minutes: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "1440"))
    consent_version: str = "1.0"
    consent_purpose: str = "personalization"

settings = Settings()
