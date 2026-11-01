def test_health_endpoint(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"
    assert data["service"] == "PulseOps"
    assert "uptime_seconds" in data
    assert "timestamp" in data

def test_ready_endpoint(client):
    response = client.get("/ready")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "ready"
    assert data["checks"]["memory"] == "ok"
    assert data["checks"]["routing"] == "ok"
    assert data["checks"]["observability"] == "ok"
