"""
Vortex-369 DAO - Python Integration Layer
Connects Macedon Governance Engine to on-chain execution

Usage:
    from vortex_integration import VortexBridge
    
    bridge = VortexBridge(macedon_engine, chain="base")
    bridge.start()
"""

import asyncio
import json
import hashlib
import time
from dataclasses import dataclass
from typing import Optional, Dict, Any, List, Tuple
from enum import Enum

# Web3 is optional - only needed for chain interaction
try:
    from web3 import Web3
    from eth_account import Account
    HAS_WEB3 = True
except ImportError:
    HAS_WEB3 = False
    Web3 = None
    Account = None


# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

BASE_FREQUENCY = 432
PROTOCOL_FEE_BPS = 90       # 0.9%
NULL_BURN_BPS = 81          # 91% of fee → Null
DAO_SHARE_BPS = 9           # 9% of fee → DAO

CHAIN_CONFIG = {
    "base": {
        "chain_id": 8453,
        "rpc": "https://mainnet.base.org",
        "null_office": "0x0000000000000000000000000000000000000369",
        "aave": "0xA238Dd80C259a72e81d7e4664a9801593F98d1c5",
        "morpho": "0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb",
    },
    "arbitrum": {
        "chain_id": 42161,
        "rpc": "https://arb1.arbitrum.io/rpc",
        "null_office": "0x0000000000000000000000000000000000000369",
        "aave": "0x794a61358D6845594F94dc1DB02A252b5b4814aD",
        "pendle": "0x888888888889758F76e7103c6CbF23ABbF58F946",
    },
    "ethereum": {
        "chain_id": 1,
        "rpc": "https://eth.llamarpc.com",
        "null_office": "0x0000000000000000000000000000000000000369",
        "aave": "0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2",
        "morpho": "0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb",
        "sommelier": "0x7bad5DF5E11151Dc5Ee1a648800057C5c934c0d5",
    }
}

# VortexDAO ABI (simplified)
VORTEX_DAO_ABI = [
    {
        "inputs": [
            {"name": "actionType", "type": "uint8"},
            {"name": "target", "type": "address"},
            {"name": "value", "type": "uint256"},
            {"name": "data", "type": "bytes"}
        ],
        "name": "proposeAction",
        "outputs": [{"name": "actionHash", "type": "bytes32"}],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {"name": "actionHash", "type": "bytes32"},
            {"name": "witnessRecord", "type": "string"}
        ],
        "name": "advancePhase",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [{"name": "actionHash", "type": "bytes32"}],
        "name": "executeAction",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "joinAsMember",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getStats",
        "outputs": [
            {"name": "_totalYield", "type": "uint256"},
            {"name": "_totalLiquidations", "type": "uint256"},
            {"name": "_totalBurned", "type": "uint256"},
            {"name": "_currentCycle", "type": "uint256"}
        ],
        "stateMutability": "view",
        "type": "function"
    }
]


class ActionType(Enum):
    LIQUIDATION = 0
    YIELD_HARVEST = 1
    REBALANCE = 2
    COMPOUND = 3
    BURN_TO_NULL = 4


@dataclass
class SyntheticAction:
    """Action generated from Macedon synthetic data"""
    action_type: ActionType
    target: str
    value: int
    data: bytes
    witness_record: str
    proposal_id: str
    manifested: bool = False


class VortexBridge:
    """
    Bridge between Macedon Governance Engine and Vortex-369 DAO on-chain.
    
    Polls Macedon for manifested proposals and submits them to the DAO.
    """
    
    def __init__(
        self,
        macedon_engine,
        chain: str = "base",
        dao_address: str = None,
        private_key: str = None
    ):
        self.macedon = macedon_engine
        self.chain = chain
        self.config = CHAIN_CONFIG.get(chain, CHAIN_CONFIG["base"])
        
        # Web3 setup (optional)
        self.w3 = None
        self.account = None
        self.dao_contract = None
        
        if HAS_WEB3:
            self.w3 = Web3(Web3.HTTPProvider(self.config["rpc"]))
            self.dao_address = dao_address
            
            # Account setup (optional - for direct submission)
            if private_key:
                self.account = Account.from_key(private_key)
            
            # DAO contract
            if dao_address:
                self.dao_contract = self.w3.eth.contract(
                    address=Web3.to_checksum_address(dao_address),
                    abi=VORTEX_DAO_ABI
                )
        else:
            self.dao_address = dao_address
        
        # State
        self._running = False
        self._processed_proposals = set()
        self._stats = {
            "proposals_processed": 0,
            "actions_submitted": 0,
            "total_value": 0,
            "errors": 0
        }
    
    async def start(self):
        """Start the bridge polling loop."""
        self._running = True
        print(f"🌀 Vortex Bridge started on {self.chain}")
        
        while self._running:
            try:
                await self._poll_and_process()
            except Exception as e:
                print(f"❌ Bridge error: {e}")
                self._stats["errors"] += 1
            
            # Cosmic breathing: 3 second interval
            await asyncio.sleep(3)
    
    def stop(self):
        """Stop the bridge."""
        self._running = False
        print("🛑 Vortex Bridge stopped")
    
    async def _poll_and_process(self):
        """Poll Macedon and process manifested proposals."""
        # Get manifested proposals
        results = self.macedon.process_proposals()
        
        for result in results:
            if result.proposal_id in self._processed_proposals:
                continue
            
            if result.final_state.name == "MANIFESTED":
                print(f"✨ Processing manifested proposal: {result.proposal_id[:16]}...")
                
                # Convert to action
                action = self._convert_to_action(result)
                
                if action:
                    # Submit to chain
                    success = await self._submit_to_chain(action)
                    
                    if success:
                        self._stats["actions_submitted"] += 1
                        self._stats["total_value"] += action.value
                
                self._processed_proposals.add(result.proposal_id)
                self._stats["proposals_processed"] += 1
    
    def _convert_to_action(self, result) -> Optional[SyntheticAction]:
        """Convert Macedon ProcessingResult to SyntheticAction."""
        # Get proposal content from database
        if not self.macedon.db:
            return None
        
        stored = self.macedon.db.get_proposal(result.proposal_id)
        if not stored:
            return None
        
        try:
            content = json.loads(stored.content)
        except:
            content = {}
        
        # Determine action type
        action_str = content.get("action", "burn")
        action_type = {
            "liquidation": ActionType.LIQUIDATION,
            "liquidate": ActionType.LIQUIDATION,
            "harvest": ActionType.YIELD_HARVEST,
            "yield": ActionType.YIELD_HARVEST,
            "rebalance": ActionType.REBALANCE,
            "compound": ActionType.COMPOUND,
        }.get(action_str.lower(), ActionType.BURN_TO_NULL)
        
        # Build action data
        target = content.get("target", self.config["null_office"])
        value = content.get("value", 0)
        data = self._encode_action_data(action_type, content)
        
        return SyntheticAction(
            action_type=action_type,
            target=target,
            value=value,
            data=data,
            witness_record=result.witness_record,
            proposal_id=result.proposal_id,
            manifested=True
        )
    
    def _encode_action_data(self, action_type: ActionType, content: Dict) -> bytes:
        """Encode action-specific data."""
        if not HAS_WEB3 or not self.w3:
            # Return JSON-encoded data as fallback
            return json.dumps(content).encode()
        
        if action_type == ActionType.LIQUIDATION:
            # Encode liquidation params
            protocol = content.get("protocol", self.config.get("aave", ""))
            collateral = content.get("collateral", "")
            debt = content.get("debt", "")
            borrower = content.get("borrower", "")
            debt_amount = content.get("debt_amount", 0)
            
            # ABI encode
            return self.w3.codec.encode(
                ["address", "address", "address", "address", "uint256"],
                [protocol, collateral, debt, borrower, debt_amount]
            )
        
        elif action_type == ActionType.YIELD_HARVEST:
            protocol = content.get("protocol", "")
            asset = content.get("asset", "")
            return self.w3.codec.encode(["address", "address"], [protocol, asset])
        
        elif action_type == ActionType.REBALANCE:
            from_protocol = content.get("from_protocol", "")
            to_protocol = content.get("to_protocol", "")
            asset = content.get("asset", "")
            amount = content.get("amount", 0)
            return self.w3.codec.encode(
                ["address", "address", "address", "uint256"],
                [from_protocol, to_protocol, asset, amount]
            )
        
        return b""
    
    async def _submit_to_chain(self, action: SyntheticAction) -> bool:
        """Submit action to VortexDAO on-chain."""
        if not self.dao_contract or not self.account:
            print("⚠️ No DAO contract or account configured")
            return False
        
        try:
            # Build transaction
            tx = self.dao_contract.functions.proposeAction(
                action.action_type.value,
                Web3.to_checksum_address(action.target),
                action.value,
                action.data
            ).build_transaction({
                "from": self.account.address,
                "nonce": self.w3.eth.get_transaction_count(self.account.address),
                "gas": 500000,
                "gasPrice": self.w3.eth.gas_price
            })
            
            # Sign and send
            signed = self.account.sign_transaction(tx)
            tx_hash = self.w3.eth.send_raw_transaction(signed.rawTransaction)
            
            print(f"📤 Submitted: {tx_hash.hex()}")
            
            # Wait for confirmation
            receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash, timeout=60)
            
            if receipt["status"] == 1:
                print(f"✅ Confirmed in block {receipt['blockNumber']}")
                return True
            else:
                print("❌ Transaction reverted")
                return False
        
        except Exception as e:
            print(f"❌ Submission error: {e}")
            return False
    
    def get_stats(self) -> Dict:
        """Get bridge statistics."""
        return {
            **self._stats,
            "chain": self.chain,
            "dao_address": self.dao_address,
            "processed_count": len(self._processed_proposals)
        }


class LiquidationScanner:
    """
    Scans for undercollateralized positions to liquidate.
    Generates synthetic proposals for Macedon.
    """
    
    def __init__(self, macedon_engine, chain: str = "base"):
        self.macedon = macedon_engine
        self.chain = chain
        self.config = CHAIN_CONFIG.get(chain, CHAIN_CONFIG["base"])
        self.w3 = Web3(Web3.HTTPProvider(self.config["rpc"])) if HAS_WEB3 else None
    
    async def scan_aave_positions(self) -> List[Dict]:
        """Scan Aave for liquidatable positions."""
        # In production, this would query Aave's getUserAccountData
        # and find positions where healthFactor < 1
        
        positions = []
        
        # Mock data for demonstration
        # Real implementation would use Aave's Graph or direct contract calls
        
        return positions
    
    async def scan_morpho_positions(self) -> List[Dict]:
        """Scan Morpho Blue for liquidatable positions."""
        positions = []
        
        # Mock data for demonstration
        
        return positions
    
    async def create_liquidation_proposals(self):
        """Create Macedon proposals for liquidatable positions."""
        aave_positions = await self.scan_aave_positions()
        morpho_positions = await self.scan_morpho_positions()
        
        for pos in aave_positions + morpho_positions:
            content = {
                "action": "liquidation",
                "protocol": pos.get("protocol"),
                "collateral": pos.get("collateral_asset"),
                "debt": pos.get("debt_asset"),
                "borrower": pos.get("borrower"),
                "debt_amount": pos.get("debt_to_cover"),
                "value": pos.get("estimated_profit", 0)
            }
            
            success, proposal_id = self.macedon.submit_proposal(
                content,
                origin=f"liquidation_scanner:{self.chain}"
            )
            
            if success:
                print(f"📋 Created liquidation proposal: {proposal_id[:16]}...")


class YieldHarvester:
    """
    Monitors yield strategies and generates harvest proposals.
    """
    
    def __init__(self, macedon_engine, chain: str = "base"):
        self.macedon = macedon_engine
        self.chain = chain
        self.config = CHAIN_CONFIG.get(chain, CHAIN_CONFIG["base"])
    
    async def check_harvest_opportunities(self) -> List[Dict]:
        """Check for yield harvest opportunities."""
        opportunities = []
        
        # In production, check:
        # - Aave lending yields
        # - Morpho optimization
        # - Pendle PT/YT maturity
        # - Sommelier vault yields
        
        return opportunities
    
    async def create_harvest_proposals(self):
        """Create harvest proposals for pending yields."""
        opportunities = await self.check_harvest_opportunities()
        
        for opp in opportunities:
            content = {
                "action": "harvest",
                "protocol": opp.get("protocol"),
                "asset": opp.get("asset"),
                "value": opp.get("pending_yield", 0)
            }
            
            success, proposal_id = self.macedon.submit_proposal(
                content,
                origin=f"yield_harvester:{self.chain}"
            )
            
            if success:
                print(f"🌾 Created harvest proposal: {proposal_id[:16]}...")


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

async def main():
    """Demo: Run the Vortex Bridge."""
    import sys
    sys.path.insert(0, '/home/claude')
    
    from macedon_governance_engine import quick_start
    
    print("🔮 Initializing Macedon Engine...")
    engine = quick_start("vortex_demo.db")
    
    print("🌀 Starting Vortex Bridge...")
    bridge = VortexBridge(
        macedon_engine=engine,
        chain="base",
        # dao_address="0x...",  # Set when deployed
        # private_key="0x..."   # Set for direct submission
    )
    
    # Create some demo proposals
    print("📋 Creating demo proposals...")
    
    # Liquidation proposal
    engine.submit_proposal({
        "action": "liquidation",
        "protocol": CHAIN_CONFIG["base"]["aave"],
        "collateral": "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",  # WETH
        "debt": "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",  # USDC
        "borrower": "0x1234567890abcdef1234567890abcdef12345678",
        "debt_amount": 1000000000,  # 1000 USDC
        "value": 100000000000000000  # 0.1 ETH profit
    }, origin="demo")
    
    # Harvest proposal
    engine.submit_proposal({
        "action": "harvest",
        "protocol": CHAIN_CONFIG["base"]["aave"],
        "asset": "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        "value": 50000000000000000  # 0.05 ETH
    }, origin="demo")
    
    # Process through 9-phase cycle
    print("🔄 Processing proposals...")
    results = engine.process_proposals()
    
    for r in results:
        status = "✨ MANIFESTED" if r.final_state.name == "MANIFESTED" else "🌀 " + r.final_state.name
        print(f"   {r.proposal_id[:16]}... → {status}")
        if r.witness_record:
            print(f"   Witness: {r.witness_record}")
    
    print("\n📊 Bridge Stats:")
    print(f"   Chain: {bridge.chain}")
    print(f"   Proposals processed: {len(results)}")
    
    # Cleanup
    engine.shutdown()
    print("\n3 · 6 · 9\nThe Vortex closes.")


if __name__ == "__main__":
    asyncio.run(main())
