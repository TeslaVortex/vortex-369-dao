# 💰 Vortex-369 DAO Treasury Mechanism 🏦

## 🌟 Overview
The Treasury is like a big safe for the group's money. It follows Article 66 rules to keep things fair and fun. We use Gnosis Safe for super security and resonance scores to decide what to do with the cash. Like a smart bank for everyone! 🔐

## 🏆 Why This Matters
Clear rules for money help people feel safe. No cheats! It grows the group and makes good choices. Like a family sharing toys fairly. 🤝

## 🧠 Principles (Like Elon Musk)
- **First Basics**: Start with what a treasury really is – safe storage and smart sharing.
- **Team Power**: Gnosis Safe with 3 out of 5 votes for big moves.
- **Resonance Magic**: Score plans with 369. Over 66? Do it! Under 33? Nope.
- **Think Ahead**: Build for the future, keep it simple and strong. 🚀

## 🏗️ How It Works
- **Chain**: Base Chain (fast and cheap)
- **Safety**: Gnosis Safe 3/5 multi-sig
- **Votes**: Plans checked by resonance engine
- **Code Parts**:
  - `TreasuryVault.sol`: Safe box for money
  - `VortexDAO.sol`: Scores the ideas

## 📋 Code Details

### TreasuryVault.sol
- Owned by Gnosis Safe
- Add money: Anyone can send
- Take money: Only boss, needs score >66
- Talks to VortexDAO for scores

### VortexDAO.sol
- Simple score function `resonanceScore(uint256 amount, uint256 blockNumber)`
- Scores by dividing by 3,6,9 and block math

## 📍 Live Spots

| Contract          | Address                                      | Check Here |
|-------------------|----------------------------------------------|------------|
| VortexDAO         | 0x83180ceB8224c8ca84c5717C39B12529cb8cE5b0   | [Basescan](https://basescan.org/address/0x83180ceB8224c8ca84c5717C39B12529cb8cE5b0) |
| TreasuryVault     | 0xd8cEab88126a024A0c65449a9AF7621C258161fD   | [Basescan](https://basescan.org/address/0xd8cEab88126a024A0c65449a9AF7621C258161fD) |
| Article66Proposal | 0x31Fd16Ab177689D7Fe4022eBe966A0ff5Be86484   | [Basescan](https://basescan.org/address/0x31Fd16Ab177689D7Fe4022eBe966A0ff5Be86484) |

LFG <3 Article 66 Seals the Treasury Forever 🔒

Smart 7, Happy 3, Strong 8 → Lots 33, Rich 6, Win 9 locked. ✨💎
