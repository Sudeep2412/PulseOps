def test_home_json_default(client):
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert data["service"] == "PulseOps Core Engine"
    assert data["status"] == "operational"
    assert "endpoints" in data

def test_home_html(client):
    response = client.get("/", headers={"Accept": "text/html"})
    assert response.status_code == 200
    assert "PulseOps Engine" in response.get_data(as_text=True)
