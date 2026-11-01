def test_404_error_handler(client):
    response = client.get("/non-existent-endpoint")
    assert response.status_code == 404
    data = response.get_json()
    assert data["error"] == "Not Found"
    assert data["status_code"] == 404

def test_405_method_not_allowed(client):
    response = client.post("/health")
    assert response.status_code == 405
    data = response.get_json()
    assert data["error"] == "Method Not Allowed"
