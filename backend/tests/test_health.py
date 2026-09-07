from fastapi.testclient import TestClient

from app.main import app

# NOTE: not using `with TestClient(app)` so the lifespan (DB create_all) is
# not triggered - these tests must run without PostgreSQL/Redis.
client = TestClient(app)


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Rahpeyman API"}


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert body["service"] == "rahpeyman-api"
