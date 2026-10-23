from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.app.core.config import settings
from backend.app.core.database import init_db
from backend.app.routers import auth, consent, sessions, recommendations, account

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    yield

app = FastAPI(
    title=settings.app_name,
    version="1.0.0",
    description="NeuroPulseAI Backend for Authentication, Purpose-Specific Consent, Idempotent Record Sync, and Explainable Recommendations.",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health", tags=["Health"])
def health_check():
    return {
        "status": "healthy",
        "app": settings.app_name,
        "environment": settings.environment,
        "consent_version": settings.consent_version
    }

@app.get("/", tags=["Root"])
def root():
    return {
        "message": "NeuroPulseAI API is running.",
        "docs_url": "/docs",
        "health_url": "/health"
    }

app.include_router(auth.router)
app.include_router(consent.router)
app.include_router(sessions.router)
app.include_router(recommendations.router)
app.include_router(account.router)
