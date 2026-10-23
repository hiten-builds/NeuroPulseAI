from datetime import datetime, timezone

def test_sync_requires_consent(client):
    reg = client.post("/auth/register", json={"email": "eve@example.com", "password": "password123"})
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "motor_sessions": [{
            "local_id": "loc-motor-1",
            "test_type": "tapping",
            "completed_at": datetime.now(timezone.utc).isoformat(),
            "cadence_taps_per_sec": 4.2,
            "interval_cv": 0.12,
            "total_taps": 42
        }],
        "wellness_sessions": []
    }

    # No consent granted yet -> Must return 403 Forbidden
    res = client.post("/sessions/sync", json=payload, headers=headers)
    assert res.status_code == 403
    assert "consent has not been granted" in res.json()["detail"].lower()

def test_sync_idempotency_and_withdrawal(client):
    reg = client.post("/auth/register", json={"email": "frank@example.com", "password": "password123"})
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Grant consent
    client.put(
        "/consent/personalization",
        json={"decision": "granted", "version": "1.0", "purpose": "personalization"},
        headers=headers
    )

    payload = {
        "motor_sessions": [
            {
                "local_id": "loc-motor-101",
                "test_type": "tapping",
                "completed_at": datetime.now(timezone.utc).isoformat(),
                "cadence_taps_per_sec": 3.8,
                "interval_cv": 0.15,
                "total_taps": 38
            },
            {
                "local_id": "loc-motor-102",
                "test_type": "spiral",
                "completed_at": datetime.now(timezone.utc).isoformat(),
                "spiral_rmse": 14.5,
                "spiral_completion_time_sec": 12.3
            }
        ],
        "wellness_sessions": [
            {
                "local_id": "loc-well-201",
                "activity_type": "breathing",
                "completed_at": datetime.now(timezone.utc).isoformat(),
                "cycles_completed": 4,
                "duration_seconds": 60.0
            }
        ]
    }

    # First sync -> all synced
    res1 = client.post("/sessions/sync", json=payload, headers=headers)
    assert res1.status_code == 200
    data1 = res1.json()
    assert data1["synced_motor_count"] == 2
    assert data1["synced_wellness_count"] == 1
    assert data1["existing_motor_count"] == 0
    assert data1["existing_wellness_count"] == 0

    # Second sync of identical batch -> idempotent! (0 new, all recognized as existing)
    res2 = client.post("/sessions/sync", json=payload, headers=headers)
    assert res2.status_code == 200
    data2 = res2.json()
    assert data2["synced_motor_count"] == 0
    assert data2["synced_wellness_count"] == 0
    assert data2["existing_motor_count"] == 2
    assert data2["existing_wellness_count"] == 1

    # Verify query returns the 2 motor sessions
    motor_res = client.get("/sessions/motor", headers=headers)
    assert motor_res.status_code == 200
    assert len(motor_res.json()) == 2

    # Withdraw consent -> subsequent sync attempts must be blocked immediately!
    client.post("/consent/withdraw", headers=headers)

    new_payload = {
        "motor_sessions": [{
            "local_id": "loc-motor-103",
            "test_type": "tapping",
            "completed_at": datetime.now(timezone.utc).isoformat(),
            "cadence_taps_per_sec": 4.0
        }],
        "wellness_sessions": []
    }
    res_after_withdraw = client.post("/sessions/sync", json=new_payload, headers=headers)
    assert res_after_withdraw.status_code == 403

def test_user_isolation(client):
    # Register User 1
    reg1 = client.post("/auth/register", json={"email": "user1@example.com", "password": "password123"})
    token1 = reg1.json()["access_token"]
    headers1 = {"Authorization": f"Bearer {token1}"}
    client.put("/consent/personalization", json={"decision": "granted", "version": "1.0", "purpose": "personalization"}, headers=headers1)

    # User 1 syncs a session
    client.post("/sessions/sync", json={
        "motor_sessions": [{
            "local_id": "user1-session-1",
            "test_type": "tapping",
            "completed_at": datetime.now(timezone.utc).isoformat(),
            "total_taps": 50
        }],
        "wellness_sessions": []
    }, headers=headers1)

    # Register User 2
    reg2 = client.post("/auth/register", json={"email": "user2@example.com", "password": "password123"})
    token2 = reg2.json()["access_token"]
    headers2 = {"Authorization": f"Bearer {token2}"}
    client.put("/consent/personalization", json={"decision": "granted", "version": "1.0", "purpose": "personalization"}, headers=headers2)

    # User 2 gets motor sessions -> must be empty (cannot see User 1's data)
    user2_motor = client.get("/sessions/motor", headers=headers2)
    assert user2_motor.status_code == 200
    assert len(user2_motor.json()) == 0

    # User 1 still sees their 1 session
    user1_motor = client.get("/sessions/motor", headers=headers1)
    assert user1_motor.status_code == 200
    assert len(user1_motor.json()) == 1
    assert user1_motor.json()[0]["local_id"] == "user1-session-1"
