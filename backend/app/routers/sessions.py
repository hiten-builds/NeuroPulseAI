from typing import List, Dict, Any
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from backend.app.core.database import get_db
from backend.app.models import User, MotorSession, WellnessSession
from backend.app.schemas import SyncBatchRequest, SyncBatchResponse
from backend.app.services.auth_service import get_current_user
from backend.app.services.sync_service import sync_sessions_batch

router = APIRouter(prefix="/sessions", tags=["Sessions"])

@router.post("/sync", response_model=SyncBatchResponse)
def sync_sessions(
    batch: SyncBatchRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return sync_sessions_batch(db, current_user.id, batch)

@router.get("/motor")
def get_motor_sessions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    sessions = (
        db.query(MotorSession)
        .filter(MotorSession.user_id == current_user.id)
        .order_by(MotorSession.completed_at.desc())
        .all()
    )
    return [
        {
            "id": s.id,
            "local_id": s.local_id,
            "test_type": s.test_type,
            "completed_at": s.completed_at,
            "duration_seconds": s.duration_seconds,
            "cadence_taps_per_sec": s.cadence_taps_per_sec,
            "interval_cv": s.interval_cv,
            "mean_inter_tap_interval_ms": s.mean_inter_tap_interval_ms,
            "mean_center_deviation": s.mean_center_deviation,
            "mean_accuracy_score": s.mean_accuracy_score,
            "total_taps": s.total_taps,
            "spiral_rmse": s.spiral_rmse,
            "spiral_completion_time_sec": s.spiral_completion_time_sec,
        }
        for s in sessions
    ]

@router.get("/wellness")
def get_wellness_sessions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    sessions = (
        db.query(WellnessSession)
        .filter(WellnessSession.user_id == current_user.id)
        .order_by(WellnessSession.completed_at.desc())
        .all()
    )
    return [
        {
            "id": s.id,
            "local_id": s.local_id,
            "activity_type": s.activity_type,
            "completed_at": s.completed_at,
            "duration_seconds": s.duration_seconds,
            "cycles_completed": s.cycles_completed,
            "stress_rating": s.stress_rating,
            "energy_rating": s.energy_rating,
            "mood_rating": s.mood_rating,
        }
        for s in sessions
    ]
