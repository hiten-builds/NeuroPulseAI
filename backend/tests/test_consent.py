def test_consent_lifecycle(client):
    reg = client.post("/auth/register", json={"email": "dan@example.com", "password": "password123"})
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. No consent initially recorded -> 404
    get_res = client.get("/consent", headers=headers)
    assert get_res.status_code == 404

    # 2. Grant consent for personalization
    grant_res = client.put(
        "/consent/personalization",
        json={"decision": "granted", "version": "1.0", "purpose": "personalization"},
        headers=headers
    )
    assert grant_res.status_code == 200
    assert grant_res.json()["decision"] == "granted"
    assert grant_res.json()["current_status"] == "active"

    # 3. Verify consent query returns active
    verify_res = client.get("/consent", headers=headers)
    assert verify_res.status_code == 200
    assert verify_res.json()["decision"] == "granted"
    assert verify_res.json()["current_status"] == "active"

    # 4. Decline consent
    decline_res = client.put(
        "/consent/personalization",
        json={"decision": "declined", "version": "1.0", "purpose": "personalization"},
        headers=headers
    )
    assert decline_res.status_code == 200
    assert decline_res.json()["decision"] == "declined"
    assert decline_res.json()["current_status"] == "declined"

    # 5. Grant consent again then withdraw
    client.put(
        "/consent/personalization",
        json={"decision": "granted", "version": "1.0", "purpose": "personalization"},
        headers=headers
    )
    withdraw_res = client.post("/consent/withdraw", headers=headers)
    assert withdraw_res.status_code == 200
    assert withdraw_res.json()["current_status"] == "withdrawn"
    assert withdraw_res.json()["withdrawal_timestamp"] is not None
