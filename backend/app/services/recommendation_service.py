import uuid
from datetime import datetime, timezone
from typing import List, Dict, Any
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from backend.app.models import MotorSession, WellnessSession
from backend.app.schemas import RecommendationItem, RecommendationListResponse
from backend.app.services.consent_service import is_personalization_consented

def generate_recommendations(db: Session, user_id: str) -> RecommendationListResponse:
    # 1. Enforce server-side consent
    if not is_personalization_consented(db, user_id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Personalization consent is required to access account-linked recommendations."
        )

    # 2. Retrieve user's synced records only
    motor_records = (
        db.query(MotorSession)
        .filter(MotorSession.user_id == user_id)
        .order_by(MotorSession.completed_at.desc())
        .limit(20)
        .all()
    )
    wellness_records = (
        db.query(WellnessSession)
        .filter(WellnessSession.user_id == user_id)
        .order_by(WellnessSession.completed_at.desc())
        .limit(20)
        .all()
    )

    total_sessions = len(motor_records) + len(wellness_records)
    now = datetime.now(timezone.utc)

    # 3. Minimum data requirements check (at least 2 sessions needed for personalized trend analysis)
    if total_sessions < 2:
        baseline_recs = [
            RecommendationItem(
                recommendation_id=f"rec-baseline-{uuid.uuid4().hex[:8]}",
                title="Establish Your Baseline",
                description="Complete at least two motor assessments and one wellness check-in to unlock personalized pacing and recovery suggestions.",
                category="general",
                explanation="Trend analysis requires repeat sessions to observe your natural pacing and recovery patterns. Your data remains protected under your chosen consent settings.",
                evidence_summary={
                    "total_sessions_found": total_sessions,
                    "required_minimum": 2,
                    "notice": "Neutral wellness guidance. Not a diagnostic assessment."
                },
                created_at=now
            ),
            RecommendationItem(
                recommendation_id=f"rec-wellness-{uuid.uuid4().hex[:8]}",
                title="Mindful Pacing Check-In",
                description="Try a 2-minute Guided Breathing session in MindEase before your next assessment to observe how breathing influences your motor rhythm.",
                category="wellness",
                explanation="Standard wellness practice suggests taking brief breathing pauses before fine-motor activities.",
                evidence_summary={
                    "suggestion_type": "lifestyle_wellness",
                    "notice": "Consult a healthcare provider for any clinical questions."
                },
                created_at=now
            )
        ]
        return RecommendationListResponse(
            user_id=user_id,
            has_sufficient_data=False,
            status_message="Complete at least 2 sessions to generate data-driven personalized recommendations.",
            recommendations=baseline_recs,
            generated_at=now
        )

    # 4. Generate data-driven, explainable recommendations from user's records
    recs: List[RecommendationItem] = []

    # Analysis A: Tapping Cadence & Rhythm Stability
    tapping_sessions = [s for s in motor_records if s.test_type == "tapping" and s.cadence_taps_per_sec is not None]
    if tapping_sessions:
        cadences = [s.cadence_taps_per_sec for s in tapping_sessions]
        cv_values = [s.interval_cv for s in tapping_sessions if s.interval_cv is not None]
        mean_cadence = sum(cadences) / len(cadences)
        mean_cv = (sum(cv_values) / len(cv_values)) if cv_values else 0.0

        if mean_cv > 0.25:
            recs.append(RecommendationItem(
                recommendation_id=f"rec-cadence-{uuid.uuid4().hex[:8]}",
                title="Smooth Cadence Pacing",
                description="Your recent tapping interval variability is slightly elevated across target zones. Practice gentle rhythmic tapping without rushing.",
                category="cadence",
                explanation=f"Based on {len(tapping_sessions)} tapping sessions with an average interval CV of {mean_cv:.2f}. Lower variability indicates more uniform pacing.",
                evidence_summary={
                    "sample_count": len(tapping_sessions),
                    "mean_cadence_taps_per_sec": round(mean_cadence, 2),
                    "mean_interval_cv": round(mean_cv, 3),
                    "latest_session": tapping_sessions[0].completed_at.isoformat()
                },
                created_at=now
            ))
        else:
            recs.append(RecommendationItem(
                recommendation_id=f"rec-cadence-{uuid.uuid4().hex[:8]}",
                title="Consistent Motor Rhythm",
                description="Your alternating tapping pace demonstrates consistent rhythm stability across both target zones.",
                category="cadence",
                explanation=f"Derived from {len(tapping_sessions)} tapping assessments showing a stable rhythm (mean CV {mean_cv:.2f}, cadence {mean_cadence:.1f} taps/sec).",
                evidence_summary={
                    "sample_count": len(tapping_sessions),
                    "mean_cadence_taps_per_sec": round(mean_cadence, 2),
                    "mean_interval_cv": round(mean_cv, 3)
                },
                created_at=now
            ))

    # Analysis B: Spiral Tracing Smoothness
    spiral_sessions = [s for s in motor_records if s.test_type == "spiral" and s.spiral_rmse is not None]
    if spiral_sessions:
        rmse_values = [s.spiral_rmse for s in spiral_sessions]
        mean_rmse = sum(rmse_values) / len(rmse_values)
        times = [s.spiral_completion_time_sec for s in spiral_sessions if s.spiral_completion_time_sec is not None]
        mean_time = (sum(times) / len(times)) if times else 0.0

        recs.append(RecommendationItem(
            recommendation_id=f"rec-tracing-{uuid.uuid4().hex[:8]}",
            title="Fine-Motor Tracing Trajectory",
            description="Take your time when tracing inner spiral turns. Smooth, deliberate continuous strokes yield higher path accuracy.",
            category="tracing",
            explanation=f"Calculated from {len(spiral_sessions)} spiral tracing trials with average root-mean-square error of {mean_rmse:.1f} pt and duration of {mean_time:.1f} s.",
            evidence_summary={
                "spiral_sessions_count": len(spiral_sessions),
                "mean_rmse_pt": round(mean_rmse, 2),
                "mean_duration_sec": round(mean_time, 1)
            },
            created_at=now
        ))

    # Analysis C: Wellness & Stress Correlation
    checkin_sessions = [w for w in wellness_records if w.stress_rating is not None]
    breathing_sessions = [w for w in wellness_records if w.activity_type == "breathing"]
    if checkin_sessions:
        stress_levels = [w.stress_rating for w in checkin_sessions]
        avg_stress = sum(stress_levels) / len(stress_levels)
        if avg_stress >= 3.0:
            recs.append(RecommendationItem(
                recommendation_id=f"rec-wellness-{uuid.uuid4().hex[:8]}",
                title="Post-Assessment Wind Down",
                description="Your self-reported stress levels averaged moderately high. Pair motor assessments with 3 minutes of 4-7-8 breathing in MindEase.",
                category="wellness",
                explanation=f"Analyzed {len(checkin_sessions)} wellness check-ins showing average stress rating of {avg_stress:.1f}/5.",
                evidence_summary={
                    "checkins_analyzed": len(checkin_sessions),
                    "average_stress": round(avg_stress, 1),
                    "breathing_sessions_completed": len(breathing_sessions)
                },
                created_at=now
            ))
        else:
            recs.append(RecommendationItem(
                recommendation_id=f"rec-wellness-{uuid.uuid4().hex[:8]}",
                title="Well-Balanced Recovery",
                description="Your wellness check-ins reflect steady recovery after motor sessions. Continue balancing activity with restful intervals.",
                category="wellness",
                explanation=f"Based on {len(checkin_sessions)} check-ins with favorable stress scores (average {avg_stress:.1f}/5).",
                evidence_summary={
                    "checkins_analyzed": len(checkin_sessions),
                    "average_stress": round(avg_stress, 1)
                },
                created_at=now
            ))
    elif breathing_sessions:
        recs.append(RecommendationItem(
            recommendation_id=f"rec-wellness-{uuid.uuid4().hex[:8]}",
            title="MindEase Rhythm Pairing",
            description="You have completed guided breathing sessions. Regular mindful breathing supports relaxed motor control.",
            category="wellness",
            explanation=f"Based on {len(breathing_sessions)} completed breathing sessions.",
            evidence_summary={
                "breathing_sessions_count": len(breathing_sessions)
            },
            created_at=now
        ))

    return RecommendationListResponse(
        user_id=user_id,
        has_sufficient_data=True,
        status_message=f"Personalized insights generated from {total_sessions} authorized activity records.",
        recommendations=recs,
        generated_at=now
    )
