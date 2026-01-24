from fastapi.testclient import TestClient
from app import app
import hmac
import hashlib
import json

client = TestClient(app)

SECRET_KEY = "vortex369secret"

def compute_signature(payload):
    payload_str = json.dumps(payload, separators=(',', ':'), sort_keys=True)
    return hmac.new(SECRET_KEY.encode(), payload_str.encode(), hashlib.sha256).hexdigest()

def test_vortex():
    response = client.get("/vortex")
    assert response.status_code == 200
    assert response.json() == {"status": "nominal", "code": 369}

def test_webhook():
    payload = {"event": "transfer", "data": "sample"}
    signature = compute_signature(payload)
    response = client.post("/webhook", json=payload, headers={"X-Signature": signature})
    assert response.status_code == 200
    assert response.json() == {"status": "received"}

def test_dao_status():
    response = client.get("/dao-status")
    assert response.status_code == 200
    assert response.json() == {"members": 144, "abundance": "infinite"}
