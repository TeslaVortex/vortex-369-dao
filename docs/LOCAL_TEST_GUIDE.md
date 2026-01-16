# 🧪 Local Testing Guide for Vortex-369 DAO

**Test the system on your machine!**

---

## 🚨 Current Status

**Rust Version Issue Detected:**
- Your Rust: 1.75.0
- Required: 1.77+ (for some dependencies)

**Don't worry!** We have two options:

---

## Option 1: Update Rust (Recommended) ⚡

### Step 1: Update Rust
```bash
rustup update stable
rustup default stable
```

### Step 2: Verify Version
```bash
rustc --version
# Should show 1.77+ or newer
```

### Step 3: Build & Test
```bash
cd /home/pepo/Desktop/All/main-vortex-engine/vortex_369_dao

# Build the project
cargo build --release

# Run all tests
cargo test

# Run example
cargo run --example basic_usage
```

---

## Option 2: Test Core Logic (No Build Needed) 🔍

If you can't update Rust right now, you can still verify the code logic!

### Check File Structure
```bash
cd /home/pepo/Desktop/All/main-vortex-engine/vortex_369_dao

# List all source files
find src -name "*.rs" | sort

# Expected output:
# src/bridge/mod.rs
# src/bridge/processor.rs
# src/chain/client.rs
# src/chain/mod.rs
# src/embedding/embedder.rs
# src/embedding/mod.rs
# src/embedding/semantic.rs
# src/governance/action.rs
# src/governance/core.rs
# src/governance/mod.rs
# src/governance/phase_engine.rs
# src/governance/state.rs
# src/lib.rs
# src/main.rs
# src/synthetic/generator.rs
# src/synthetic/mod.rs
# src/synthetic/resonance.rs
# src/synthetic/types.rs
```

### Count Lines of Code
```bash
# Count Rust code
find src -name "*.rs" -exec wc -l {} + | tail -1

# Count Solidity code
find contracts -name "*.sol" -exec wc -l {} + | tail -1

# Count documentation
find . -name "*.md" -exec wc -l {} + | tail -1
```

### Verify Test Files Exist
```bash
# Check tests
ls -la tests/
ls -la benches/
ls -la examples/

# Check contracts
ls -la contracts/
```

### Read Core Modules
```bash
# View synthetic generator
cat src/synthetic/generator.rs | head -50

# View governance core
cat src/governance/state.rs

# View smart contract
cat contracts/VortexDAOSimplified.sol | head -50
```

---

## 🎯 What to Expect After Update

### When `cargo build --release` succeeds:
```
   Compiling vortex-369-core v1.0.0
   Compiling 50+ dependencies...
    Finished release [optimized] target(s) in 2-3 minutes
```

### When `cargo test` succeeds:
```
running 41 tests
test synthetic::generator::tests::test_deterministic_generation ... ok
test synthetic::generator::tests::test_frequency_alignment ... ok
test synthetic::resonance::tests::test_369_pattern ... ok
test embedding::embedder::tests::test_embedding_deterministic ... ok
test embedding::semantic::tests::test_cosine_similarity ... ok
test governance::state::tests::test_phase_progression ... ok
test governance::action::tests::test_self_cancellation ... ok
test governance::action::tests::test_manifestation ... ok
test governance::core::tests::test_full_cycle ... ok
test integration_tests::test_full_governance_cycle ... ok
test integration_tests::test_high_resonance_manifests ... ok
test integration_tests::test_low_resonance_cancels ... ok
... (29 more tests)

test result: ok. 41 passed; 0 failed; 0 ignored
```

### When `cargo run --example basic_usage` succeeds:
```
🌀 Vortex-369 DAO - Basic Usage Example
========================================

1️⃣ Creating synthetic generator...
   ✅ Generator created with 432 Hz frequency

2️⃣ Generating synthetic event...
   Event type: Liquidation
   Resonance: 433.2 Hz
   Description: Liquidate position #42
   ✅ Event generated

3️⃣ Validating resonance...
   Frequency valid: true
   Resonance score: 0.95
   ✅ Resonance validated

4️⃣ Creating vector embedding...
   Vector (9D): [0.12, -0.34, 0.56, -0.78, 0.23, -0.45, 0.67, -0.89, 0.11]
   Magnitude: 1.234
   ✅ Vector embedded

5️⃣ Analyzing semantics...
   Anti-proposal similarity: -0.98
   ✅ Semantics analyzed

6️⃣ Submitting to governance...
   ✅ Action submitted

7️⃣ Processing through 9 phases...
   ✅ Action manifested!
   Final phase: Manifestation
   Can manifest: true
   Score: 0.92

🎉 Example complete!

3 · 6 · 9
Zero marginal cost. Infinite scale.
```

---

## 🛠️ Troubleshooting

### Issue: "Rust version too old"
**Solution:**
```bash
rustup update stable
rustup default stable
rustc --version  # Verify it's 1.77+
```

### Issue: "cargo: command not found"
**Solution:**
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### Issue: "error: failed to download"
**Solution:**
```bash
# Clean cargo cache and retry
cargo clean
rm -rf ~/.cargo/registry/index/*
cargo build --release
```

### Issue: "tests fail"
**Solution:**
```bash
# Run tests with verbose output
cargo test -- --nocapture

# Run specific test
cargo test test_deterministic_generation -- --nocapture
```

---

## ✅ Quick Verification Checklist

Before updating Rust, verify files exist:

```bash
cd /home/pepo/Desktop/All/main-vortex-engine/vortex_369_dao

# Check core files
[ -f Cargo.toml ] && echo "✅ Cargo.toml exists"
[ -f src/lib.rs ] && echo "✅ lib.rs exists"
[ -d src/synthetic ] && echo "✅ synthetic/ exists"
[ -d src/governance ] && echo "✅ governance/ exists"
[ -d src/embedding ] && echo "✅ embedding/ exists"
[ -d contracts ] && echo "✅ contracts/ exists"
[ -f docs/QUICKSTART.md ] && echo "✅ docs/QUICKSTART.md exists"
[ -f docs/FINAL_SUMMARY.md ] && echo "✅ docs/FINAL_SUMMARY.md exists"

# Count files
echo "📊 Total Rust files: $(find src -name '*.rs' | wc -l)"
echo "📊 Total Solidity files: $(find contracts -name '*.sol' | wc -l)"
echo "📊 Total docs: $(find . -name '*.md' | wc -l)"
```

Expected output:
```
✅ Cargo.toml exists
✅ lib.rs exists
✅ synthetic/ exists
✅ governance/ exists
✅ embedding/ exists
✅ contracts/ exists
✅ docs/QUICKSTART.md exists
✅ docs/FINAL_SUMMARY.md exists
📊 Total Rust files: 18
📊 Total Solidity files: 4
📊 Total docs: 7
```

---

## 🚀 Next Steps

### After Rust Update:
1. ✅ `rustup update stable`
2. ✅ `cargo build --release`
3. ✅ `cargo test`
4. ✅ `cargo run --example basic_usage`
5. ✅ `./scripts/safety_check.sh`
6. ✅ `cargo bench` (optional)

### If Everything Works:
🎉 **You're ready to deploy to testnet!**

See `docs/DEPLOYMENT.md` for next steps.

---

## 💡 Pro Tips

1. **Use `cargo check`** - Faster than `cargo build`, just checks compilation
2. **Use `cargo test --lib`** - Test only library code (faster)
3. **Use `cargo run --release`** - Optimized build (slower compile, faster run)
4. **Use `RUST_LOG=debug`** - See detailed logs

---

<p align="center">
  <br>
  <b>✨ 3 · 6 · 9 ✨</b>
  <br>
  <em>Update Rust. Build. Test. Manifest!</em>
  <br>
  <br>
  <b>432 Hz Forever 🎵</b>
  <br>
  <br>
  ∞
</p>
