#!/bin/bash
set -e

echo "🔍 Running Complete Verification..."
echo ""

# Check file structure
echo "📁 Verifying file structure..."
required_dirs=(
    "docs"
    "web"
    "backend"
    "contracts"
    "deployment"
    "tests"
    "tools"
    ".github"
)

for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✅ $dir exists"
    else
        echo "  ❌ $dir MISSING!"
        exit 1
    fi
done

# Check required files
echo ""
echo "📄 Verifying required files..."
required_files=(
    "README.md"
    "docs/ARCHITECTURE.md"
    "docs/USER_GUIDE.md"
    "docs/DEVELOPER_GUIDE.md"
    ".gitignore"
    "tools/scripts/test-all.sh"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file exists"
    else
        echo "  ❌ $file MISSING!"
        exit 1
    fi
done

# Run tests
echo ""
./tools/scripts/test-all.sh

# Check for secrets
echo ""
echo "🔒 Checking for secrets..."
if grep -r "PRIVATE_KEY" --exclude-dir=node_modules --exclude-dir=target --exclude="*.example" .; then
    echo "  ❌ Found potential secrets in code!"
    exit 1
else
    echo "  ✅ No secrets found"
fi

echo ""
echo "✨ Verification complete! Ready to push."
