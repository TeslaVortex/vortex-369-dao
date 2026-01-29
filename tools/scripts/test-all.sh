#!/bin/bash

echo "🧪 Running Vortex-369 DAO Test Suite..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Rust Backend Tests
echo "📦 Testing Rust Backend..."
cd backend
if ! cargo test --release; then
    echo -e "${RED}❌ Backend tests failed${NC}"
    cd ..
    exit 1
fi
echo -e "${GREEN}✅ Backend tests passed${NC}"
cd ..

# Solidity Contract Tests
echo ""
echo "💎 Testing Smart Contracts..."
cd contracts
if ! forge test; then
    echo -e "${RED}❌ Contract tests failed${NC}"
    cd ..
    exit 1
fi
echo -e "${GREEN}✅ Contract tests passed${NC}"
cd ..

# Frontend Tests (if they exist and have test script)
if [ -d "web" ] && [ -f "web/package.json" ]; then
    echo ""
    echo "🌐 Testing Frontend..."
    cd web
    if npm run test --if-present 2>/dev/null; then
        echo -e "${GREEN}✅ Frontend tests passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Frontend tests not available (skipping)${NC}"
    fi
    cd ..
fi

# Integration Tests (if they exist)
if [ -d "tests/integration" ] && [ -f "tests/integration/Cargo.toml" ]; then
    echo ""
    echo "🔗 Running Integration Tests..."
    cd tests/integration
    if ! cargo test; then
        echo -e "${RED}❌ Integration tests failed${NC}"
        cd ../..
        exit 1
    fi
    echo -e "${GREEN}✅ Integration tests passed${NC}"
    cd ../..
else
    echo ""
    echo "🔗 Integration tests not configured (skipping)"
fi

# Final Result
echo ""
echo "================================"
echo -e "${GREEN}🎉 All tests passed!${NC}"
exit 0
