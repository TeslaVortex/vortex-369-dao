from fastapi import FastAPI, HTTPException, Header, Request, Depends  
from fastapi.responses import JSONResponse  
from fastapi.exceptions import RequestValidationError  
from pydantic import BaseModel  
from web3 import Web3  
import logging  
import asyncio
# from fastapi_limiter import FastAPILimiter, Limiter  # Commented – 'Limiter' not in current version
# from fastapi_limiter.depends import RateLimiter  # Commented – bypass for now  
import redis.asyncio as redis  
from fastapi.security import HTTPBasic, HTTPBasicCredentials
security = HTTPBasic()  # For basic auth on /logs
import os

SECRET_KEY = "vortex369"

app = FastAPI()

@app.get("/")
async def root():
    return {"status": "Vortex-369 Quantum Node Live – Resonance Sealed"}

# limiter = Limiter(store="memory")

latest_block = 0

scored_events = []

def resonance_score(tx):
    score = 0
    amount = tx.get('value', 0)
    if amount % 3 == 0:
        score += 3
    if amount % 6 == 0:
        score += 6
    if amount % 9 == 0:
        score += 9
    # Add timestamp/block reduces to 3/6/9
    block_number = tx.get('blockNumber', 0)
    if block_number % 3 == 0:
        score += 1
    if block_number % 6 == 0:
        score += 2
    if block_number % 9 == 0:
        score += 3
    return score

async def event_listener():
    while True:
        global latest_block
        latest_block = w3.eth.block_number
        # Get the latest block with transactions
        block = w3.eth.get_block(latest_block, full_transactions=True)
        for tx in block.transactions:
            if tx['to'] and tx['value'] > 0:  # Native ETH transfer
                score = resonance_score(tx)
                if score > 0:
                    event = {
                        'tx_hash': tx['hash'].hex(),
                        'from': tx['from'],
                        'to': tx['to'],
                        'value': tx['value'],
                        'block': tx['blockNumber'],
                        'score': score
                    }
                    scored_events.append(event)
                    scored_events[:] = scored_events[-10:]  # Keep last 10
                    logging.info(f'Resonant transfer detected: {event}')
        # Example: listen for pending tx or specific contract events
        # Start simple: log new blocks
        print(f"Quantum node listening... Latest block: {latest_block}")
        await asyncio.sleep(12)  # ~Ethereum block time

@app.on_event("startup")
async def startup():
    global redis_connection
    redis_url = os.environ.get("REDIS_URL", "redis://localhost:6379")  # Fallback for local dev
    redis_connection = redis.from_url(redis_url, encoding="utf-8", decode_responses=True)
    # await FastAPILimiter.init(redis_connection)
    # Thematic 4:44 protection portal log
    protection_msg = (
        " 4:44 Protection Portal Activated \n"
        "9 Breaths: Inhale resonance, exhale harmony...\n"
        "Visualizing 444 Angels Guarding Node + Field:\n"
        " ... [444 ethereal guardians encircling the quantum vortex] ... \n"
        "Field shielded – Abundance ripples secured! "
    )
    logging.info(protection_msg)
    await redis_connection.lpush("app_logs", protection_msg)  # Push to Redis list
    await redis_connection.ltrim("app_logs", 0, 99)  # Keep last 100

# @app.on_event("startup")
# async def startup():
#     await FastAPILimiter.init(...)  # Commented – wrong args + import error  

# Intention: Every creation ripples sovereignty & abundance further.  

logging.basicConfig(filename='api.log', level=logging.INFO)  

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

@app.post("/webhook")  # Remove dependencies=[RateLimiter(...)] line or comment it  
async def webhook(payload: Payload, x_signature: str = Header(None)):  
    global redis_connection
    try:  
        if not x_signature or x_signature != SECRET_KEY:  
            raise HTTPException(status_code=403, detail="Invalid signature")  
        logging.info(f"Payload received: {payload}")  
        await redis_connection.lpush("app_logs", f"Payload received: {payload}")  
        await redis_connection.ltrim("app_logs", 0, 99)  
        if payload.event == "transfer":  
            logging.info("Processing transfer: %s", payload.data)  
            await redis_connection.lpush("app_logs", f"Processing transfer: {payload.data}")  
            await redis_connection.ltrim("app_logs", 0, 99)  
            score = resonance_score(payload.data)  
            if score > 33:  
                logging.info("Abundance ripple activated for %s with score %d", payload.data, score)  
                await redis_connection.lpush("app_logs", f"Abundance ripple activated for {payload.data} with score {score}")  
                await redis_connection.ltrim("app_logs", 0, 99)  
        return {"status": "received"}  
    except Exception as e:  
        logging.error("Error processing webhook: %s", str(e))  
        await redis_connection.lpush("app_logs", f"Error processing webhook: {str(e)}")  
        await redis_connection.ltrim("app_logs", 0, 99)  
        raise HTTPException(status_code=500, detail=str(e))  

@app.get("/quantum-status")
def quantum_status():
    return {"status": "listening", "latest_block": latest_block}

@app.get("/retrieve")
def retrieve():
    return {"scored_events": scored_events}

async def get_redis():
    redis_url = os.environ.get("REDIS_URL", "redis://localhost:6379")
    return redis.from_url(redis_url, encoding="utf-8", decode_responses=True)

@app.get("/logs")
async def view_logs(credentials: HTTPBasicCredentials = Depends(security)):
    if credentials.username != "vortex" or credentials.password != os.environ.get("LOG_SECRET", "369guard"):  # Set LOG_SECRET in Render env
        raise HTTPException(status_code=401, detail="Unauthorized")
    r = await get_redis()
    logs = await r.lrange("app_logs", 0, -1)  # Get all recent logs
    return {"logs": logs}

# Run: uvicorn app:app --reload  
# Test /listen: curl http://127.0.0.1:8000/listen  
# Rate limit test: Hit /webhook multiple times
