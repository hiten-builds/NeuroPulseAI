from typing import Optional
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from backend.app.models import ConsentRecord

def get_user_consent(db: Session, user_id: str, purpose: str = "personalization") -> Optional[ConsentRecord]:
    """Retrieve the latest consent record for the specified user and purpose."""
    return (
        db.query(ConsentRecord)
        .filter(ConsentRecord.user_id == user_id, ConsentRecord.purpose == purpose)
        .order_by(ConsentRecord.created_at.desc())
        .first()
    )

def is_personalization_consented(db: Session, user_id: str) -> bool:
    """Return True only if the user has an active, granted consent for personalization."""
    consent = get_user_consent(db, user_id, purpose="personalization")
    if not consent:
        return False
    return consent.decision == "granted" and consent.current_status == "active"

def record_consent_decision(
    db: Session,
    user_id: str,
    decision: str,
    version: str = "1.0",
    purpose: str = "personalization"
) -> ConsentRecord:
    """
    Record an explicit consent decision ("granted" or "declined").
    Creates a new immutable receipt record marking previous records superseded.
    """
    now = datetime.now(timezone.utc)
    status = "active" if decision == "granted" else "declined"
    
    # Create the new consent audit record
    new_consent = ConsentRecord(
        user_id=user_id,
        purpose=purpose,
        decision=decision,
        version=version,
        decision_timestamp=now,
        withdrawal_timestamp=None,
        current_status=status
    )
    db.add(new_consent)
    db.commit()
    db.refresh(new_consent)
    return new_consent

def withdraw_consent(db: Session, user_id: str, purpose: str = "personalization") -> Optional[ConsentRecord]:
    """
    Withdraw existing consent for the user.
    Updates current active records and records a withdrawal timestamp.
    """
    active_consents = (
        db.query(ConsentRecord)
        .filter(
            ConsentRecord.user_id == user_id,
            ConsentRecord.purpose == purpose,
            ConsentRecord.current_status == "active"
        )
        .all()
    )
    
    now = datetime.now(timezone.utc)
    for c in active_consents:
        c.current_status = "withdrawn"
        c.withdrawal_timestamp = now
        db.add(c)
        
    # Also record an explicit withdrawn record
    withdrawn_record = ConsentRecord(
        user_id=user_id,
        purpose=purpose,
        decision="declined",
        version="1.0",
        decision_timestamp=now,
        withdrawal_timestamp=now,
        current_status="withdrawn"
    )
    db.add(withdrawn_record)
    db.commit()
    db.refresh(withdrawn_record)
    return withdrawn_record
