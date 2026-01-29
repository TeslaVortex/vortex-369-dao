#!/bin/bash
set -e

echo "🌀 Setting up Vortex-369 DAO development environment..."
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

command -v git >/dev/null 2>&1 || { echo "❌ Git not found. Install it first."; exit 1; }
echo "✅ Git found"

command -v node >/dev/null 2>&1 || { echo "❌ Node.js not found. Install it first."; exit 1; }
echo "✅ Node.js found"

command -v cargo >/dev/null 2>&1 || { echo "❌ Rust/Cargo not found. Install it first."; exit 1; }
echo "✅ Rust found"

command -v forge >/dev/null 2>&1 || { echo "❌ Foundry not found. Install it first."; exit 1; }
echo "✅ Foundry found"

# Install backend dependencies
echo ""
echo "📦 Installing backend dependencies..."
cd backend
cargo build
cd ..

# Install frontend dependencies
if [ -d "web" ]; then
    echo ""
    echo "🌐 Installing frontend dependencies..."
    cd web
    npm install
    cd ..
fi

# Install contract dependencies
echo ""
echo "💎 Installing contract dependencies..."
cd contracts
forge install
cd ..

# Create environment files
echo ""
echo "⚙️ Creating environment files..."
if [ ! -f ".env" ]; then
    cp deployment/configs/local.env.example .env
    echo "📝 Created .env file - please configure it!"
fi

# Setup git hooks
echo ""
echo "🎣 Setting up git hooks..."
cat > .git/hooks/pre-commit << 'HOOK'
#!/bin/bash
echo "Running tests before commit..."
./tools/scripts/test-all.sh
HOOK
chmod +x .git/hooks/pre-commit

echo ""
echo "✨ Setup complete! You're ready to develop."
echo ""
echo "Next steps:"
echo "  1. Configure .env file with your settings"
echo "  2. Run: cd backend && cargo run"
echo "  3. Run: cd web && npm run dev"
echo "  4. Start coding! 🚀"
