#!/bin/bash

# deployment/scripts/upgrade-contracts.sh

echo "Upgrading contracts..."

# Load environment

source .env

# Upgrade VortexDAO

cast send $VORTEX_DAO_PROXY "upgradeTo(address)" $NEW_VORTEX_DAO_IMPL \
  --rpc-url $RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY

# Upgrade NullOffice if needed

echo "✅ Upgrade complete!"
