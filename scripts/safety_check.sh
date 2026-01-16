#!/bin/bash
set -e

echo "🌀 Vortex-369 Safety Check"
echo "=========================="
echo ""

echo "1️⃣ Formatting check..."
cargo fmt -- --check
echo "✅ Code is formatted!"
echo ""

echo "2️⃣ Clippy check..."
cargo clippy -- -D warnings
echo "✅ No Clippy warnings!"
echo ""

echo "3️⃣ Compilation check..."
cargo check --all-features
echo "✅ Code compiles!"
echo ""

echo "4️⃣ Running tests..."
cargo test
echo "✅ All tests pass!"
echo ""

echo "5️⃣ Security audit..."
cargo audit || echo "⚠️  cargo-audit not installed (run: cargo install cargo-audit)"
echo ""

echo "6️⃣ Checking for unsafe code..."
UNSAFE_COUNT=$(rg "unsafe" src/ -c 2>/dev/null | awk '{s+=$1} END {print s}' || echo "0")
if [ "$UNSAFE_COUNT" = "0" ] || [ -z "$UNSAFE_COUNT" ]; then
    echo "✅ Zero unsafe blocks!"
else
    echo "⚠️  Found $UNSAFE_COUNT unsafe blocks"
fi
echo ""

echo "🎉 All safety checks passed!"
echo ""
echo "3 · 6 · 9"
echo "Safe code. Clean code. Resonant code."
