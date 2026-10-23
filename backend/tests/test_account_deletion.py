from datetime import datetime, timezone

def test_delete_remote_data_preserves_account(client):
    reg = client.post("/auth/register", json={"email": "judy@example.com", "password": "password123"})
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    client.put("/consent/personalization", json={"decision": "granted", "version": "1.0", "purpose": "personalization"}, headers=headers)

    # Sync a session
    client.post("/sessions/sync", json={
        "motor_sessions": [{
            "local_id": "judy-motor-1",
            "test_type": "tapping",
            "completed_at": datetime.now(timezone.utc).isoformat(),
            "total_taps": 35
        }],
        "wellness_sessions": []
    }, headers=headers)

    # Verify session exists
    assert len(client.get("/sessions/motor", headers=headers).json()) == 1

    # Request deletion of remote data
    del_res = client.delete("/account/data", headers=headers)
    assert del_res.status_code == 200
    assert del_res.json()["status"] == "success"
    assert del_res.json()["deleted_motor_sessions"] == 1
    assert del_res.json()["consent_withdrawn"] is True

    # Motor sessions now empty
    assert len(client.get("/sessions/motor", headers=headers).json()) == 0

    # User account still exists and can access /auth/me
    me_res = client.get("/auth/me", headers=headers)
    assert me_res.status_code == 200
    assert me_res.json()["email"] == "judy@example.com"

    # Subsequent sync returns 403 Forbidden because consent was withdrawn
    sync_res = client.post("/sessions/sync", json={
        "motor_sessions": [{
            "local_id": "judy-motor-2",
            "test_type": "tapping",
            "completed_at": datetime.now(timezone.utc).isoformat()
        }],
        "wellness_sessions": []
    }, headers=headers)
    assert sync_res.status_code == 403
