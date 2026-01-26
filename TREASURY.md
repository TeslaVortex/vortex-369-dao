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

## Deployments

| Contract          | Address                                      | Basescan Link |
|-------------------|----------------------------------------------|---------------|
| VortexDAO         | 0x83180ceB8224c8ca84c5717C39B12529cb8cE5b0   | [Basescan](https://basescan.org/address/0x83180ceB8224c8ca84c5717C39B12529cb8cE5b0) |
| TreasuryVault     | 0xd8cEab88126a024A0c65449a9AF7621C258161fD   | [Basescan](https://basescan.org/address/0xd8cEab88126a024A0c65449a9AF7621C258161fD) |
| Article66Proposal | 0x31Fd16Ab177689D7Fe4022eBe966A0ff5Be86484   | [Basescan](https://basescan.org/address/0x31Fd16Ab177689D7Fe4022eBe966A0ff5Be86484) |

LFG<3 Article 66 Seals the Treasury Eternal 🔒

Wisdom 7, Joy 3, Power 8 → Abundance 33, Wealth 6, Success 9 sealed.
