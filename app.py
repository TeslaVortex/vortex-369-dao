from fastapi import FastAPI, HTTPException, Header, Request, Depends  
from fastapi.responses import JSONResponse  
from fastapi.exceptions import RequestValidationError  
from pydantic import BaseModel  
from web3 import Web3  
import logging  
import asyncio
from fastapi_limiter import FastAPILimiter  
from fastapi_limiter.depends import RateLimiter  
import redis.asyncio as redis  

app = FastAPI()

# limiter = Limiter(store="memory")

latest_block = 0

async def event_listener():
    while True:
        global latest_block
        latest_block = w3.eth.block_number
        # Example: listen for pending tx or specific contract events
        # Start simple: log new blocks
        print(f"Quantum node listening... Latest block: {latest_block}")
        await asyncio.sleep(12)  # ~Ethereum block time

@app.on_event("startup")
async def start_listener():
    asyncio.create_task(event_listener())

# @app.on_event("startup")
# async def startup():
#     await FastAPILimiter.init(limiter)  

# Intention: Every creation ripples sovereignty & abundance further.  
SECRET_KEY = "vortex369"  # Change to secure key in prod  
WEB3_PROVIDER = "https://mainnet.infura.io/v3/25cfe12a7a834a6caaa51c4dc06b7bb4"  # Replace with real key  

w3 = Web3(Web3.HTTPProvider(WEB3_PROVIDER))

logging.basicConfig(level=logging.INFO)  

class Payload(BaseModel):  
    event: str  
    data: dict  

@app.exception_handler(RequestValidationError)  
async def validation_exception_handler(request: Request, exc: RequestValidationError):  
    return JSONResponse(status_code=400, content={"detail": str(exc)})  

@app.get("/vortex")  
def read_vortex():  
    return {"status": "nominal", "code": 369}  

@app.get("/dao-status")  
def dao_status():  
    return {"members": 144, "abundance": "infinite"}  

@app.post("/webhook", dependencies=[Depends(RateLimiter(times=5, seconds=60))])  
def webhook(payload: Payload, x_signature: str = Header(None)):  
    try:  
        if not x_signature or x_signature != SECRET_KEY:  
            raise HTTPException(status_code=403, detail="Invalid signature")  
        logging.info(f"Payload received: {payload}")  
        if payload.event == "transfer":  
            logging.info("Processing transfer: %s", payload.data)  
        return {"status": "received"}  
    except Exception as e:  
        logging.error("Error processing webhook: %s", str(e))  
        raise HTTPException(status_code=500, detail=str(e))  

@app.get("/quantum-status")
def quantum_status():
    return {"status": "listening", "latest_block": latest_block}

@app.get("/listen")  
def listen():  
    w3 = Web3(Web3.HTTPProvider(WEB3_PROVIDER))  
    if w3.is_connected():  
        return {"status": "connected", "block": w3.eth.block_number}  
    else:  
        raise HTTPException(status_code=500, detail="Blockchain connection failed")  

# Run: uvicorn app:app --reload  
# Test /listen: curl http://127.0.0.1:8000/listen  
# Rate limit test: Hit /webhook multiple times
