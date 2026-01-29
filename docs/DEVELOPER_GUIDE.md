# 💻 Vortex-369 DAO Developer Guide

## Quick Start (5 Minutes)

```bash
# 1. Clone the repo
git clone https://github.com/TeslaVortex/vortex-369-dao.git
cd vortex-369-dao

# 2. Run the setup script
./tools/scripts/setup-dev.sh

# 3. Start developing!
cd backend && cargo run        # Backend on localhost:8080
cd web && npm run dev          # Frontend on localhost:3000
```

That's it! You're ready to code. 🚀

## Project Structure

```
vortex-369-dao/
├── docs/              # You are here
├── web/               # Frontend React app
├── backend/           # Rust API server
├── contracts/         # Solidity smart contracts
├── deployment/        # Deployment scripts & configs
├── tests/             # All tests (unit, integration, e2e)
└── tools/             # Developer utilities
```

## Development Workflow

### 1. Pick an Issue
- Check GitHub Issues
- Find one tagged `good-first-issue`
- Comment "I'll take this!"

### 2. Create a Branch
```bash
git checkout -b feature/your-feature-name
```

### 3. Write Code
- Follow the code style guide (see below)
- Add tests for new features
- Update docs if needed

### 4. Test Locally
```bash
# Run all tests
./tools/scripts/test-all.sh

# Or run specific tests
cd backend && cargo test        # Rust tests
cd contracts && forge test      # Solidity tests
cd web && npm test              # Frontend tests
```

### 5. Submit PR
```bash
git add .
git commit -m "feat: add amazing feature"
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub!

## Code Style Guide

### Rust
```rust
// Use descriptive names
fn calculate_resonance_score(proposal: &str) -> u8 {
    // Add comments for complex logic
    let score = 0;
    
    // Use early returns
    if proposal.is_empty() {
        return 0;
    }
    
    score
}
```

### Solidity
```solidity
// Use NatSpec comments
/// @notice Calculates proposal resonance
/// @param _proposal The proposal text
/// @return score The resonance score (0-100)
function calculateResonance(string memory _proposal) 
    public 
    pure 
    returns (uint8 score) 
{
    // Implementation
}
```

### TypeScript/React
```typescript
// Use TypeScript interfaces
interface Proposal {
  id: string;
  text: string;
  score: number;
}

// Use functional components
export const ProposalCard: React.FC<{ proposal: Proposal }> = ({ proposal }) => {
  return <div>{proposal.text}</div>;
};
```

## Testing Standards

Every new feature needs:
1. **Unit tests** - Test functions in isolation
2. **Integration tests** - Test components together
3. **E2E tests** (for major features) - Test entire user flow

### Example Test
```rust
#[test]
fn test_high_resonance_keywords() {
    let proposal = "Create harmony through 369 resonance";
    let score = calculate_score(proposal);
    assert!(score > 66, "Should score high with resonance keywords");
}
```

## Smart Contract Development

### Local Testing
```bash
cd contracts

# Compile
forge build

# Test
forge test -vvv

# Deploy to local network
anvil  # In one terminal
forge script script/Deploy.s.sol --rpc-url localhost --broadcast  # In another
```

### Mainnet Deployment
**⚠️ NEVER deploy to mainnet without:**
1. Full test coverage (>80%)
2. Code review from 2+ developers
3. Security audit (for major changes)
4. Dry run on testnet

## Debugging Tips

### Backend Issues
```bash
# Enable verbose logging
RUST_LOG=debug cargo run

# Use rust-analyzer in VS Code
```

### Contract Issues
```bash
# Detailed error traces
forge test -vvvv

# Interactive debugging
forge debug
```

### Frontend Issues
```bash
# Check browser console (F12)
# Use React DevTools extension
```

## Common Tasks

### Add a New Endpoint
1. Create route in `backend/src/api/routes.rs`
2. Create handler in `backend/src/api/handlers/`
3. Add tests in `backend/tests/`
4. Update API docs

### Add a New Contract Function
1. Add function to contract in `contracts/core/`
2. Add interface in `contracts/interfaces/`
3. Write tests in `contracts/test/`
4. Update deployment script

### Add a New Frontend Component
1. Create component in `web/src/components/`
2. Create styles (use Tailwind classes)
3. Add tests in same directory
4. Export from `index.ts`

## Resources

- [Rust Book](https://doc.rust-lang.org/book/)
- [Solidity Docs](https://docs.soliditylang.org/)
- [React Docs](https://react.dev/)
- [Foundry Book](https://book.getfoundry.sh/)

## Need Help?

- Check existing code for examples
- Read the tests (they're documentation too!)
- Ask in Discord #dev-help channel
- Tag @maintainers in GitHub issues

---
*Happy coding! May your PRs merge swiftly.* 🚀
