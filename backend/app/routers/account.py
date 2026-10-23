from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from backend.app.core.database import get_db
from backend.app.models import User, MotorSession, WellnessSession, Recommendation
from backend.app.services.auth_service import get_current_user
from backend.app.services.consent_service import withdraw_consent

router = APIRouter(prefix="/account", tags=["Account Management"])

@router.delete("/data", status_code=status.HTTP_200_OK)
def delete_user_remote_data(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Deletes all remote motor sessions, wellness sessions, and recommendations
    belonging to the authenticated user.
    Also automatically withdraws personalization consent to prevent new syncs.
    Preserves the user account credentials.
    """
    motor_count = (
        db.query(MotorSession)
        .filter(MotorSession.user_id == current_user.id)
        .delete()
    )
    wellness_count = (
        db.query(WellnessSession)
        .filter(WellnessSession.user_id == current_user.id)
        .delete()
    )
    rec_count = (
        db.query(Recommendation)
        .filter(Recommendation.user_id == current_user.id)
        .delete()
    )
    db.commit()

    # Mark consent as withdrawn
    withdraw_consent(db, current_user.id, purpose="personalization")

    return {
        "status": "success",
        "message": "All remote assessment and wellness records have been deleted.",
        "deleted_motor_sessions": motor_count,
        "deleted_wellness_sessions": wellness_count,
        "deleted_recommendations": rec_count,
        "consent_withdrawn": True
    }

@router.delete("", status_code=status.HTTP_200_OK)
def delete_account(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Permanently delete user account and all cascaded data."""
    db.delete(current_user)
    db.commit()
    return {
        "status": "success",
        "message": "Account and associated data deleted permanently."
    }
