# Vortex-369 DAO API

## Setup Guide

1. Install Python 3.12 and pip.

2. Clone the repository: `git clone https://github.com/TeslaVortex/vortex-369-dao.git`

3. Create virtual environment: `python3 -m venv vortex_env`

4. Activate virtual environment: `source vortex_env/bin/activate`

5. Install dependencies: `pip install fastapi uvicorn web3 fastapi-limiter requests httpx pytest`

6. Run the application: `uvicorn app:app --reload`

7. For webhook testing, setup ngrok:
   - Download ngrok: `wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz`
   - Extract: `tar -xzf ngrok-v3-stable-linux-amd64.tgz`
   - Run: `./ngrok http 8000`
   - Use the provided HTTPS URL for webhook testing.

8. Access API docs at http://127.0.0.1:8000/docs

9. Run tests: `pytest test_app.py`

## Endpoints

- GET /vortex: Returns vortex status
- POST /webhook: Receives webhooks with signature validation and event parsing
- GET /dao-status: Returns DAO status
- GET /listen: Mock event listening for ETH/Solana
- GET /retrieve: Mock data retrieval
- GET /docs: Swagger UI (auto-generated)

## Notes

- Webhook requires X-Signature header for HMAC validation.
- Logs are written to api.log.
- Rate limiting is applied to /webhook (10 requests/minute).
