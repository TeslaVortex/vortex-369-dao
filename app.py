from fastapi import FastAPI, Request, HTTPException
import hmac
import hashlib
import json
from web3 import Web3
# from fastapi_limiter import FastAPILimiter, Limiter
import logging

app = FastAPI()

SECRET_KEY = "vortex369secret"

# limiter = Limiter(store="memory")

logging.basicConfig(filename='api.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# @app.on_event("startup")
# async def startup():
#     await FastAPILimiter.init(limiter)

@app.get("/vortex")
def read_vortex():
    logging.info("Endpoint /vortex accessed")
    return {"status": "nominal", "code": 369}

# Every creation ripples sovereignty & abundance further.

@app.get("/resonance")
def quantum_resonance():
    logging.info("Endpoint /resonance accessed")
    return {"status": "nominal", "code": 369}

# @limiter.limit("10/minute")
@app.post("/webhook")
def webhook_receiver(request: Request, payload: dict):
    try:
        signature = request.headers.get("X-Signature")
        if not signature:
            raise HTTPException(status_code=401, detail="Missing signature")
        
        payload_str = json.dumps(payload, separators=(',', ':'), sort_keys=True)
        expected_signature = hmac.new(SECRET_KEY.encode(), payload_str.encode(), hashlib.sha256).hexdigest()
        
        if not hmac.compare_digest(signature, expected_signature):
            raise HTTPException(status_code=401, detail="Invalid signature")
        
        VALID_EVENTS = ["transfer", "vote"]
        event = payload.get("event")
        if not event or event not in VALID_EVENTS:
            raise HTTPException(status_code=400, detail="Invalid or missing event")
        
        print("Received webhook payload:", payload)
        logging.info(f"Webhook received: {payload}")
        return {"status": "received"}
    except Exception as e:
        print("Error processing webhook:", e)
        raise HTTPException(status_code=400, detail="Bad payload")

@app.get("/dao-status")
def dao_status():
    logging.info("DAO status queried")
    return {"members": 144, "abundance": "infinite"}

@app.get("/listen")
def listen_events():
    logging.info("Event listener accessed")
    # Mock connection to ETH/Solana RPC
    # For ETH: w3 = Web3(Web3.HTTPProvider('https://mainnet.infura.io/v3/YOUR_PROJECT_ID'))
    # For Solana: # Would need solana-py
    # Mock events
    return {"events": ["transfer: 1 ETH from 0x123 to 0x456", "vote: approved"]}

@app.get("/retrieve")
def retrieve_data():
    logging.info("DAO data retrieved")
    return {"balance": 1000, "address": "0x123", "dao_name": "Vortex-369"}
