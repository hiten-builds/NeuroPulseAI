from datetime import datetime, timezone

def test_recommendations_consent_enforcement(client):
    reg = client.post("/auth/register", json={"email": "grace@example.com", "password": "password123"})
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # No consent -> 403
    res = client.get("/recommendations", headers=headers)
    assert res.status_code == 403

def test_recommendations_insufficient_data(client):
    reg = client.post("/auth/register", json={"email": "heidi@example.com", "password": "password123"})
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    client.put("/consent/personalization", json={"decision": "granted", "version": "1.0", "purpose": "personalization"}, headers=headers)

    # 0 sessions uploaded
    res = client.get("/recommendations", headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert data["has_sufficient_data"] is False
    assert "Complete at least 2 sessions" in data["status_message"]
    assert len(data["recommendations"]) > 0
    # Ensure baseline recommendations have clear evidence/notice
    assert "not a diagnostic" in data["recommendations"][0]["evidence_summary"]["notice"].lower()

def test_recommendations_personalized_with_sufficient_data(client):
    reg = client.post("/auth/register", json={"email": "ivan@example.com", "password": "password123"})
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    client.put("/consent/personalization", json={"decision": "granted", "version": "1.0", "purpose": "personalization"}, headers=headers)

    # Upload 2 tapping sessions and 1 wellness check-in
    payload = {
        "motor_sessions": [
            {
                "local_id": "tap-1",
                "test_type": "tapping",
                "completed_at": datetime.now(timezone.utc).isoformat(),
                "cadence_taps_per_sec": 3.9,
                "interval_cv": 0.11,
                "total_taps": 39
            },
            {
                "local_id": "tap-2",
                "test_type": "tapping",
                "completed_at": datetime.now(timezone.utc).isoformat(),
                "cadence_taps_per_sec": 4.1,
                "interval_cv": 0.13,
                "total_taps": 41
            }
        ],
        "wellness_sessions": [
            {
                "local_id": "checkin-1",
                "activity_type": "checkin",
                "completed_at": datetime.now(timezone.utc).isoformat(),
                "stress_rating": 2,
                "mood_rating": 4,
                "energy_rating": 3
            }
        ]
    }
    client.post("/sessions/sync", json=payload, headers=headers)

    # Request recommendations
    res = client.get("/recommendations", headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert data["has_sufficient_data"] is True
    assert len(data["recommendations"]) >= 2
    
    # Check explainability and category
    categories = [r["category"] for r in data["recommendations"]]
    assert "cadence" in categories
    assert "wellness" in categories

    cadence_rec = next(r for r in data["recommendations"] if r["category"] == "cadence")
    assert "Derived from 2 tapping assessments" in cadence_rec["explanation"] or "Based on 2 tapping" in cadence_rec["explanation"]
    assert cadence_rec["evidence_summary"]["sample_count"] == 2
