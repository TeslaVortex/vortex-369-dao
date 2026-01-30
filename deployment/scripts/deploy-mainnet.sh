#!/bin/bash
set -e

echo "🚀 Deploying to Base Mainnet..."

# Load environment
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Copy deployment/configs/mainnet.env.example to .env and configure it"
    exit 1
fi

source .env

# Verify we have required variables
if [ -z "$DEPLOYER_PRIVATE_KEY" ]; then
    echo "❌ DEPLOYER_PRIVATE_KEY not set!"
    exit 1
fi

# Deploy contracts
cd contracts
echo "Compiling contracts..."
forge build

echo "Deploying to mainnet..."
forge script script/Deploy.s.sol \
    --rpc-url $RPC_URL \
    --private-key $DEPLOYER_PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --chain-id 8453

echo "✅ Deployment complete!"
echo "Check your deployed contracts on BaseScan"
