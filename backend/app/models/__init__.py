import uuid
from datetime import datetime, timezone
from sqlalchemy import (
    Column, String, Boolean, DateTime, Float, Integer, ForeignKey, Text, UniqueConstraint
)
from sqlalchemy.orm import relationship
from backend.app.core.database import Base

def generate_uuid() -> str:
    return str(uuid.uuid4())

def utc_now() -> datetime:
    return datetime.now(timezone.utc)

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now, nullable=False)

    consents = relationship("ConsentRecord", back_populates="user", cascade="all, delete-orphan")
    motor_sessions = relationship("MotorSession", back_populates="user", cascade="all, delete-orphan")
    wellness_sessions = relationship("WellnessSession", back_populates="user", cascade="all, delete-orphan")
    recommendations = relationship("Recommendation", back_populates="user", cascade="all, delete-orphan")

class ConsentRecord(Base):
    __tablename__ = "consent_records"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    purpose = Column(String(64), nullable=False, default="personalization")
    decision = Column(String(32), nullable=False) # "granted" or "declined"
    version = Column(String(32), nullable=False, default="1.0")
    decision_timestamp = Column(DateTime(timezone=True), default=utc_now, nullable=False)
    withdrawal_timestamp = Column(DateTime(timezone=True), nullable=True)
    current_status = Column(String(32), nullable=False) # "active" or "withdrawn" or "declined"
    created_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)

    user = relationship("User", back_populates="consents")

class MotorSession(Base):
    __tablename__ = "motor_sessions"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    local_id = Column(String(64), nullable=False, index=True)
    test_type = Column(String(32), nullable=False) # "tapping" or "spiral"
    started_at = Column(DateTime(timezone=True), nullable=True)
    completed_at = Column(DateTime(timezone=True), nullable=False)
    duration_seconds = Column(Float, nullable=True)
    
    # Tapping metrics
    cadence_taps_per_sec = Column(Float, nullable=True)
    interval_cv = Column(Float, nullable=True)
    mean_inter_tap_interval_ms = Column(Float, nullable=True)
    mean_center_deviation = Column(Float, nullable=True)
    mean_accuracy_score = Column(Float, nullable=True)
    total_taps = Column(Integer, nullable=True)
    
    # Spiral metrics
    spiral_rmse = Column(Float, nullable=True)
    spiral_completion_time_sec = Column(Float, nullable=True)
    
    metrics_json = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)

    user = relationship("User", back_populates="motor_sessions")

    __table_args__ = (
        UniqueConstraint("user_id", "local_id", name="uq_user_motor_local_id"),
    )

class WellnessSession(Base):
    __tablename__ = "wellness_sessions"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    local_id = Column(String(64), nullable=False, index=True)
    activity_type = Column(String(32), nullable=False) # "breathing", "meditation", "tracing", "checkin"
    started_at = Column(DateTime(timezone=True), nullable=True)
    completed_at = Column(DateTime(timezone=True), nullable=False)
    duration_seconds = Column(Float, nullable=True)
    
    cycles_completed = Column(Integer, nullable=True)
    target_cycles = Column(Integer, nullable=True)
    stress_rating = Column(Integer, nullable=True)
    energy_rating = Column(Integer, nullable=True)
    mood_rating = Column(Integer, nullable=True)
    
    metrics_json = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)

    user = relationship("User", back_populates="wellness_sessions")

    __table_args__ = (
        UniqueConstraint("user_id", "local_id", name="uq_user_wellness_local_id"),
    )

class Recommendation(Base):
    __tablename__ = "recommendations"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    recommendation_id = Column(String(64), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String(64), nullable=False) # "cadence", "rhythm", "tracing", "wellness", "general"
    explanation = Column(Text, nullable=False)
    evidence_summary_json = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=utc_now, nullable=False)

    user = relationship("User", back_populates="recommendations")
