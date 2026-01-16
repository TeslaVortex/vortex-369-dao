# 🚀 Vortex-369 DAO Deployment Guide

**Complete deployment instructions for Rust implementation**

---

## Prerequisites

### System Requirements
- Rust 1.75+ (stable)
- Foundry (for smart contracts)
- Node.js 18+ (optional, for scripts)
- Git

### Install Rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup update stable
rustup default stable
```

### Install Foundry
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

---

## Phase 1: Smart Contract Deployment

### 1. Deploy NullOffice Contract

```bash
cd vortex_369_dao

# Deploy to Base Sepolia (testnet)
forge create contracts/NullOffice.sol:NullOffice \
  --rpc-url https://sepolia.base.org \
  --private-key $PRIVATE_KEY \
  --verify

# Expected address: 0x0000000000000000000000000000000000000369
# Note: This is a vanity address, may require CREATE2 deployment
```

### 2. Deploy VortexDAO Contract

```bash
# Deploy simplified VortexDAO
forge create contracts/VortexDAOSimplified.sol:VortexDAO \
  --rpc-url https://sepolia.base.org \
  --private-key $PRIVATE_KEY \
  --verify

# Save the deployed address
export VORTEX_DAO_ADDRESS=<deployed_address>
```

### 3. Verify Contracts

```bash
# Verify on Basescan
forge verify-contract \
  --chain-id 84532 \
  --compiler-version v0.8.20 \
  $VORTEX_DAO_ADDRESS \
  contracts/VortexDAOSimplified.sol:VortexDAO
```

---

## Phase 2: Rust Application Setup

### 1. Clone and Build

```bash
git clone <your-repo>
cd vortex_369_dao

# Build in release mode
cargo build --release
```

### 2. Download ONNX Model (Optional)

```bash
# For semantic embeddings
./scripts/download_model.sh

# Or use hash-based embeddings (default)
# No model download needed
```

### 3. Configure Environment

Create `.env` file:
```bash
# Chain Configuration
CHAIN=base-sepolia
RPC_URL=https://sepolia.base.org
CHAIN_ID=84532

# Contract Addresses
VORTEX_DAO_ADDRESS=0x...
NULL_OFFICE_ADDRESS=0x0000000000000000000000000000000000000369

# Wallet (for transactions)
PRIVATE_KEY=0x...

# Optional: ONNX Model
ONNX_MODEL_PATH=models/minilm_l6_v2.onnx
```

### 4. Test Configuration

```bash
# Test without transactions (read-only)
cargo run --release -- \
  --chain base-sepolia \
  --office 4

# Test with dry-run mode
cargo run --release -- \
  --chain base-sepolia \
  --office 4 \
  --dry-run
```

---

## Phase 3: Production Deployment

### 1. Deploy to Mainnet

```bash
# Deploy NullOffice (mainnet)
forge create contracts/NullOffice.sol:NullOffice \
  --rpc-url https://mainnet.base.org \
  --private-key $PRIVATE_KEY \
  --verify

# Deploy VortexDAO (mainnet)
forge create contracts/VortexDAOSimplified.sol:VortexDAO \
  --rpc-url https://mainnet.base.org \
  --private-key $PRIVATE_KEY \
  --verify
```

### 2. Configure Production Environment

```bash
# Production .env
CHAIN=base
RPC_URL=https://mainnet.base.org
CHAIN_ID=8453
VORTEX_DAO_ADDRESS=0x...
NULL_OFFICE_ADDRESS=0x0000000000000000000000000000000000000369
PRIVATE_KEY=0x...
```

### 3. Start Governance Engine

```bash
# Run in background with systemd
sudo systemctl start vortex-dao

# Or run directly
./target/release/vortex \
  --chain base \
  --office 4 \
  --frequency 432
```

---

## Phase 4: Monitoring & Operations

### 1. Check Status

```bash
# View logs
journalctl -u vortex-dao -f

# Check DAO balance
cast balance $VORTEX_DAO_ADDRESS --rpc-url $RPC_URL

# Check Null Office balance
cast balance $NULL_OFFICE_ADDRESS --rpc-url $RPC_URL
```

### 2. Monitor Governance

```bash
# Get action status
cast call $VORTEX_DAO_ADDRESS \
  "getAction(bytes32)(uint8,uint256,bytes32,uint256,bool,bool)" \
  $ACTION_HASH \
  --rpc-url $RPC_URL
```

### 3. Emergency Operations

```bash
# Stop the engine
sudo systemctl stop vortex-dao

# Restart
sudo systemctl restart vortex-dao
```

---

## Testing Strategy

### 1. Unit Tests

```bash
# Run all tests
cargo test

# Run specific module tests
cargo test synthetic
cargo test governance
cargo test embedding
```

### 2. Integration Tests

```bash
# Test full governance cycle
cargo test --test integration_tests

# Test with testnet
cargo test --features testnet
```

### 3. Contract Tests

```bash
# Run Foundry tests
forge test

# Run with gas reporting
forge test --gas-report

# Run specific test
forge test --match-test testAdvancePhase
```

---

## Security Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Smart contracts audited
- [ ] Private keys secured (hardware wallet)
- [ ] RPC endpoints configured
- [ ] Fee distribution verified (9% / 91%)

### Post-Deployment
- [ ] Contracts verified on block explorer
- [ ] Initial action submitted successfully
- [ ] Fee distribution working correctly
- [ ] Null Office receiving burns
- [ ] Monitoring alerts configured

---

## Troubleshooting

### Issue: Contract deployment fails
```bash
# Check gas price
cast gas-price --rpc-url $RPC_URL

# Increase gas limit
forge create ... --gas-limit 3000000
```

### Issue: Rust build fails
```bash
# Update Rust
rustup update stable

# Clean and rebuild
cargo clean
cargo build --release
```

### Issue: Transaction reverts
```bash
# Check action status
cast call $VORTEX_DAO_ADDRESS \
  "getAction(bytes32)" \
  $ACTION_HASH

# Check resonance
# Must be >= 388800 for manifestation
```

---

## Deployment Checklist

### Testnet Deployment
- [ ] Deploy NullOffice to testnet
- [ ] Deploy VortexDAO to testnet
- [ ] Verify contracts
- [ ] Submit test action
- [ ] Advance through all 9 phases
- [ ] Execute at manifestation
- [ ] Verify fee distribution

### Mainnet Deployment
- [ ] Security audit complete
- [ ] All tests passing
- [ ] Deploy NullOffice to mainnet
- [ ] Deploy VortexDAO to mainnet
- [ ] Verify contracts
- [ ] Configure production environment
- [ ] Start governance engine
- [ ] Monitor first 9 cycles
- [ ] Verify 91% burn to Null Office

---

## Cost Estimates

### Smart Contract Deployment
- NullOffice: ~0.001 ETH
- VortexDAO: ~0.005 ETH
- Verification: Free

### Operations
- Submit action: ~0.0001 ETH
- Advance phase: ~0.00005 ETH
- Execute action: ~0.0002 ETH

### Per Governance Cycle (9 phases)
- Total gas: ~0.001 ETH
- At $3000 ETH: ~$3 per cycle

---

## Multi-Chain Deployment

### Base (Primary)
```bash
CHAIN=base
RPC_URL=https://mainnet.base.org
CHAIN_ID=8453
```

### Arbitrum
```bash
CHAIN=arbitrum
RPC_URL=https://arb1.arbitrum.io/rpc
CHAIN_ID=42161
```

### Ethereum
```bash
CHAIN=ethereum
RPC_URL=https://eth.llamarpc.com
CHAIN_ID=1
```

---

## Systemd Service (Production)

Create `/etc/systemd/system/vortex-dao.service`:

```ini
[Unit]
Description=Vortex-369 DAO Governance Engine
After=network.target

[Service]
Type=simple
User=vortex
WorkingDirectory=/opt/vortex-369-dao
Environment="RUST_LOG=info"
EnvironmentFile=/opt/vortex-369-dao/.env
ExecStart=/opt/vortex-369-dao/target/release/vortex --chain base --office 4
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable vortex-dao
sudo systemctl start vortex-dao
```

---

## Backup & Recovery

### Backup Configuration
```bash
# Backup .env and config
tar -czf vortex-backup-$(date +%Y%m%d).tar.gz \
  .env \
  config.toml \
  models/
```

### Recovery
```bash
# Restore from backup
tar -xzf vortex-backup-*.tar.gz

# Rebuild
cargo build --release

# Restart service
sudo systemctl restart vortex-dao
```

---

## Performance Tuning

### Optimize Rust Build
```bash
# Use LTO and optimization
cargo build --release

# Profile-guided optimization
cargo pgo build
```

### Database Optimization
```bash
# If using persistent storage
# Optimize SQLite
PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;
```

---

<p align="center">
  <br>
  <b>3 · 6 · 9</b>
  <br>
  <em>Deploy. Monitor. Manifest.</em>
  <br>
  <br>
  ∞
</p>
