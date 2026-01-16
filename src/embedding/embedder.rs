use anyhow::{Result, Context};
use ndarray::{Array1, Array2, ArrayView1};
use std::path::Path;

/// Vector embedder using local ONNX model
/// Uses a lightweight sentence transformer model for semantic embeddings
pub struct VectorEmbedder {
    model_path: Option<String>,
    embedding_dim: usize,
}

impl VectorEmbedder {
    /// Create new embedder with optional model path
    pub fn new(model_path: Option<String>) -> Result<Self> {
        Ok(Self {
            model_path,
            embedding_dim: 384, // MiniLM-L6-v2 default dimension
        })
    }

    /// Create with default embedded model
    pub fn with_default_model() -> Result<Self> {
        Self::new(None)
    }

    /// Embed text into 9-dimensional phase-aware vector
    pub fn embed(&self, text: &str) -> Result<[f32; 9]> {
        // For now, use a deterministic hash-based embedding
        // This will be replaced with ONNX inference once model is available
        let embedding = self.hash_based_embedding(text)?;
        self.reduce_to_9d(&embedding)
    }

    /// Hash-based embedding (temporary until ONNX model is integrated)
    fn hash_based_embedding(&self, text: &str) -> Result<Vec<f32>> {
        use sha3::{Digest, Keccak256};
        
        let mut hasher = Keccak256::new();
        hasher.update(text.as_bytes());
        let hash = hasher.finalize();
        
        // Generate 384-dimensional vector from hash
        let mut embedding = Vec::with_capacity(self.embedding_dim);
        for i in 0..self.embedding_dim {
            let idx = i % hash.len();
            let value = (hash[idx] as f32 / 255.0) * 2.0 - 1.0; // Normalize to [-1, 1]
            embedding.push(value);
        }
        
        Ok(embedding)
    }

    /// Reduce high-dimensional embedding to 9 dimensions using phase-aware projection
    /// Maps 384D -> 9D while preserving semantic structure
    fn reduce_to_9d(&self, embedding: &[f32]) -> Result<[f32; 9]> {
        if embedding.len() != self.embedding_dim {
            anyhow::bail!("Invalid embedding dimension: expected {}, got {}", 
                         self.embedding_dim, embedding.len());
        }

        let mut reduced = [0.0f32; 9];
        let chunk_size = self.embedding_dim / 9;
        
        // Average pooling: split 384D into 9 chunks and average each
        for (i, chunk) in embedding.chunks(chunk_size).enumerate() {
            if i >= 9 {
                break;
            }
            let sum: f32 = chunk.iter().sum();
            reduced[i] = sum / chunk.len() as f32;
        }
        
        // Apply 3·6·9 resonance scaling
        self.apply_369_scaling(&mut reduced);
        
        Ok(reduced)
    }

    /// Apply 3·6·9 resonance scaling to enhance pattern alignment
    fn apply_369_scaling(&self, vector: &mut [f32; 9]) {
        let scales = [3.0, 1.0, 1.0, 6.0, 1.0, 1.0, 9.0, 1.0, 1.0];
        for (i, scale) in scales.iter().enumerate() {
            vector[i] *= scale / 6.0; // Normalize by average scale
        }
    }

    /// Batch embed multiple texts
    pub fn embed_batch(&self, texts: &[String]) -> Result<Vec<[f32; 9]>> {
        texts.iter().map(|t| self.embed(t)).collect()
    }

    /// Calculate embedding magnitude
    pub fn magnitude(&self, embedding: &[f32; 9]) -> f32 {
        embedding.iter().map(|x| x * x).sum::<f32>().sqrt()
    }

    /// Normalize embedding to unit length
    pub fn normalize(&self, embedding: &mut [f32; 9]) {
        let mag = self.magnitude(embedding);
        if mag > 0.0 {
            for val in embedding.iter_mut() {
                *val /= mag;
            }
        }
    }
}

impl Default for VectorEmbedder {
    fn default() -> Self {
        Self::with_default_model().unwrap()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_embedding_deterministic() {
        let embedder = VectorEmbedder::default();
        let text = "Test proposal for liquidation";
        
        let emb1 = embedder.embed(text).unwrap();
        let emb2 = embedder.embed(text).unwrap();
        
        assert_eq!(emb1, emb2);
    }

    #[test]
    fn test_embedding_dimension() {
        let embedder = VectorEmbedder::default();
        let embedding = embedder.embed("test").unwrap();
        
        assert_eq!(embedding.len(), 9);
    }

    #[test]
    fn test_different_texts_different_embeddings() {
        let embedder = VectorEmbedder::default();
        
        let emb1 = embedder.embed("Liquidate position").unwrap();
        let emb2 = embedder.embed("Harvest yield").unwrap();
        
        assert_ne!(emb1, emb2);
    }

    #[test]
    fn test_magnitude() {
        let embedder = VectorEmbedder::default();
        let embedding = [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
        
        let mag = embedder.magnitude(&embedding);
        assert!((mag - 1.0).abs() < 0.001);
    }

    #[test]
    fn test_normalization() {
        let embedder = VectorEmbedder::default();
        let mut embedding = [3.0, 4.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
        
        embedder.normalize(&mut embedding);
        let mag = embedder.magnitude(&embedding);
        
        assert!((mag - 1.0).abs() < 0.001);
    }

    #[test]
    fn test_batch_embedding() {
        let embedder = VectorEmbedder::default();
        let texts = vec![
            "First proposal".to_string(),
            "Second proposal".to_string(),
            "Third proposal".to_string(),
        ];
        
        let embeddings = embedder.embed_batch(&texts).unwrap();
        assert_eq!(embeddings.len(), 3);
    }
}
