def test_workload_get(client):
    response = client.get("/api/v1/workload?items=3")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "success"
    assert data["processed_items"] == 3
    assert len(data["items"]) == 3

def test_workload_post(client):
    response = client.post("/api/v1/workload", json={"items": 4})
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "success"
    assert data["processed_items"] == 4

def test_simulate_error(client):
    for code in (400, 404, 500, 503):
        response = client.get(f"/api/v1/simulate-error?code={code}")
        assert response.status_code == code
        data = response.get_json()
        assert data["error"] is True
        assert data["status_code"] == code

def test_simulate_latency(client):
    response = client.get("/api/v1/simulate-latency?delay=0.05")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "success"
    assert data["injected_delay_seconds"] == 0.05

def test_system_info(client):
    response = client.get("/api/v1/system-info")
    assert response.status_code == 200
    data = response.get_json()
    assert "platform" in data
    assert "python_version" in data
    assert "cpu_count" in data
