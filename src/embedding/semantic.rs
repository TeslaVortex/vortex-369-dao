use anyhow::Result;

/// Semantic analyzer for proposal similarity
pub struct SemanticAnalyzer {
}

impl SemanticAnalyzer {
    pub fn new() -> Self {
        Self {}
    }

    /// Calculate cosine similarity between two vectors
    pub fn cosine_similarity(&self, a: &[f32; 9], b: &[f32; 9]) -> f32 {
        let dot: f32 = a.iter().zip(b.iter()).map(|(x, y)| x * y).sum();
        let mag_a: f32 = a.iter().map(|x| x * x).sum::<f32>().sqrt();
        let mag_b: f32 = b.iter().map(|x| x * x).sum::<f32>().sqrt();
        
        if mag_a == 0.0 || mag_b == 0.0 {
            0.0
        } else {
            dot / (mag_a * mag_b)
        }
    }

    /// Generate anti-proposal vector
    pub fn generate_anti_proposal(&self, vector: &[f32; 9]) -> [f32; 9] {
        let mut anti = [0.0; 9];
        for (i, v) in vector.iter().enumerate() {
            anti[i] = -v;
        }
        anti
    }

    /// Calculate resonance score
    pub fn calculate_resonance_score(&self, vector: &[f32; 9]) -> f64 {
        let magnitude: f32 = vector.iter().map(|x| x * x).sum::<f32>().sqrt();
        (magnitude / 3.0).min(1.0) as f64
    }
}

impl Default for SemanticAnalyzer {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cosine_similarity() {
        let analyzer = SemanticAnalyzer::new();
        let a = [1.0; 9];
        let b = [1.0; 9];
        
        let sim = analyzer.cosine_similarity(&a, &b);
        assert!((sim - 1.0).abs() < 0.001);
    }

    #[test]
    fn test_anti_proposal() {
        let analyzer = SemanticAnalyzer::new();
        let vector = [1.0; 9];
        let anti = analyzer.generate_anti_proposal(&vector);
        
        assert_eq!(anti[0], -1.0);
    }
}
