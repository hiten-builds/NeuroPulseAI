from datetime import datetime
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, EmailStr, Field, ConfigDict

# --- Auth Schemas ---

class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, description="Password must be at least 8 characters")

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    email: str
    is_active: bool
    created_at: datetime

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

# --- Consent Schemas ---

class ConsentDecisionRequest(BaseModel):
    decision: str = Field(..., pattern="^(granted|declined)$")
    version: str = Field("1.0", description="Version of consent disclosure accepted")
    purpose: str = Field("personalization", description="Specific purpose")

class ConsentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    purpose: str
    decision: str
    version: str
    decision_timestamp: datetime
    withdrawal_timestamp: Optional[datetime] = None
    current_status: str

# --- Motor Session Schemas ---

class MotorSessionSyncItem(BaseModel):
    local_id: str
    test_type: str = Field(..., pattern="^(tapping|spiral)$")
    started_at: Optional[datetime] = None
    completed_at: datetime
    duration_seconds: Optional[float] = None
    
    # Tapping metrics
    cadence_taps_per_sec: Optional[float] = None
    interval_cv: Optional[float] = None
    mean_inter_tap_interval_ms: Optional[float] = None
    mean_center_deviation: Optional[float] = None
    mean_accuracy_score: Optional[float] = None
    total_taps: Optional[int] = None
    
    # Spiral metrics
    spiral_rmse: Optional[float] = None
    spiral_completion_time_sec: Optional[float] = None
    
    metrics: Optional[Dict[str, Any]] = None

class WellnessSessionSyncItem(BaseModel):
    local_id: str
    activity_type: str = Field(..., pattern="^(breathing|meditation|tracing|checkin)$")
    started_at: Optional[datetime] = None
    completed_at: datetime
    duration_seconds: Optional[float] = None
    
    cycles_completed: Optional[int] = None
    target_cycles: Optional[int] = None
    stress_rating: Optional[int] = None
    energy_rating: Optional[int] = None
    mood_rating: Optional[int] = None
    
    metrics: Optional[Dict[str, Any]] = None

class SyncBatchRequest(BaseModel):
    motor_sessions: List[MotorSessionSyncItem] = Field(default_factory=list)
    wellness_sessions: List[WellnessSessionSyncItem] = Field(default_factory=list)

class SyncBatchResponse(BaseModel):
    synced_motor_count: int
    synced_wellness_count: int
    existing_motor_count: int
    existing_wellness_count: int
    synced_at: datetime

# --- Recommendation Schemas ---

class RecommendationItem(BaseModel):
    recommendation_id: str
    title: str
    description: str
    category: str
    explanation: str
    evidence_summary: Optional[Dict[str, Any]] = None
    created_at: datetime

class RecommendationListResponse(BaseModel):
    user_id: str
    has_sufficient_data: bool
    status_message: str
    recommendations: List[RecommendationItem]
    generated_at: datetime
