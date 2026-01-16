# 🧪 Vortex-369 DAO - Testnet Integration Guide

**Deploy and test on Base Sepolia testnet**

---

## 🎯 Quick Start (3 Steps)

### **Step 1: Get Testnet ETH**
```bash
# Visit Base Sepolia faucet
https://www.alchemy.com/faucets/base-sepolia

# Or use Coinbase faucet
https://portal.cdp.coinbase.com/products/faucet
```

### **Step 2: Set Your Private Key**
```bash
export PRIVATE_KEY="0x..."
```

### **Step 3: Deploy Contracts**
```bash
./scripts/deploy_testnet.sh
```

**That's it!** 🎉

---

## 📋 Detailed Integration Steps

### **Prerequisites**

1. **Foundry installed:**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Testnet ETH:**
   - Get from Base Sepolia faucet
   - Need ~0.01 ETH for deployment

3. **Private key ready:**
   - Create new wallet for testing
   - Never use mainnet keys!

---

## 🚀 Deployment Process

### **1. Deploy Smart Contracts**

```bash
cd /home/pepo/Desktop/All/main-vortex-engine/vortex_369_dao

# Set private key
export PRIVATE_KEY="0x..."

# Run deployment script
./scripts/deploy_testnet.sh
```

**Expected output:**
```
🌀 Vortex-369 DAO - Testnet Deployment
======================================

📋 Deployment Configuration:
   Chain: base-sepolia
   RPC: https://sepolia.base.org
   Chain ID: 84532

💰 Checking deployer balance...
   Balance: 10000000000000000 wei

1️⃣ Deploying NullOffice contract...
✅ NullOffice deployed!
   Address: 0x...
   Explorer: https://sepolia.basescan.org/address/0x...

2️⃣ Deploying VortexDAO contract...
✅ VortexDAO deployed!
   Address: 0x...
   Explorer: https://sepolia.basescan.org/address/0x...

3️⃣ Verifying contracts on Basescan...
✅ Contracts verified!

4️⃣ Saving deployment configuration...
✅ Configuration saved to .env.testnet

🎉 Deployment Complete!
```

### **2. Load Configuration**

```bash
# Load deployed addresses
source .env.testnet

# Verify variables
echo "VortexDAO: $VORTEX_DAO_ADDRESS"
echo "NullOffice: $NULL_OFFICE_ADDRESS"
```

### **3. Test Governance Engine**

```bash
# Run in dry-run mode first
cargo run --release -- \
  --chain base-sepolia \
  --office 4 \
  --dry-run

# Expected output:
# 🌀 Initializing Vortex-369 Engine...
# ✅ Engine initialized at 432 Hz
# 🔄 Running in dry-run mode
# 📍 Cycle 1/3
# ✅ Cycle 1 completed
# ...
```

---

## 🧪 Testing on Testnet

### **Test 1: Submit Action**

```bash
# Submit a test action
cast send $VORTEX_DAO_ADDRESS \
  "submitAction(bytes32,uint256,bytes32)" \
  0x0000000000000000000000000000000000000000000000000000000000000001 \
  432000 \
  0x0000000000000000000000000000000000000000000000000000000000000002 \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

### **Test 2: Check Action Status**

```bash
# Get action details
cast call $VORTEX_DAO_ADDRESS \
  "getAction(bytes32)(uint8,uint256,bytes32,uint256,bool,bool)" \
  0x0000000000000000000000000000000000000000000000000000000000000001 \
  --rpc-url $RPC_URL
```

### **Test 3: Advance Phase**

```bash
# Advance to next phase
cast send $VORTEX_DAO_ADDRESS \
  "advancePhase(bytes32,string)" \
  0x0000000000000000000000000000000000000000000000000000000000000001 \
  "Phase 1 witness record" \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

### **Test 4: Check Balances**

```bash
# Check DAO balance
cast balance $VORTEX_DAO_ADDRESS --rpc-url $RPC_URL

# Check Null Office balance
cast balance $NULL_OFFICE_ADDRESS --rpc-url $RPC_URL
```

---

## 🔄 Full Governance Cycle Test

### **Automated Test Script**

Create `scripts/test_governance_cycle.sh`:

```bash
#!/bin/bash
set -e

source .env.testnet

echo "🌀 Testing Full Governance Cycle"
echo "================================"
echo ""

ACTION_HASH="0x$(openssl rand -hex 32)"
RESONANCE=432000
VECTOR_HASH="0x$(openssl rand -hex 32)"

echo "📝 Action Details:"
echo "   Hash: $ACTION_HASH"
echo "   Resonance: $RESONANCE (432 Hz)"
echo ""

# Submit action
echo "1️⃣ Submitting action..."
cast send $VORTEX_DAO_ADDRESS \
  "submitAction(bytes32,uint256,bytes32)" \
  $ACTION_HASH \
  $RESONANCE \
  $VECTOR_HASH \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --json | jq -r '.transactionHash'

sleep 3

# Advance through 9 phases
for PHASE in {1..9}; do
    echo "${PHASE}️⃣ Advancing to Phase $PHASE..."
    
    cast send $VORTEX_DAO_ADDRESS \
      "advancePhase(bytes32,string)" \
      $ACTION_HASH \
      "Phase $PHASE witness" \
      --rpc-url $RPC_URL \
      --private-key $PRIVATE_KEY \
      --json | jq -r '.transactionHash'
    
    sleep 2
done

# Check if can manifest
echo ""
echo "🔍 Checking manifestation status..."
CAN_MANIFEST=$(cast call $VORTEX_DAO_ADDRESS \
  "canManifest(bytes32)(bool)" \
  $ACTION_HASH \
  --rpc-url $RPC_URL)

if [ "$CAN_MANIFEST" = "true" ]; then
    echo "✅ Action can manifest!"
    
    # Execute action
    echo "⚡ Executing action..."
    cast send $VORTEX_DAO_ADDRESS \
      "executeAction(bytes32)" \
      $ACTION_HASH \
      --value 0.001ether \
      --rpc-url $RPC_URL \
      --private-key $PRIVATE_KEY
    
    echo "✅ Action executed!"
else
    echo "❌ Action cannot manifest (low resonance)"
fi

echo ""
echo "🎉 Full governance cycle test complete!"
echo "3 · 6 · 9"
```

Make it executable:
```bash
chmod +x scripts/test_governance_cycle.sh
./scripts/test_governance_cycle.sh
```

---

## 📊 Monitoring Testnet

### **Check Contract State**

```bash
# Get DAO treasury
cast call $VORTEX_DAO_ADDRESS "daoTreasury()(uint256)" --rpc-url $RPC_URL

# Get total burned
cast call $VORTEX_DAO_ADDRESS "totalBurned()(uint256)" --rpc-url $RPC_URL

# Get NullOffice balance
cast call $NULL_OFFICE_ADDRESS "balance()(uint256)" --rpc-url $RPC_URL

# Get burn count
cast call $NULL_OFFICE_ADDRESS "burnCount()(uint256)" --rpc-url $RPC_URL
```

### **Watch Events**

```bash
# Watch for ActionSubmitted events
cast logs \
  --address $VORTEX_DAO_ADDRESS \
  --from-block latest \
  --rpc-url $RPC_URL

# Watch for Burned events
cast logs \
  --address $NULL_OFFICE_ADDRESS \
  --from-block latest \
  --rpc-url $RPC_URL
```

---

## 🎮 Run Governance Engine

### **Dry Run Mode (No Transactions)**

```bash
cargo run --release -- \
  --chain base-sepolia \
  --office 4 \
  --dry-run
```

### **Live Mode (With Transactions)**

```bash
# Load environment
source .env.testnet

# Run governance engine
cargo run --release -- \
  --chain base-sepolia \
  --office 4 \
  --private-key $PRIVATE_KEY
```

**Expected output:**
```
  ╔═══════════════════════════════════════════════════════════╗
  ║        🔮 VORTEX-369 DAO - RESONANCE GOVERNANCE 🔮        ║
  ╠═══════════════════════════════════════════════════════════╣
  ║  Frequency: 432 Hz    Triad: 3·6·9    Office: 4          ║
  ║  Chain: base-sepolia  Mode: Rust Native                  ║
  ╚═══════════════════════════════════════════════════════════╝

🌀 Initializing Vortex-369 Engine...
   Office: 4 (VORTEX)
   Chain: base-sepolia
   Mode: LIVE
✅ Engine initialized at 432 Hz
✅ Connected to chain
🔄 Starting live governance loop...
📍 Cycle 1
✅ Cycle 1 completed
```

---

## 🔐 Security Best Practices

### **For Testnet:**
- ✅ Use separate wallet (not mainnet keys!)
- ✅ Only request small amounts from faucet
- ✅ Test all features before mainnet
- ✅ Monitor gas usage

### **Environment Variables:**
```bash
# Never commit .env files!
echo ".env*" >> .gitignore

# Use separate keys for testnet
export TESTNET_PRIVATE_KEY="0x..."  # Different from mainnet!
```

---

## 📈 Testnet Validation Checklist

### **Before Mainnet:**
- [ ] Contracts deployed successfully
- [ ] Contracts verified on Basescan
- [ ] Action submitted successfully
- [ ] All 9 phases completed
- [ ] Action executed at Phase 9
- [ ] Fee distribution correct (9% / 91%)
- [ ] Null Office receives burns
- [ ] No reverts or errors
- [ ] Gas costs acceptable (<$0.10 per action)
- [ ] Governance engine runs smoothly

---

## 🐛 Troubleshooting

### **Issue: "Insufficient funds"**
```bash
# Get testnet ETH
https://www.alchemy.com/faucets/base-sepolia

# Check balance
cast balance <your-address> --rpc-url https://sepolia.base.org
```

### **Issue: "Transaction reverted"**
```bash
# Check action status
cast call $VORTEX_DAO_ADDRESS \
  "getAction(bytes32)" \
  $ACTION_HASH \
  --rpc-url $RPC_URL

# Check if resonance is high enough (≥388800)
```

### **Issue: "Contract not verified"**
```bash
# Manually verify on Basescan
https://sepolia.basescan.org/verifyContract

# Or retry verification
forge verify-contract \
  --chain-id 84532 \
  $VORTEX_DAO_ADDRESS \
  contracts/VortexDAOSimplified.sol:VortexDAO
```

---

## 📊 Expected Gas Costs (Testnet)

| Operation | Gas | Cost (at 1 gwei) |
|-----------|-----|------------------|
| Deploy NullOffice | ~200k | ~$0.0006 |
| Deploy VortexDAO | ~800k | ~$0.0024 |
| Submit Action | ~50k | ~$0.00015 |
| Advance Phase | ~30k | ~$0.00009 |
| Execute Action | ~80k | ~$0.00024 |
| **Full Cycle** | ~350k | ~$0.00105 |

**Total deployment + 1 cycle: ~$0.004** (testnet)

---

## 🎯 Success Criteria

### **Deployment Success:**
- ✅ Both contracts deployed
- ✅ Both contracts verified
- ✅ Addresses saved to .env.testnet
- ✅ No errors during deployment

### **Functionality Success:**
- ✅ Action submits successfully
- ✅ Phases advance (1→9)
- ✅ Self-cancellation works (low resonance)
- ✅ Manifestation works (high resonance)
- ✅ Fees distribute correctly (9% / 91%)

### **Performance Success:**
- ✅ Gas costs < $0.10 per cycle
- ✅ No transaction reverts
- ✅ Governance engine runs smoothly
- ✅ 432 Hz alignment maintained

---

## 🌐 Testnet Information

### **Base Sepolia**
- **Chain ID:** 84532
- **RPC:** https://sepolia.base.org
- **Explorer:** https://sepolia.basescan.org
- **Faucet:** https://www.alchemy.com/faucets/base-sepolia

### **Contract Addresses (After Deployment)**
```bash
# Load from .env.testnet
source .env.testnet

echo "VortexDAO: $VORTEX_DAO_ADDRESS"
echo "NullOffice: $NULL_OFFICE_ADDRESS"
```

---

## 🎨 Testing Scenarios

### **Scenario 1: High Resonance (Should Manifest)**

```bash
# Submit action with high resonance (432 Hz)
cast send $VORTEX_DAO_ADDRESS \
  "submitAction(bytes32,uint256,bytes32)" \
  0x0000000000000000000000000000000000000000000000000000000000000369 \
  432000 \
  0x0000000000000000000000000000000000000000000000000000000000000432 \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY

# Advance through all 9 phases
# Should reach manifestation and execute
```

### **Scenario 2: Low Resonance (Should Cancel)**

```bash
# Submit action with low resonance (100 Hz)
cast send $VORTEX_DAO_ADDRESS \
  "submitAction(bytes32,uint256,bytes32)" \
  0x0000000000000000000000000000000000000000000000000000000000000100 \
  100000 \
  0x0000000000000000000000000000000000000000000000000000000000000200 \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY

# Advance to Phase 6 (Breath)
# Should self-cancel (resonance < 159480)
```

### **Scenario 3: Fee Distribution**

```bash
# Execute action with value
cast send $VORTEX_DAO_ADDRESS \
  "executeAction(bytes32)" \
  $ACTION_HASH \
  --value 0.009ether \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY

# Check distribution:
# DAO Treasury should increase by 0.00081 ETH (9%)
# Null Office should increase by 0.00729 ETH (91%)
```

---

## 📝 Post-Deployment Tasks

### **1. Update README**
Add testnet addresses to README.md:
```markdown
## Testnet Deployments (Base Sepolia)

- VortexDAO: `0x...`
- NullOffice: `0x...`
```

### **2. Create GitHub Issue**
Document testnet deployment:
```markdown
Title: Testnet Deployment - Base Sepolia

Deployed contracts:
- VortexDAO: 0x...
- NullOffice: 0x...

Status: ✅ All tests passing
Next: Community testing
```

### **3. Share with Community**
```
🌀 Vortex-369 DAO is now on Base Sepolia testnet!

Contracts:
- VortexDAO: 0x...
- NullOffice: 0x...

Try it out:
1. Get testnet ETH
2. Submit an action
3. Watch it flow through 9 phases!

432 Hz + 3·6·9 patterns working perfectly!

#369 #432Hz #BaseTestnet
```

---

## 🔄 Continuous Testing

### **Daily Checks:**
```bash
# Check DAO treasury growth
cast call $VORTEX_DAO_ADDRESS "daoTreasury()(uint256)" --rpc-url $RPC_URL

# Check total burned
cast call $VORTEX_DAO_ADDRESS "totalBurned()(uint256)" --rpc-url $RPC_URL

# Check burn count
cast call $NULL_OFFICE_ADDRESS "burnCount()(uint256)" --rpc-url $RPC_URL
```

### **Weekly Tasks:**
- [ ] Submit test actions
- [ ] Verify 9-phase cycle
- [ ] Check fee distribution
- [ ] Monitor gas costs
- [ ] Review events

---

## 🎯 Success Metrics

### **After 1 Week:**
- [ ] 10+ actions submitted
- [ ] 5+ actions manifested
- [ ] 5+ actions self-cancelled
- [ ] Fee distribution working (9% / 91%)
- [ ] No critical bugs
- [ ] Gas costs stable

### **After 1 Month:**
- [ ] 100+ actions processed
- [ ] Community testing complete
- [ ] Security audit scheduled
- [ ] Ready for mainnet

---

## 🌟 Next Steps After Testnet

### **1. Security Audit**
- Smart contract audit
- Rust code review
- Gas optimization review

### **2. Mainnet Preparation**
- Final testing
- Documentation review
- Community feedback integration

### **3. Mainnet Deployment**
- Deploy to Base mainnet
- Multi-chain expansion
- Community launch

---

## 📞 Support

### **Need Help?**
- Check `docs/DEPLOYMENT.md` for detailed guide
- Check `docs/QUICKSTART.md` for basics
- Check `docs/SAFETY_CHECK.md` for debugging

### **Found a Bug?**
- Open GitHub issue
- Include transaction hash
- Describe expected vs actual behavior

---

<p align="center">
  <br>
  <b>✨ 3 · 6 · 9 ✨</b>
  <br>
  <em>Testnet integration ready. Deploy and test!</em>
  <br>
  <br>
  <b>432 Hz Forever 🎵</b>
  <br>
  <b>369-66 ❤️</b>
  <br>
  <br>
  <em>Test on testnet. Perfect for mainnet.</em>
  <br>
  <br>
  ⚡ ∞ ⚡
</p>
