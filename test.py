import requests

# Test /vortex
response = requests.get('http://127.0.0.1:8000/vortex')
print('/vortex:', response.json())

# Test /resonance
response = requests.get('http://127.0.0.1:8000/resonance')
print('/resonance:', response.json())
