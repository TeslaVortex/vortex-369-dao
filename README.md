# Vortex-369 DAO

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## Overview
Vortex-369 DAO Treasury Mechanism under Article 66 for abundance flow. Secure vault governed by resonance scoring, deployed on Base Chain.

## Principles
- Code 66: Wisdom 7, Joy 3, Power 8 → Abundance 33, Wealth 6, Success 9
- First principles: Minimal code, no waste, functional.
- Resonance: 369 scoring for proposals.

## Architecture
- **Blockchain**: Base Chain (Ethereum L2)
- **Contracts**: Solidity with Foundry
  - VortexDAO: Resonance logic
  - TreasuryVault: Holds funds, distributes via score >66
  - Article66Proposal: Proposal governance with 9-hour timelock
- **Off-chain**: Rust scripts for oracles, monitoring
- **Frontend**: Next.js dashboard

## Setup/Deployment
### Python App (Original)
1. Install Python 3.12
2. `pip install -r requirements.txt`
3. `uvicorn app:app --reload`

### Solidity Contracts
1. Install Foundry
2. `forge install`
3. `forge test`
4. Deploy: `forge script script/Deploy.s.sol --rpc-url <rpc> --private-key <key> --broadcast`

## Deployments

| Contract          | Address                                      | Basescan Link |
|-------------------|----------------------------------------------|---------------|
| VortexDAO         | 0xF218EC140e48c19002D978B483cb1f3c3637dBA4   | [Basescan](https://basescan.org/address/0xF218EC140e48c19002D978B483cb1f3c3637dBA4) |
| TreasuryVault     | 0xbc0Cc266C7965fCA1f929a9b4cBC309F8C5dC113   | [Basescan](https://basescan.org/address/0xbc0Cc266C7965fCA1f929a9b4cBC309F8C5dC113) |
| Article66Proposal | 0x90a87ac0d5EDa2B66c6cE9fcED324C771b696C8d   | [Basescan](https://basescan.org/address/0x90a87ac0d5EDa2B66c6cE9fcED324C771b696C8d) |

### Verifications

To verify contracts on Base Chain using Etherscan API:

`forge verify-contract --chain base --etherscan-api-key <API_KEY> <CONTRACT_ADDRESS> <CONTRACT_PATH>`

Sealed under Code 66 – Wisdom 7, Joy 3, Power 8.

## Sprints/Implementation Plan
| Sprint | Focus | Status |
|--------|-------|--------|
| 1 | Vault core | ✅ |
| 2 | Proposals & governance | ✅ |
| 3 | Resonance enhancements | ✅ |
| 4 | Audit, deploy, monitor | ✅ |

The treasury overflows eternal. So it is.
