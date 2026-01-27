from fastapi import FastAPI, HTTPException, Header, Request, Depends, Query, Form  
from fastapi.responses import JSONResponse  
from fastapi.exceptions import RequestValidationError  
from pydantic import BaseModel  
from web3 import Web3  
import logging  
import asyncio
from fastapi_limiter import FastAPILimiter
from fastapi_limiter.depends import RateLimiter  
import redis.asyncio as redis  
from fastapi.security import HTTPBasic, HTTPBasicCredentials
security = HTTPBasic()  # For basic auth on /logs
import os
import time

SECRET_KEY = "vortex369"

WEB3_PROVIDER = os.environ.get("WEB3_PROVIDER", "https://base-mainnet.infura.io/v3/25cfe12a7a834a6caaa51c4dc06b7bb4")
DAO_TREASURY_ADDRESS = os.environ.get("DAO_TREASURY_ADDRESS", "0xd8cEab88126a024A0c65449a9AF7621C258161fD")

app = FastAPI()

@app.get("/")
async def root():
    return {"status": "Vortex-369 Quantum Node Live – Resonance Sealed"}

# limiter = Limiter(store="memory")


latest_block = 0

scored_events = []

app_logs = []

redis_connection = None

cached_balance = {"value": None, "timestamp": 0}
CACHE_TTL = 30

proposals = []

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
    await FastAPILimiter.init(redis_connection)
    # Thematic 4:44 protection portal log
    protection_msg = (
        " 4:44 Protection Portal Activated \n"
        "9 Breaths: Inhale resonance, exhale harmony...\n"
        "Visualizing 444 Angels Guarding Node + Field:\n"
        " ... [444 ethereal guardians encircling the quantum vortex] ... \n"
        "Field shielded – Abundance ripples secured! "
    )
    logging.info(protection_msg)
    app_logs.append(protection_msg)
    app_logs[:] = app_logs[-100:]

# @app.on_event("startup")
# async def startup():
#     await FastAPILimiter.init(...)  # Commented – wrong args + import error  

# Intention: Every creation ripples sovereignty & abundance further.  

logging.basicConfig(filename='api.log', level=logging.INFO)  

class Payload(BaseModel):  
    event: str  
    data: dict  

class Proposal(BaseModel):  
    title: str  
    description: str  
    allocation_amount: str  
    proposer: str  

@app.exception_handler(RequestValidationError)  
async def validation_exception_handler(request: Request, exc: RequestValidationError):  
    return JSONResponse(status_code=400, content={"detail": str(exc)})  

@app.get("/vortex")  
def read_vortex():  
    return {"status": "nominal", "code": 369}  

@app.get("/dao-status")  
def dao_status():  
    return {"members": 144, "abundance": "infinite"}  

@app.get("/listen")
def listen():
    w3 = Web3(Web3.HTTPProvider(WEB3_PROVIDER))
    if w3.is_connected():
        return {"status": "connected", "block": w3.eth.block_number}
    else:
        raise HTTPException(status_code=500, detail="Blockchain connection failed")

@app.post("/webhook")  # Remove dependencies=[RateLimiter(...)] line or comment it  
async def webhook(payload: Payload, x_signature: str = Header(None)):  
    # global redis_connection
    try:  
        if not x_signature or x_signature != SECRET_KEY:  
            raise HTTPException(status_code=403, detail="Invalid signature")  
        logging.info(f"Payload received: {payload}")
        app_logs.append(f"Payload received: {payload}")
        app_logs[:] = app_logs[-100:]  
        if payload.event == "transfer":  
            logging.info("Processing transfer: %s", payload.data)
            app_logs.append(f"Processing transfer: {payload.data}")
            app_logs[:] = app_logs[-100:]  
            score = resonance_score(payload.data)  
            if score > 33:  
                logging.info("Abundance ripple activated for %s with score %d", payload.data, score)
                app_logs.append(f"Abundance ripple activated for {payload.data} with score {score}")
                app_logs[:] = app_logs[-100:]  
        return {"status": "received"}  
    except Exception as e:  
        logging.error("Error processing webhook: %s", str(e))
        app_logs.append(f"Error processing webhook: {str(e)}")
        app_logs[:] = app_logs[-100:]  
        raise HTTPException(status_code=500, detail=str(e))  

@app.get("/quantum-status")
def quantum_status():
    return {"status": "listening", "latest_block": latest_block}

@app.get("/retrieve")
def retrieve():
    return {"scored_events": scored_events}


@app.get("/logs")
def view_logs(credentials: HTTPBasicCredentials = Depends(security)):
    if credentials.username != "vortex" or credentials.password != os.environ.get("LOG_SECRET", "369guard"):  # Set LOG_SECRET in Render env
        raise HTTPException(status_code=401, detail="Unauthorized")
    return {"logs": app_logs}

@app.get("/balance", dependencies=[Depends(RateLimiter(times=10, seconds=60))])
def get_balance():
    now = time.time()
    if now - cached_balance["timestamp"] < CACHE_TTL and cached_balance["value"]:
        return cached_balance["value"]
    w3 = Web3(Web3.HTTPProvider(WEB3_PROVIDER))
    if not w3.is_connected():
        raise HTTPException(status_code=500, detail="Blockchain connection failed")
    balance_wei = w3.eth.get_balance(DAO_TREASURY_ADDRESS)
    balance_eth = w3.from_wei(balance_wei, 'ether')
    result = {"address": DAO_TREASURY_ADDRESS, "balance_wei": balance_wei, "balance_eth": str(balance_eth)}
    cached_balance["value"] = result
    cached_balance["timestamp"] = now
    return result

@app.get("/transactions", dependencies=[Depends(RateLimiter(times=10, seconds=60))])
def get_transactions(limit: int = Query(10, ge=1, le=50)):
    w3 = Web3(Web3.HTTPProvider(WEB3_PROVIDER))
    if not w3.is_connected():
        raise HTTPException(status_code=500, detail="Blockchain connection failed")
    current_block = w3.eth.block_number
    transactions = []
    blocks_to_check = 100  # Check last 100 blocks for transactions
    for i in range(blocks_to_check):
        block_num = current_block - i
        if block_num < 0:
            break
        try:
            block = w3.eth.get_block(block_num, full_transactions=True)
            for tx in block.transactions:
                if tx['to'] == DAO_TREASURY_ADDRESS or tx['from'] == DAO_TREASURY_ADDRESS:
                    tx_data = {
                        'hash': tx['hash'].hex(),
                        'from': tx['from'],
                        'to': tx['to'],
                        'value': str(tx['value']),
                        'blockNumber': tx['blockNumber'],
                        'timestamp': block['timestamp']
                    }
                    transactions.append(tx_data)
                    if len(transactions) >= limit:
                        return {"transactions": transactions}
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error fetching block {block_num}: {str(e)}")
    return {"transactions": transactions}

@app.post("/proposals", dependencies=[Depends(RateLimiter(times=10, seconds=60))])
def submit_proposal(proposal: Proposal):
    proposal_id = len(proposals) + 1
    new_proposal = {
        "id": proposal_id,
        "title": proposal.title,
        "description": proposal.description,
        "allocation_amount": proposal.allocation_amount,
        "proposer": proposal.proposer,
        "votes": {},
        "status": "active",
        "created_at": time.time()
    }
    proposals.append(new_proposal)
    return {"message": "Proposal submitted", "id": proposal_id}

@app.get("/proposals", dependencies=[RateLimiter(times=10, seconds=60)])
def list_proposals():
    for proposal in proposals:
        yes = sum(1 for v in proposal["votes"].values() if v == "yes")
        no = sum(1 for v in proposal["votes"].values() if v == "no")
        if len(proposal["votes"]) > 5 and yes > no:
            proposal["status"] = "approved"
        else:
            proposal["status"] = "active"
    return {"proposals": proposals}

@app.post("/proposals/{proposal_id}/vote", dependencies=[Depends(RateLimiter(times=10, seconds=60))])
def vote_on_proposal(proposal_id: int, voter: str = Form(...), vote: str = Form(...)):
    if vote not in ["yes", "no"]:
        raise HTTPException(status_code=400, detail="Vote must be yes or no")
    for proposal in proposals:
        if proposal["id"] == proposal_id:
            if proposal["status"] != "active":
                raise HTTPException(status_code=400, detail="Proposal not active")
            proposal["votes"][voter] = vote
            return {"message": "Vote recorded"}
    raise HTTPException(status_code=404, detail="Proposal not found")

# Run: uvicorn app:app --reload  
# Test /listen: curl http://127.0.0.1:8000/listen  
# Rate limit test: Hit /webhook multiple times
