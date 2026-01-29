#!/bin/bash
set -e

echo "🧪 Running Vortex-369 DAO Test Suite..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Track failures
FAILED=0

# Rust Backend Tests
echo "📦 Testing Rust Backend..."
cd backend
if cargo test --release; then
    echo -e "${GREEN}✅ Backend tests passed${NC}"
else
    echo -e "${RED}❌ Backend tests failed${NC}"
    FAILED=1
fi
cd ..

# Solidity Contract Tests
echo ""
echo "💎 Testing Smart Contracts..."
cd contracts
if forge test; then
    echo -e "${GREEN}✅ Contract tests passed${NC}"
else
    echo -e "${RED}❌ Contract tests failed${NC}"
    FAILED=1
fi
cd ..

# Frontend Tests (if they exist)
if [ -d "web" ]; then
    echo ""
    echo "🌐 Testing Frontend..."
    cd web
    if npm test -- --watchAll=false; then
        echo -e "${GREEN}✅ Frontend tests passed${NC}"
    else
        echo -e "${RED}❌ Frontend tests failed${NC}"
        FAILED=1
    fi
    cd ..
fi

# Integration Tests
echo ""
echo "🔗 Running Integration Tests..."
cd tests/integration
if cargo test; then
    echo -e "${GREEN}✅ Integration tests passed${NC}"
else
    echo -e "${RED}❌ Integration tests failed${NC}"
    FAILED=1
fi
cd ../..

# Final Result
echo ""
echo "================================"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}💥 Some tests failed${NC}"
    exit 1
fi
