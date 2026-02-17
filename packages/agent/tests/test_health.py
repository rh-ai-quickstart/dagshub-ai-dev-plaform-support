"""Tests for agent health endpoint."""


def test_health_check(client):
    """Test that health endpoint returns healthy status."""
    response = client.get("/agent/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "agent"
