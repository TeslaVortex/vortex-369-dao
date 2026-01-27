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

PROPOSAL_CONTRACT_ADDRESS = "0x31Fd16Ab177689D7Fe4022eBe966A0ff5Be86484"
PROPOSAL_ABI = [{"inputs":[{"internalType":"address","name":"_vortexDAO","type":"address"},{"internalType":"address payable","name":"_treasuryVault","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"id","type":"uint256"},{"indexed":false,"internalType":"address","name":"proposer","type":"address"},{"indexed":false,"internalType":"string","name":"description","type":"string"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":false,"internalType":"address","name":"recipient","type":"address"},{"indexed":false,"internalType":"uint256","name":"score","type":"uint256"}],"name":"ProposalCreated","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"id","type":"uint256"}],"name":"ProposalExecuted","type":"event"},{"inputs":[{"internalType":"string","name":"desc","type":"string"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"blockNum","type":"uint256"}],"name":"calculateScore","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"executeQueued","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"nextId","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"proposals","outputs":[{"internalType":"address","name":"proposer","type":"address"},{"internalType":"string","name":"description","type":"string"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"score","type":"uint256"},{"internalType":"uint256","name":"queuedTime","type":"uint256"},{"internalType":"bool","name":"executed","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"desc","type":"string"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"address","name":"recipient","type":"address"}],"name":"propose","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"treasuryVault","outputs":[{"internalType":"contract TreasuryVault","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"vortexDAO","outputs":[{"internalType":"contract VortexDAO","name":"","type":"address"}],"stateMutability":"view","type":"function"}]

app = FastAPI()

@app.get("/")
async def root():
    return {"status": "Vortex-369 Quantum Node Live – Resonance Sealed"}

# limiter = Limiter(store="memory")


latest_block = 0

scored_events = []

app_logs = []

redis_connection = None

w3 = None
account = None
proposal_contract = None

cached_balance = {"value": None, "timestamp": 0}
CACHE_TTL = 30

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
    global redis_connection, w3, account, proposal_contract, private_key
    redis_url = os.environ.get("REDIS_URL", "redis://localhost:6379")  # Fallback for local dev
    redis_connection = redis.from_url(redis_url, encoding="utf-8", decode_responses=True)
    await FastAPILimiter.init(redis_connection)
    w3 = Web3(Web3.HTTPProvider(WEB3_PROVIDER))
    if not w3.is_connected():
        raise ValueError("Web3 not connected")
    private_key = os.getenv('DAO_PRIVATE_KEY')
    if not private_key:
        raise ValueError("DAO_PRIVATE_KEY not set")
    account = w3.eth.account.from_key(private_key)
    proposal_contract = w3.eth.contract(address=PROPOSAL_CONTRACT_ADDRESS, abi=PROPOSAL_ABI)
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
    description: str  
    amount: int  
    recipient: str  

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

@app.post("/webhook")  # Remove dependencies=[Depends(RateLimiter(...)] line or comment it  
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
    try:
        nonce = w3.eth.get_transaction_count(account.address)
        tx = proposal_contract.functions.propose(proposal.description, proposal.amount, proposal.recipient).build_transaction({
            'chainId': 8453,
            'gas': 200000,
            'gasPrice': w3.eth.gas_price,
            'nonce': nonce,
        })
        signed_tx = w3.eth.account.sign_transaction(tx, private_key)
        tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
        return {"message": "Proposal submitted", "tx_hash": tx_hash.hex()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/proposals", dependencies=[Depends(RateLimiter(times=10, seconds=60))])
def list_proposals():
    try:
        next_id = proposal_contract.functions.nextId().call()
        proposals = []
        for i in range(next_id):
            prop = proposal_contract.functions.proposals(i).call()
            proposals.append({
                "id": i,
                "proposer": prop[0],
                "description": prop[1],
                "amount": prop[2],
                "recipient": prop[3],
                "score": prop[4],
                "queuedTime": prop[5],
                "executed": prop[6]
            })
        return {"proposals": proposals}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/proposals/{proposal_id}/execute", dependencies=[Depends(RateLimiter(times=10, seconds=60))])
def execute_proposal(proposal_id: int):
    try:
        nonce = w3.eth.get_transaction_count(account.address)
        tx = proposal_contract.functions.executeQueued(proposal_id).build_transaction({
            'chainId': 8453,
            'gas': 200000,
            'gasPrice': w3.eth.gas_price,
            'nonce': nonce,
        })
        signed_tx = w3.eth.account.sign_transaction(tx, private_key)
        tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
        return {"message": "Execution attempted", "tx_hash": tx_hash.hex()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Run: uvicorn app:app --reload  
# Test /listen: curl http://127.0.0.1:8000/listen  
# Rate limit test: Hit /webhook multiple times
