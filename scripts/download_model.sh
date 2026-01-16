#!/bin/bash
# Download and prepare MiniLM-L6-v2 ONNX model for vector embeddings

set -e

MODEL_DIR="models"
MODEL_NAME="minilm_l6_v2.onnx"
MODEL_URL="https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/resolve/main/onnx/model.onnx"

echo "🌀 Vortex-369 DAO - Model Download Script"
echo "=========================================="
echo ""

# Create models directory
mkdir -p "$MODEL_DIR"

# Check if model already exists
if [ -f "$MODEL_DIR/$MODEL_NAME" ]; then
    echo "✅ Model already exists at $MODEL_DIR/$MODEL_NAME"
    echo "   Size: $(du -h "$MODEL_DIR/$MODEL_NAME" | cut -f1)"
    exit 0
fi

echo "📥 Downloading MiniLM-L6-v2 ONNX model..."
echo "   Source: $MODEL_URL"
echo "   Target: $MODEL_DIR/$MODEL_NAME"
echo ""

# Download model
if command -v wget &> /dev/null; then
    wget -O "$MODEL_DIR/$MODEL_NAME" "$MODEL_URL"
elif command -v curl &> /dev/null; then
    curl -L -o "$MODEL_DIR/$MODEL_NAME" "$MODEL_URL"
else
    echo "❌ Error: Neither wget nor curl found. Please install one of them."
    exit 1
fi

# Verify download
if [ -f "$MODEL_DIR/$MODEL_NAME" ]; then
    echo ""
    echo "✅ Model downloaded successfully!"
    echo "   Size: $(du -h "$MODEL_DIR/$MODEL_NAME" | cut -f1)"
    echo ""
    echo "📊 Model Info:"
    echo "   - Architecture: MiniLM-L6-v2"
    echo "   - Embedding Dimension: 384"
    echo "   - Reduced Dimension: 9 (phase-aware)"
    echo "   - Inference: Local (zero API cost)"
    echo ""
    echo "🎯 Next Steps:"
    echo "   1. Update VectorEmbedder to use ONNX Runtime"
    echo "   2. Run: cargo build --release"
    echo "   3. Test: cargo test embedding"
    echo ""
else
    echo "❌ Error: Download failed"
    exit 1
fi

echo "3 · 6 · 9"
echo "Zero marginal cost achieved."
