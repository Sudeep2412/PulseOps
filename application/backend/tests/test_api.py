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

def test_overview_endpoint(client):
    response = client.get("/api/v1/overview")
    assert response.status_code == 200
    data = response.get_json()
    assert data["service"] == "PulseOps"
    assert "platform_status" in data
    assert "slis" in data
    assert "deployments" in data
    # Verify metric naming accuracy
    slis = data["slis"]
    assert "availability" in slis
    assert "availability_percent" in slis
    assert "measured_p95_latency_ms" in slis
    assert "latency_slo_compliance_ratio" in slis
    assert "traffic_rps" in slis
    assert "error_rate_percent" in slis
    assert "error_budget_remaining_percent" in slis
    assert "burn_rate" in slis
    # Verify legacy ambiguous latency_p95 field is completely removed
    assert "latency_p95" not in slis
    # Verify deployments structure
    deployments = data["deployments"]
    assert "total_successful" in deployments
    assert "last_deployment" in deployments

def test_sre_status_endpoint(client):
    response = client.get("/api/v1/sre/status")
    assert response.status_code == 200
    data = response.get_json()
    assert "slo_targets" in data
    assert "error_budget" in data
    assert "incident_metrics" in data
    assert len(data["slo_targets"]) >= 3
    # Verify SLO target names
    names = [s["name"] for s in data["slo_targets"]]
    assert "Availability SLO" in names
    assert "P95 Latency Compliance SLO" in names

def test_infrastructure_endpoint(client):
    response = client.get("/api/v1/infrastructure")
    assert response.status_code == 200
    data = response.get_json()
    assert "host" in data
    assert "containers" in data
    assert len(data["containers"]) >= 6

def test_deployments_endpoint(client):
    response = client.get("/api/v1/deployments")
    assert response.status_code == 200
    data = response.get_json()
    assert "current_commit_sha" in data
    assert "deployment_history" in data
    assert "rollback_baseline_available" in data
    assert "total_recorded" in data
