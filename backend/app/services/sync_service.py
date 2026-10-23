import json
from datetime import datetime, timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from backend.app.models import MotorSession, WellnessSession
from backend.app.schemas import SyncBatchRequest, SyncBatchResponse
from backend.app.services.consent_service import is_personalization_consented

def sync_sessions_batch(db: Session, user_id: str, batch: SyncBatchRequest) -> SyncBatchResponse:
    # 1. Enforce Server-Side Consent Rule
    if not is_personalization_consented(db, user_id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Personalization data-sharing consent has not been granted or has been withdrawn. Upload rejected."
        )

    synced_motor = 0
    existing_motor = 0
    synced_wellness = 0
    existing_wellness = 0

    # 2. Process Motor Sessions idempotently
    for item in batch.motor_sessions:
        existing = (
            db.query(MotorSession)
            .filter(MotorSession.user_id == user_id, MotorSession.local_id == item.local_id)
            .first()
        )
        if existing:
            existing_motor += 1
            continue
        
        metrics_str = json.dumps(item.metrics) if item.metrics is not None else None
        record = MotorSession(
            user_id=user_id,
            local_id=item.local_id,
            test_type=item.test_type,
            started_at=item.started_at,
            completed_at=item.completed_at,
            duration_seconds=item.duration_seconds,
            cadence_taps_per_sec=item.cadence_taps_per_sec,
            interval_cv=item.interval_cv,
            mean_inter_tap_interval_ms=item.mean_inter_tap_interval_ms,
            mean_center_deviation=item.mean_center_deviation,
            mean_accuracy_score=item.mean_accuracy_score,
            total_taps=item.total_taps,
            spiral_rmse=item.spiral_rmse,
            spiral_completion_time_sec=item.spiral_completion_time_sec,
            metrics_json=metrics_str
        )
        db.add(record)
        synced_motor += 1

    # 3. Process Wellness Sessions idempotently
    for item in batch.wellness_sessions:
        existing = (
            db.query(WellnessSession)
            .filter(WellnessSession.user_id == user_id, WellnessSession.local_id == item.local_id)
            .first()
        )
        if existing:
            existing_wellness += 1
            continue

        metrics_str = json.dumps(item.metrics) if item.metrics is not None else None
        record = WellnessSession(
            user_id=user_id,
            local_id=item.local_id,
            activity_type=item.activity_type,
            started_at=item.started_at,
            completed_at=item.completed_at,
            duration_seconds=item.duration_seconds,
            cycles_completed=item.cycles_completed,
            target_cycles=item.target_cycles,
            stress_rating=item.stress_rating,
            energy_rating=item.energy_rating,
            mood_rating=item.mood_rating,
            metrics_json=metrics_str
        )
        db.add(record)
        synced_wellness += 1

    db.commit()

    return SyncBatchResponse(
        synced_motor_count=synced_motor,
        synced_wellness_count=synced_wellness,
        existing_motor_count=existing_motor,
        existing_wellness_count=existing_wellness,
        synced_at=datetime.now(timezone.utc)
    )
