from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")
    assert response.status_code == 200


def test_predict() -> None:
    response = client.post(
        "/predict",
        json={"description": "AWS monthly server bill", "amount": 12400},
    )
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data["category"], str)
    assert 0 <= data["confidence"] <= 1
    assert len(data["top_predictions"]) == 3
