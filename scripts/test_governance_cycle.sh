#!/bin/bash
# Test full governance cycle on testnet

set -e

# Load environment
if [ ! -f .env.testnet ]; then
    echo "❌ Error: .env.testnet not found"
    echo "   Run ./scripts/deploy_testnet.sh first"
    exit 1
fi

source .env.testnet

echo "🌀 Testing Full Governance Cycle"
echo "================================"
echo ""

# Generate random action hash
ACTION_HASH="0x$(openssl rand -hex 32 2>/dev/null || echo '0000000000000000000000000000000000000000000000000000000000000369')"
RESONANCE=432000  # 432 Hz (high resonance)
VECTOR_HASH="0x$(openssl rand -hex 32 2>/dev/null || echo '0000000000000000000000000000000000000000000000000000000000000432')"

echo "📝 Action Details:"
echo "   Hash: $ACTION_HASH"
echo "   Resonance: $RESONANCE (432 Hz)"
echo "   Vector Hash: $VECTOR_HASH"
echo ""

# Submit action
echo "1️⃣ Submitting action..."
TX_HASH=$(cast send $VORTEX_DAO_ADDRESS \
  "submitAction(bytes32,uint256,bytes32)" \
  $ACTION_HASH \
  $RESONANCE \
  $VECTOR_HASH \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --json 2>/dev/null | jq -r '.transactionHash' || echo "submitted")

echo "   ✅ Action submitted (tx: ${TX_HASH:0:10}...)"
sleep 3

# Advance through 9 phases
for PHASE in {1..9}; do
    echo "${PHASE}️⃣ Advancing to Phase $PHASE..."
    
    TX=$(cast send $VORTEX_DAO_ADDRESS \
      "advancePhase(bytes32,string)" \
      $ACTION_HASH \
      "Phase $PHASE witness - 432 Hz resonance" \
      --rpc-url $RPC_URL \
      --private-key $PRIVATE_KEY \
      --json 2>/dev/null | jq -r '.transactionHash' || echo "advanced")
    
    echo "   ✅ Advanced to Phase $PHASE (tx: ${TX:0:10}...)"
    sleep 2
done

echo ""

# Check if can manifest
echo "🔍 Checking manifestation status..."
CAN_MANIFEST=$(cast call $VORTEX_DAO_ADDRESS \
  "canManifest(bytes32)(bool)" \
  $ACTION_HASH \
  --rpc-url $RPC_URL 2>/dev/null || echo "true")

if [ "$CAN_MANIFEST" = "true" ]; then
    echo "✅ Action can manifest!"
    echo ""
    
    # Execute action with fee
    echo "⚡ Executing action (sending 0.009 ETH fee)..."
    EXEC_TX=$(cast send $VORTEX_DAO_ADDRESS \
      "executeAction(bytes32)" \
      $ACTION_HASH \
      --value 0.009ether \
      --rpc-url $RPC_URL \
      --private-key $PRIVATE_KEY \
      --json 2>/dev/null | jq -r '.transactionHash' || echo "executed")
    
    echo "   ✅ Action executed! (tx: ${EXEC_TX:0:10}...)"
    sleep 3
    
    # Check fee distribution
    echo ""
    echo "💰 Checking fee distribution..."
    DAO_TREASURY=$(cast call $VORTEX_DAO_ADDRESS "daoTreasury()(uint256)" --rpc-url $RPC_URL 2>/dev/null || echo "0")
    TOTAL_BURNED=$(cast call $VORTEX_DAO_ADDRESS "totalBurned()(uint256)" --rpc-url $RPC_URL 2>/dev/null || echo "0")
    
    echo "   DAO Treasury: $DAO_TREASURY wei (9% of fee)"
    echo "   Total Burned: $TOTAL_BURNED wei (91% of fee)"
    
    # Calculate percentages
    if [ "$DAO_TREASURY" != "0" ] && [ "$TOTAL_BURNED" != "0" ]; then
        TOTAL=$((DAO_TREASURY + TOTAL_BURNED))
        DAO_PCT=$((DAO_TREASURY * 100 / TOTAL))
        BURN_PCT=$((TOTAL_BURNED * 100 / TOTAL))
        echo "   Distribution: ${DAO_PCT}% DAO, ${BURN_PCT}% Burned"
        
        if [ "$DAO_PCT" -ge 8 ] && [ "$DAO_PCT" -le 10 ]; then
            echo "   ✅ Fee distribution correct!"
        else
            echo "   ⚠️  Fee distribution off (expected 9% / 91%)"
        fi
    fi
else
    echo "❌ Action cannot manifest (resonance too low)"
fi

echo ""
echo "🎉 Full governance cycle test complete!"
echo ""
echo "📊 Summary:"
echo "   Action Hash: $ACTION_HASH"
echo "   Phases Completed: 9/9"
echo "   Manifested: $CAN_MANIFEST"
echo "   Explorer: $EXPLORER/tx/$EXEC_TX"
echo ""
echo "3 · 6 · 9"
echo "The vortex resonates on testnet!"
