#!/bin/bash
set -e

NETWORK=$1

if [ -z "$NETWORK" ]; then
    echo "Usage: ./verify-contracts.sh [testnet|mainnet]"
    exit 1
fi

source .env

if [ "$NETWORK" == "mainnet" ]; then
    VORTEX_DAO="0x983a432de80Eae9722c44ffE61F7831b0Cd99fd5"
    NULL_OFFICE="0x7D2fd294506723756B50279a8fd18662cd982bb8"
    CHAIN_ID=8453
else
    echo "Please set testnet contract addresses"
    exit 1
fi

echo "Verifying contracts on $NETWORK..."

cd contracts

forge verify-contract $VORTEX_DAO VortexDAO \
    --chain-id $CHAIN_ID \
    --etherscan-api-key $ETHERSCAN_API_KEY

forge verify-contract $NULL_OFFICE NullOffice \
    --chain-id $CHAIN_ID \
    --etherscan-api-key $ETHERSCAN_API_KEY

echo "✅ Verification complete!"
