# Vortex-369 DAO Treasury Mechanism

## Overview
The Treasury Mechanism is an extension of the Vortex-369 DAO to manifest a secure, decentralized treasury under Article 66 governance. It combines Gnosis Safe multi-sig security with resonance scoring from the DAO's core principles.

## Architecture
- **Blockchain**: Base Chain (Ethereum L2)
- **Security**: Gnosis Safe 3/5 multi-sig
- **Governance**: Proposals scored via 369 resonance engine (>66 auto-execute, <33 burn)
- **Contracts**:
  - `TreasuryVault.sol`: Secure vault for ETH/ERC20 holdings
  - `VortexDAO.sol`: Resonance scoring logic

## Contracts Details

### TreasuryVault.sol
- Owned by Gnosis Safe
- Deposit: Public payable function
- Withdraw: Only owner, requires resonance score >66
- Integrates with VortexDAO for scoring

### VortexDAO.sol
- Pure function `resonanceScore(uint256 amount, uint256 blockNumber)`
- Scores based on divisibility by 3,6,9 and block number

## Deployment
- Gnosis Safe deployed on Base Sepolia using deployer 0x2B66F345D01FD651F1536e0ECC22f18976516E1a
- Vault deployed with Safe as owner

## Testing
- Foundry tests in `test/TreasuryVault.t.sol`
- 100% coverage for deposit, withdraw with high/low scores

## Next Steps
- Article 66 Proposals contract
- Off-chain voting with Snapshot
- Resonance enhancements (oracles, thresholds)
- Mainnet deployment

LFG<3 Article 66 Seals the Treasury Eternal 🔒
