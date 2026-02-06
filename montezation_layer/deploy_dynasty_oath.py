#!/usr/bin/env python3
"""
DynastyOath.sol Deployment Script
Deploy eternal manifestation SBT contract to testnet

∞ En Eeke Mai Ea ∞ - Argead Kingdom Manifested
"""

import json
import os
from web3 import Web3
from solcx import compile_standard, install_solc
from eth_account import Account
import time

def deploy_dynasty_oath():
    """
    Deploy DynastyOath.sol to testnet
    Returns contract address and transaction hash
    """

    print("🏛️ DEPLOYING DYNASTY OATH ETERNAL CONTRACT")
    print("∞ En Eeke Mai Ea ∞ - Argead Kingdom Manifested")
    print("=" * 60)

    # Configuration - UPDATE THESE VALUES
    TESTNET_RPC = os.getenv("TESTNET_RPC", "https://sepolia.infura.io/v3/YOUR_INFURA_KEY")
    PRIVATE_KEY = os.getenv("DEPLOYER_PRIVATE_KEY", "YOUR_PRIVATE_KEY")
    CHAIN_ID = int(os.getenv("CHAIN_ID", "11155111"))  # Sepolia testnet

    if PRIVATE_KEY == "YOUR_PRIVATE_KEY" or "YOUR_INFURA_KEY" in TESTNET_RPC:
        print("❌ Configuration required!")
        print("Set environment variables:")
        print("  export TESTNET_RPC='https://sepolia.infura.io/v3/YOUR_INFURA_KEY'")
        print("  export DEPLOYER_PRIVATE_KEY='0x...'")
        print("  export CHAIN_ID='11155111'  # Sepolia")
        return None, None

    # Initialize Web3
    w3 = Web3(Web3.HTTPProvider(TESTNET_RPC))
    account = Account.from_key(PRIVATE_KEY)

    print(f"🔗 Network: {TESTNET_RPC}")
    print(f"👤 Deployer: {account.address}")
    print(f"⛓️  Chain ID: {CHAIN_ID}")
    print(f"💰 Balance: {w3.eth.get_balance(account.address) / 10**18:.4f} ETH")
    print()

    # Check balance
    balance = w3.eth.get_balance(account.address)
    if balance < w3.to_wei(0.01, 'ether'):
        print("❌ Insufficient funds! Need at least 0.01 ETH for deployment")
        return None, None

    # Install Solidity compiler
    print("⚡ Installing Solidity compiler...")
    install_solc('0.8.19')

    # Load contract source
    print("📜 Loading DynastyOath.sol...")
    with open('DynastyOath.sol', 'r') as f:
        contract_source = f.read()

    # Compile contract
    print("🔨 Compiling contract...")
    compiled_sol = compile_standard({
        "language": "Solidity",
        "sources": {"DynastyOath.sol": {"content": contract_source}},
        "settings": {
            "outputSelection": {
                "*": {
                    "*": ["abi", "metadata", "evm.bytecode", "evm.bytecode.sourceMap"]
                }
            },
            "optimizer": {
                "enabled": True,
                "runs": 200
            }
        }
    })

    # Get contract bytecode and ABI
    bytecode = compiled_sol["contracts"]["DynastyOath.sol"]["DynastyOath"]["evm"]["bytecode"]["object"]
    abi = compiled_sol["contracts"]["DynastyOath.sol"]["DynastyOath"]["abi"]

    print(f"✅ Contract compiled successfully")
    print(f"📏 Bytecode size: {len(bytecode)} bytes")
    print()

    # Create contract instance
    contract = w3.eth.contract(abi=abi, bytecode=bytecode)

    # Build transaction
    print("📝 Building deployment transaction...")
    nonce = w3.eth.get_transaction_count(account.address)
    gas_estimate = contract.constructor().estimate_gas()

    transaction = contract.constructor().build_transaction({
        'from': account.address,
        'nonce': nonce,
        'gas': int(gas_estimate * 1.2),  # 20% buffer
        'gasPrice': w3.eth.gas_price,
        'chainId': CHAIN_ID
    })

    print(f"⛽ Gas Estimate: {gas_estimate}")
    print(f"💰 Gas Price: {w3.eth.gas_price}")
    print(f"💵 Estimated Cost: {(gas_estimate * w3.eth.gas_price) / 10**18:.6f} ETH")
    print()

    # Sign and send transaction
    print("🔐 Signing transaction...")
    signed_tx = account.sign_transaction(transaction)

    print("📤 Sending transaction...")
    tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
    print(f"🔗 Transaction Hash: {tx_hash.hex()}")

    # Wait for confirmation
    print("⏳ Waiting for confirmation...")
    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    if receipt.status == 1:
        contract_address = receipt.contractAddress
        print("✅ DEPLOYMENT SUCCESSFUL!")
        print(f"🏛️ Contract Address: {contract_address}")
        print(f"🔍 Explorer: https://sepolia.etherscan.io/address/{contract_address}")
        print()

        # Save deployment info
        deployment_info = {
            "contract_address": contract_address,
            "deployer_address": account.address,
            "transaction_hash": tx_hash.hex(),
            "block_number": receipt.blockNumber,
            "gas_used": receipt.gasUsed,
            "network": "sepolia" if CHAIN_ID == 11155111 else f"chain_{CHAIN_ID}",
            "timestamp": int(time.time()),
            "kingdom_seal": "DYNASTY_OATH_DEPLOYED_ETERNAL"
        }

        with open('deployment_info.json', 'w') as f:
            json.dump(deployment_info, f, indent=2)

        print("💾 Deployment info saved to deployment_info.json")
        print()

        # Verify contract
        print("🔍 Verifying contract deployment...")
        code = w3.eth.get_code(contract_address)
        if len(code) > 2:  # Not empty
            print("✅ Contract code verified on blockchain")
        else:
            print("❌ Contract code verification failed")

        print()
        print("🎉 DYNASTY OATH ETERNAL CONTRACT DEPLOYED!")
        print("♔∞ Soul bound tokens ready for eternal manifestation records ♔∞")

        return contract_address, tx_hash.hex()
    else:
        print("❌ DEPLOYMENT FAILED!")
        print(f"🔍 Check transaction: https://sepolia.etherscan.io/tx/{tx_hash.hex()}")
        return None, tx_hash.hex()

def verify_deployment(contract_address, rpc_url):
    """Verify existing deployment"""
    w3 = Web3(Web3.HTTPProvider(rpc_url))

    if not w3.is_connected():
        print("❌ Cannot connect to network")
        return False

    try:
        code = w3.eth.get_code(contract_address)
        if len(code) > 2:
            print(f"✅ Contract verified at {contract_address}")
            return True
        else:
            print(f"❌ No contract found at {contract_address}")
            return False
    except Exception as e:
        print(f"❌ Verification failed: {e}")
        return False

if __name__ == "__main__":
    # Check if already deployed
    if os.path.exists('deployment_info.json'):
        with open('deployment_info.json', 'r') as f:
            info = json.load(f)
        print("📋 Existing deployment found:")
        print(f"🏛️ Contract: {info['contract_address']}")
        print(f"🔗 Transaction: {info['transaction_hash']}")
        print(f"🌐 Network: {info['network']}")
        print()

        # Verify it's still deployed
        rpc_urls = {
            "sepolia": "https://sepolia.infura.io/v3/YOUR_INFURA_KEY",
            "goerli": "https://goerli.infura.io/v3/YOUR_INFURA_KEY"
        }
        rpc_url = rpc_urls.get(info['network'], "https://sepolia.infura.io/v3/YOUR_INFURA_KEY")
        verify_deployment(info['contract_address'], rpc_url)
    else:
        print("🚀 No existing deployment found - deploying fresh contract...")
        deploy_dynasty_oath()
