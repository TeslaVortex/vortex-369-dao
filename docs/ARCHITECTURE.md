# 🏗️ Vortex-369 DAO Architecture

## System Overview

Vortex-369 is a resonance-based governance protocol with three main layers:

1. **User Interface (Web Layer)** - What users see and interact with
2. **Backend Services (API Layer)** - Processing, scoring, notifications
3. **Smart Contracts (Blockchain Layer)** - Immutable governance rules

## Component Map

```
User → Web App → API → Smart Contracts → Base Chain
              ↓
         Resonance Scoring (AI)
```

## Data Flow

1. User submits proposal via web interface
2. Backend scores proposal using 369/432 Hz resonance engine
3. Score determines auto-action:
   - Score > 66: Auto-execute through 9 phases
   - Score 33-66: Community petition option
   - Score < 33: Auto-burn

## Smart Contracts

### VortexDAO (0x983a...9fd5)
- Manages 9-phase governance lifecycle
- Handles proposal scoring and execution
- Distributes fees (9% DAO, 91% burn)

### NullOffice (0x7D2f...2bb8)
- Burns 91% of protocol fees forever
- Tracks total burned amount
- No admin control (true decentralization)

## Security Model

- Automated testing before deployment
- Manual audits for critical changes
- Proxy pattern for upgradability (coming soon)
- No private keys in code

## Tech Stack

- **Frontend:** React + TypeScript
- **Backend:** Rust + Actix-web
- **Contracts:** Solidity + Foundry
- **Blockchain:** Base (Ethereum L2)
- **AI Scoring:** Custom resonance engine

---
*Last updated: [DATE]*
