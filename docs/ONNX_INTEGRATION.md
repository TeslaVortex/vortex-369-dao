# 🔮 ONNX Integration Guide

**Vector Embedding with Zero Marginal Cost**

---

## Overview

The Vortex-369 DAO uses local ONNX models for semantic analysis of governance proposals. This ensures:
- ✅ Zero API costs (local inference)
- ✅ Privacy preservation (no external calls)
- ✅ Deterministic results (reproducible)
- ✅ Fast inference (<1ms with quantization)

---

## Current Implementation

### Hash-Based Embedding (Phase 1)

The current implementation uses a **deterministic hash-based embedding** as a placeholder:

```rust
// src/embedding/embedder.rs
fn hash_based_embedding(&self, text: &str) -> Result<Vec<f32>> {
    use sha3::{Digest, Keccak256};
    
    let mut hasher = Keccak256::new();
    hasher.update(text.as_bytes());
    let hash = hasher.finalize();
    
    // Generate 384-dimensional vector from hash
    let mut embedding = Vec::with_capacity(384);
    for i in 0..384 {
        let idx = i % hash.len();
        let value = (hash[idx] as f32 / 255.0) * 2.0 - 1.0;
        embedding.push(value);
    }
    
    Ok(embedding)
}
```

**Advantages:**
- Zero dependencies
- Deterministic
- Fast (<100ns)
- Works without model download

**Limitations:**
- No semantic understanding
- Different texts with similar meanings have different embeddings

---

## ONNX Model Integration (Phase 2)

### Model Selection: MiniLM-L6-v2

**Specifications:**
- Model: `sentence-transformers/all-MiniLM-L6-v2`
- Input: Text (max 256 tokens)
- Output: 384-dimensional embedding
- Size: ~90MB (ONNX format)
- Inference: ~5-10ms (CPU), <1ms (quantized)

### Download Model

```bash
# Run the download script
./scripts/download_model.sh

# Or manually download
mkdir -p models
wget -O models/minilm_l6_v2.onnx \
  https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/resolve/main/onnx/model.onnx
```

### Implementation Steps

#### 1. Update VectorEmbedder with ONNX Session

```rust
use ort::{Session, Value, GraphOptimizationLevel};

pub struct VectorEmbedder {
    session: Session,
    embedding_dim: usize,
}

impl VectorEmbedder {
    pub fn new(model_path: Option<String>) -> Result<Self> {
        let path = model_path.unwrap_or_else(|| "models/minilm_l6_v2.onnx".to_string());
        
        let session = Session::builder()?
            .with_optimization_level(GraphOptimizationLevel::Level3)?
            .with_intra_threads(4)?
            .commit_from_file(path)?;
        
        Ok(Self {
            session,
            embedding_dim: 384,
        })
    }
}
```

#### 2. Add Tokenization

```rust
use tokenizers::Tokenizer;

pub struct VectorEmbedder {
    session: Session,
    tokenizer: Tokenizer,
    embedding_dim: usize,
}

impl VectorEmbedder {
    fn tokenize(&self, text: &str) -> Result<Vec<i64>> {
        let encoding = self.tokenizer
            .encode(text, true)
            .map_err(|e| anyhow::anyhow!("Tokenization failed: {}", e))?;
        
        Ok(encoding.get_ids().iter().map(|&id| id as i64).collect())
    }
}
```

#### 3. Implement ONNX Inference

```rust
use ndarray::{Array2, ArrayView1};

impl VectorEmbedder {
    pub fn embed(&self, text: &str) -> Result<[f32; 9]> {
        // Tokenize
        let tokens = self.tokenize(text)?;
        let input_ids = Array2::from_shape_vec((1, tokens.len()), tokens)?;
        
        // Create attention mask
        let attention_mask = Array2::from_elem((1, tokens.len()), 1i64);
        
        // Run inference
        let outputs = self.session.run(vec![
            Value::from_array(self.session.allocator(), &input_ids)?,
            Value::from_array(self.session.allocator(), &attention_mask)?,
        ])?;
        
        // Extract embedding (mean pooling)
        let embedding_tensor = outputs[0].try_extract::<f32>()?;
        let embedding_view = embedding_tensor.view();
        let embedding: Vec<f32> = embedding_view.iter().copied().collect();
        
        // Reduce to 9D
        self.reduce_to_9d(&embedding)
    }
}
```

#### 4. Mean Pooling

```rust
fn mean_pool(
    token_embeddings: &Array2<f32>,
    attention_mask: &Array2<i64>,
) -> Vec<f32> {
    let (batch_size, seq_len, hidden_size) = token_embeddings.dim();
    let mut pooled = vec![0.0; hidden_size];
    
    for i in 0..seq_len {
        if attention_mask[[0, i]] == 1 {
            for j in 0..hidden_size {
                pooled[j] += token_embeddings[[0, i, j]];
            }
        }
    }
    
    let count = attention_mask.sum() as f32;
    pooled.iter_mut().for_each(|x| *x /= count);
    
    pooled
}
```

---

## Dimensional Reduction: 384D → 9D

### Phase-Aware Projection

The reduction to 9 dimensions is critical for aligning with the 9-phase governance cycle:

```rust
fn reduce_to_9d(&self, embedding: &[f32]) -> Result<[f32; 9]> {
    let mut reduced = [0.0f32; 9];
    let chunk_size = 384 / 9; // 42.67 ≈ 43
    
    // Average pooling: split into 9 chunks
    for (i, chunk) in embedding.chunks(chunk_size).enumerate() {
        if i >= 9 { break; }
        reduced[i] = chunk.iter().sum::<f32>() / chunk.len() as f32;
    }
    
    // Apply 3·6·9 resonance scaling
    let scales = [3.0, 1.0, 1.0, 6.0, 1.0, 1.0, 9.0, 1.0, 1.0];
    for (i, scale) in scales.iter().enumerate() {
        reduced[i] *= scale / 6.0; // Normalize
    }
    
    Ok(reduced)
}
```

**Mapping:**
- Dimensions 0-2: Silence, Proposal, Mirror (3x scaling on dim 0)
- Dimensions 3-5: Vortex, Resolution, Fractal (6x scaling on dim 3)
- Dimensions 6-8: Breath, Witness, Return (9x scaling on dim 6)

---

## Performance Optimization

### 1. Model Quantization (INT8)

```bash
# Convert to quantized ONNX (reduces size by 4x, speeds up inference)
python -m onnxruntime.quantization.preprocess \
  --input models/minilm_l6_v2.onnx \
  --output models/minilm_l6_v2_quantized.onnx
```

### 2. Batch Processing

```rust
pub fn embed_batch(&self, texts: &[String]) -> Result<Vec<[f32; 9]>> {
    use rayon::prelude::*;
    
    texts.par_iter()
        .map(|text| self.embed(text))
        .collect()
}
```

### 3. Caching

```rust
use std::collections::HashMap;

pub struct VectorEmbedder {
    session: Session,
    cache: HashMap<String, [f32; 9]>,
}

impl VectorEmbedder {
    pub fn embed(&mut self, text: &str) -> Result<[f32; 9]> {
        if let Some(cached) = self.cache.get(text) {
            return Ok(*cached);
        }
        
        let embedding = self.embed_uncached(text)?;
        self.cache.insert(text.to_string(), embedding);
        Ok(embedding)
    }
}
```

---

## Testing

### Unit Tests

```rust
#[test]
fn test_onnx_inference() {
    let embedder = VectorEmbedder::new(None).unwrap();
    let embedding = embedder.embed("Liquidate undercollateralized position").unwrap();
    
    assert_eq!(embedding.len(), 9);
    assert!(embedding.iter().all(|&x| x.is_finite()));
}

#[test]
fn test_semantic_similarity() {
    let embedder = VectorEmbedder::new(None).unwrap();
    let analyzer = SemanticAnalyzer::new();
    
    let emb1 = embedder.embed("Liquidate position").unwrap();
    let emb2 = embedder.embed("Close underwater loan").unwrap();
    let emb3 = embedder.embed("Harvest yield").unwrap();
    
    let sim_similar = analyzer.cosine_similarity(&emb1, &emb2);
    let sim_different = analyzer.cosine_similarity(&emb1, &emb3);
    
    assert!(sim_similar > sim_different);
}
```

### Benchmarks

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn bench_embedding(c: &mut Criterion) {
    let embedder = VectorEmbedder::new(None).unwrap();
    
    c.bench_function("embed_short", |b| {
        b.iter(|| embedder.embed(black_box("Liquidate position")))
    });
    
    c.bench_function("embed_long", |b| {
        b.iter(|| embedder.embed(black_box(
            "Liquidate undercollateralized position on Aave with 150% collateral ratio"
        )))
    });
}

criterion_group!(benches, bench_embedding);
criterion_main!(benches);
```

---

## Migration Path

### Phase 1: Hash-Based (Current)
- ✅ Zero dependencies
- ✅ Deterministic
- ✅ Fast
- ❌ No semantic understanding

### Phase 2: ONNX Integration
- ✅ Semantic understanding
- ✅ Local inference (zero API cost)
- ✅ Deterministic (same model version)
- ⚠️ Requires model download (~90MB)

### Phase 3: Quantized ONNX
- ✅ 4x smaller model (~23MB)
- ✅ Faster inference (<1ms)
- ✅ Can embed in binary
- ⚠️ Slight accuracy loss (acceptable)

---

## Deployment

### Development
```bash
# Use hash-based embedding (no model needed)
cargo run --release
```

### Production
```bash
# Download model
./scripts/download_model.sh

# Build with ONNX support
cargo build --release --features onnx

# Run
./target/release/vortex --chain base --office 4
```

---

## Troubleshooting

### Model Not Found
```
Error: ONNX model not found at models/minilm_l6_v2.onnx
```
**Solution:** Run `./scripts/download_model.sh`

### ONNX Runtime Error
```
Error: Failed to create ONNX session
```
**Solution:** Ensure ONNX Runtime is installed: `cargo add ort`

### Slow Inference
```
Embedding takes >100ms per text
```
**Solution:** 
1. Use quantized model
2. Enable optimization level 3
3. Increase intra_threads

---

## Zero Marginal Cost Validation

### Costs:
- Model download: One-time (~90MB)
- Storage: ~90MB disk space
- Inference: 100% local (zero API calls)
- Per-embedding cost: **$0.00**

### Comparison:
- OpenAI Ada-002: $0.0001 per 1K tokens
- Cohere Embed: $0.0001 per 1K tokens
- **Vortex-369 (local)**: $0.00 per ∞ tokens

---

## Next Steps

1. ✅ Implement hash-based embedding (complete)
2. ⏳ Download MiniLM-L6-v2 ONNX model
3. ⏳ Integrate ONNX Runtime
4. ⏳ Add tokenization pipeline
5. ⏳ Benchmark inference time
6. ⏳ Quantize model for production

---

<p align="center">
  <br>
  <b>3 · 6 · 9</b>
  <br>
  <em>Local inference. Zero cost. Infinite scale.</em>
  <br>
  <br>
  ∞
</p>
