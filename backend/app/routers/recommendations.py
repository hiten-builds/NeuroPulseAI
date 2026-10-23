from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from backend.app.core.database import get_db
from backend.app.models import User
from backend.app.schemas import RecommendationListResponse
from backend.app.services.auth_service import get_current_user
from backend.app.services.recommendation_service import generate_recommendations

router = APIRouter(prefix="/recommendations", tags=["Recommendations"])

@router.get("", response_model=RecommendationListResponse)
def get_user_recommendations(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return generate_recommendations(db, current_user.id)
