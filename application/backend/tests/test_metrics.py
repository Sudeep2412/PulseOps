def test_metrics_endpoint(client):
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "text/plain" in response.headers.get("Content-Type", "")
    content = response.get_data(as_text=True)
    assert "pulseops_http_requests_total" in content
    assert "pulseops_http_request_duration_seconds" in content
    assert "pulseops_app_uptime_seconds" in content
