#!/bin/bash
# Vortex-369 DAO - Testnet Deployment Script
# Deploys to Base Sepolia testnet

set -e

echo "🌀 Vortex-369 DAO - Testnet Deployment"
echo "======================================"
echo ""

# Check environment variables
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Error: PRIVATE_KEY not set"
    echo "   Run: export PRIVATE_KEY='0x...'"
    exit 1
fi

# Configuration
CHAIN="base-sepolia"
RPC_URL="https://sepolia.base.org"
CHAIN_ID=84532
EXPLORER="https://sepolia.basescan.org"

echo "📋 Deployment Configuration:"
echo "   Chain: $CHAIN"
echo "   RPC: $RPC_URL"
echo "   Chain ID: $CHAIN_ID"
echo ""

# Check balance
echo "💰 Checking deployer balance..."
BALANCE=$(cast balance $PRIVATE_KEY --rpc-url $RPC_URL 2>/dev/null || echo "0")
echo "   Balance: $BALANCE wei"

if [ "$BALANCE" = "0" ]; then
    echo "⚠️  Warning: Balance is 0. You need testnet ETH."
    echo "   Get testnet ETH from: https://www.alchemy.com/faucets/base-sepolia"
    echo ""
fi

# Deploy NullOffice
echo "1️⃣ Deploying NullOffice contract..."
echo ""

NULLOFFICE_DEPLOY=$(forge create contracts/NullOffice.sol:NullOffice \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --json 2>&1)

if echo "$NULLOFFICE_DEPLOY" | grep -q "deployedTo"; then
    NULLOFFICE_ADDRESS=$(echo "$NULLOFFICE_DEPLOY" | jq -r '.deployedTo')
    echo "✅ NullOffice deployed!"
    echo "   Address: $NULLOFFICE_ADDRESS"
    echo "   Explorer: $EXPLORER/address/$NULLOFFICE_ADDRESS"
else
    echo "❌ NullOffice deployment failed"
    echo "$NULLOFFICE_DEPLOY"
    exit 1
fi

echo ""
sleep 3

# Deploy VortexDAO
echo "2️⃣ Deploying VortexDAO contract..."
echo ""

VORTEXDAO_DEPLOY=$(forge create contracts/VortexDAOSimplified.sol:VortexDAO \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --json 2>&1)

if echo "$VORTEXDAO_DEPLOY" | grep -q "deployedTo"; then
    VORTEXDAO_ADDRESS=$(echo "$VORTEXDAO_DEPLOY" | jq -r '.deployedTo')
    echo "✅ VortexDAO deployed!"
    echo "   Address: $VORTEXDAO_ADDRESS"
    echo "   Explorer: $EXPLORER/address/$VORTEXDAO_ADDRESS"
else
    echo "❌ VortexDAO deployment failed"
    echo "$VORTEXDAO_DEPLOY"
    exit 1
fi

echo ""
sleep 3

# Verify contracts
echo "3️⃣ Verifying contracts on Basescan..."
echo ""

echo "Verifying NullOffice..."
forge verify-contract \
    --chain-id $CHAIN_ID \
    --compiler-version v0.8.20 \
    $NULLOFFICE_ADDRESS \
    contracts/NullOffice.sol:NullOffice \
    --watch || echo "⚠️  Verification queued (check explorer later)"

echo ""

echo "Verifying VortexDAO..."
forge verify-contract \
    --chain-id $CHAIN_ID \
    --compiler-version v0.8.20 \
    $VORTEXDAO_ADDRESS \
    contracts/VortexDAOSimplified.sol:VortexDAO \
    --watch || echo "⚠️  Verification queued (check explorer later)"

echo ""

# Save deployment addresses
echo "4️⃣ Saving deployment configuration..."
cat > .env.testnet << EOF
# Vortex-369 DAO Testnet Configuration
# Generated: $(date)

CHAIN=$CHAIN
RPC_URL=$RPC_URL
CHAIN_ID=$CHAIN_ID

VORTEX_DAO_ADDRESS=$VORTEXDAO_ADDRESS
NULL_OFFICE_ADDRESS=$NULLOFFICE_ADDRESS

PRIVATE_KEY=$PRIVATE_KEY
EOF

echo "✅ Configuration saved to .env.testnet"
echo ""

# Summary
echo "🎉 Deployment Complete!"
echo ""
echo "📋 Deployment Summary:"
echo "   NullOffice:  $NULLOFFICE_ADDRESS"
echo "   VortexDAO:   $VORTEXDAO_ADDRESS"
echo ""
echo "🔗 Explorer Links:"
echo "   NullOffice:  $EXPLORER/address/$NULLOFFICE_ADDRESS"
echo "   VortexDAO:   $EXPLORER/address/$VORTEXDAO_ADDRESS"
echo ""
echo "📝 Next Steps:"
echo "   1. Verify contracts on Basescan"
echo "   2. Run: source .env.testnet"
echo "   3. Test: cargo run --release -- --chain base-sepolia --dry-run"
echo "   4. Submit first action to governance"
echo ""
echo "3 · 6 · 9"
echo "The vortex is live on testnet!"
echo ""
