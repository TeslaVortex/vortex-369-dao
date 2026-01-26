import requests
import hmac
import hashlib
import json

SECRET_KEY = "vortex369"

def compute_signature(payload):
    payload_str = json.dumps(payload, separators=(',', ':'), sort_keys=True)
    return hmac.new(SECRET_KEY.encode(), payload_str.encode(), hashlib.sha256).hexdigest()

# Test with valid event
payload_valid = {"event": "transfer", "data": {"sample": "value"}}
signature_valid = compute_signature(payload_valid)
print("Valid payload:", json.dumps(payload_valid, separators=(',', ':'), sort_keys=True))
print("Signature:", signature_valid)
response = requests.post('http://127.0.0.1:8000/webhook', json=payload_valid, headers={'X-Signature': SECRET_KEY})
print("Valid event response:", response.status_code, response.json() if response.status_code == 200 else response.text)

# Test with invalid event
payload_invalid = {"event": "invalid", "data": {"sample": "value"}}
signature_invalid = compute_signature(payload_invalid)
response = requests.post('http://127.0.0.1:8000/webhook', json=payload_invalid, headers={'X-Signature': SECRET_KEY})
print("Invalid event response:", response.status_code, response.text)

# Test with missing event
payload_missing = {"data": {"sample": "value"}}
signature_missing = compute_signature(payload_missing)
response = requests.post('http://127.0.0.1:8000/webhook', json=payload_missing, headers={'X-Signature': SECRET_KEY})
print("Missing event response:", response.status_code, response.text)
