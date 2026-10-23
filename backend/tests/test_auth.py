def test_register_success(client):
    response = client.post(
        "/auth/register",
        json={"email": "alice@example.com", "password": "password123"}
    )
    assert response.status_code == 201
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"
    assert data["user"]["email"] == "alice@example.com"
    assert "id" in data["user"]

def test_register_duplicate_email(client):
    client.post("/auth/register", json={"email": "alice@example.com", "password": "password123"})
    response = client.post("/auth/register", json={"email": "alice@example.com", "password": "password123"})
    assert response.status_code == 409
    assert "already exists" in response.json()["detail"]

def test_login_success(client):
    client.post("/auth/register", json={"email": "bob@example.com", "password": "securePassword456"})
    response = client.post("/auth/login", json={"email": "bob@example.com", "password": "securePassword456"})
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["user"]["email"] == "bob@example.com"

def test_login_invalid_password(client):
    client.post("/auth/register", json={"email": "bob@example.com", "password": "securePassword456"})
    response = client.post("/auth/login", json={"email": "bob@example.com", "password": "wrongPassword"})
    assert response.status_code == 401
    assert "Incorrect email or password" in response.json()["detail"]

def test_get_profile_authenticated(client):
    reg = client.post("/auth/register", json={"email": "carol@example.com", "password": "password123"})
    token = reg.json()["access_token"]
    
    headers = {"Authorization": f"Bearer {token}"}
    response = client.get("/auth/me", headers=headers)
    assert response.status_code == 200
    assert response.json()["email"] == "carol@example.com"

def test_get_profile_unauthorized(client):
    response = client.get("/auth/me")
    assert response.status_code == 401
