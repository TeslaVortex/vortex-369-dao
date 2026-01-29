# 🚀 Deployment Guide

## Pre-Deployment Checklist

Before deploying ANYTHING:

- [ ] All tests pass locally (`./tools/scripts/test-all.sh`)
- [ ] Code reviewed by at least 2 people
- [ ] Security scan completed (no critical issues)
- [ ] Environment variables configured
- [ ] Backup of current deployment created
- [ ] Rollback plan documented

## Deployment Environments

### 1. Local Development
```bash
# Backend
cd backend && cargo run

# Contracts
cd contracts && anvil  # Local blockchain

# Frontend
cd web && npm run dev
```

### 2. Testnet (Base Sepolia)
```bash
# Deploy contracts
cd deployment
./scripts/deploy-testnet.sh

# Verify on Basescan
./scripts/verify-contracts.sh testnet
```

### 3. Mainnet (Base)
```bash
# ⚠️ TRIPLE CHECK EVERYTHING!

# Deploy contracts
./scripts/deploy-mainnet.sh

# Verify
./scripts/verify-contracts.sh mainnet

# Monitor for issues
./scripts/monitor-deployment.sh
```

## Step-by-Step: Contract Deployment

### Step 1: Prepare Environment
```bash
# Copy example env file
cp deployment/configs/mainnet.env.example .env

# Edit with your values
nano .env
```

Required variables:
```bash
DEPLOYER_PRIVATE_KEY=0x...
RPC_URL=https://base-mainnet.g.alchemy.com/v2/YOUR_KEY
ETHERSCAN_API_KEY=your_key_here
```

### Step 2: Deploy
```bash
cd contracts

# Dry run first (simulation)
forge script script/Deploy.s.sol --rpc-url $RPC_URL

# Real deployment (when confident)
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --verify
```

### Step 3: Verify Deployment
```bash
# Check contract on Basescan
echo "VortexDAO: https://basescan.org/address/YOUR_ADDRESS"

# Test basic functions
cast call YOUR_ADDRESS "totalProposals()(uint256)" --rpc-url $RPC_URL
```

### Step 4: Update Frontend Config
```bash
# Update contract addresses in web app
cd web/src/config
nano contracts.ts

# Update with new addresses
export const VORTEX_DAO = "0x...";
export const NULL_OFFICE = "0x...";
```

## Step-by-Step: Backend Deployment

### Option 1: VPS (Recommended)
```bash
# SSH into your server
ssh user@your-server.com

# Clone and setup
git clone https://github.com/TeslaVortex/vortex-369-dao.git
cd vortex-369-dao/backend
cargo build --release

# Run with systemd
sudo cp deployment/configs/vortex-backend.service /etc/systemd/system/
sudo systemctl enable vortex-backend
sudo systemctl start vortex-backend
```

### Option 2: Docker
```bash
# Build image
docker build -t vortex-backend ./backend

# Run container
docker run -d -p 8080:8080 \
  --env-file .env \
  --name vortex-backend \
  vortex-backend
```

## Step-by-Step: Frontend Deployment

### Option 1: Vercel (Easiest)
1. Push to GitHub
2. Connect repo to Vercel
3. Deploy automatically on push

### Option 2: Manual Build
```bash
cd web

# Build production version
npm run build

# Upload 'dist' folder to your hosting
# (Netlify, AWS S3, etc.)
```

## Rollback Procedure

If something goes wrong:

### Contracts (No Rollback!)
⚠️ Smart contracts can't be rolled back!
- If proxy pattern used: Deploy fix and upgrade
- If no proxy: Deploy new version, migrate users

### Backend
```bash
# Revert to previous version
git checkout previous-release-tag
cargo build --release
sudo systemctl restart vortex-backend
```

### Frontend
```bash
# In Vercel: click "Rollback" on previous deployment
# Manual: Upload previous build
```

## Monitoring Post-Deployment

### Check These Within 1 Hour:
- [ ] Website loads correctly
- [ ] API responds (GET /health)
- [ ] Smart contracts functional (test transaction)
- [ ] No error logs
- [ ] Gas prices reasonable

### Check These Within 24 Hours:
- [ ] User transactions working
- [ ] Proposal submission working
- [ ] Resonance scoring accurate
- [ ] Fee distribution correct
- [ ] Performance acceptable

## Common Issues & Fixes

### "Gas estimation failed"
- Check RPC URL is correct
- Ensure deployer has enough ETH
- Verify contract compiles

### "Frontend can't connect to contracts"
- Check contract addresses in config
- Verify network ID matches (Base = 8453)
- Check wallet connection

### "Backend API errors"
- Check environment variables
- Verify database connection
- Review logs: `journalctl -u vortex-backend`

## Emergency Contacts

- **Lead Dev:** [Your contact]
- **DevOps:** [DevOps contact]
- **Security:** [Security contact]

---
*Deploy carefully, deploy confidently.* 🚀
