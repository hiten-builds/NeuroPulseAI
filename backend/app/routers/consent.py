from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from backend.app.core.database import get_db
from backend.app.models import User
from backend.app.schemas import ConsentDecisionRequest, ConsentResponse
from backend.app.services.auth_service import get_current_user
from backend.app.services.consent_service import (
    get_user_consent, record_consent_decision, withdraw_consent
)

router = APIRouter(prefix="/consent", tags=["Consent"])

@router.get("", response_model=ConsentResponse)
def get_current_consent(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    consent = get_user_consent(db, current_user.id)
    if not consent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No consent decision recorded for this user yet."
        )
    return ConsentResponse.model_validate(consent)

@router.put("/personalization", response_model=ConsentResponse)
def set_personalization_consent(
    request: ConsentDecisionRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    consent = record_consent_decision(
        db=db,
        user_id=current_user.id,
        decision=request.decision,
        version=request.version,
        purpose=request.purpose
    )
    return ConsentResponse.model_validate(consent)

@router.post("/withdraw", response_model=ConsentResponse)
def withdraw_personalization_consent(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    withdrawn = withdraw_consent(db, current_user.id, purpose="personalization")
    return ConsentResponse.model_validate(withdrawn)
