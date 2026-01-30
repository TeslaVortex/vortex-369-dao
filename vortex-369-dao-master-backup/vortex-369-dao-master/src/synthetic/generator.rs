use rand_chacha::ChaCha20Rng;
use rand_chacha::rand_core::{SeedableRng, RngCore};
use super::types::{SyntheticEvent, EventType};

const BASE_FREQUENCY: f64 = 432.0;

/// Synthetic data generator using ChaCha20 PRNG
/// Generates privacy-preserving synthetic governance events
pub struct SyntheticGenerator {
    rng: ChaCha20Rng,
    frequency: f64,
    event_count: u64,
}

impl SyntheticGenerator {
    /// Create a new synthetic generator with a seed
    pub fn new(seed: [u8; 32], frequency: f64) -> Self {
        Self {
            rng: ChaCha20Rng::from_seed(seed),
            frequency,
            event_count: 0,
        }
    }

    /// Create from block hash (deterministic)
    pub fn from_block_hash(block_hash: [u8; 32]) -> Self {
        Self::new(block_hash, BASE_FREQUENCY)
    }

    /// Generate a synthetic event
    pub fn generate_event(&mut self) -> SyntheticEvent {
        self.event_count += 1;
        
        let event_type = self.generate_event_type();
        let resonance = self.calculate_resonance();
        let timestamp = self.generate_timestamp();
        let description = self.generate_description(&event_type);

        SyntheticEvent::new(timestamp, event_type, resonance, description)
    }

    /// Generate event type based on resonance patterns
    fn generate_event_type(&mut self) -> EventType {
        let val = (self.rng.next_u32() % 100) as u32;
        match val {
            0..=33 => EventType::Liquidation,
            34..=66 => EventType::YieldHarvest,
            67..=90 => EventType::Rebalance,
            _ => EventType::Custom,
        }
    }

    /// Calculate resonance aligned with 432 Hz
    fn calculate_resonance(&mut self) -> f64 {
        let base = self.frequency;
        let random_val = (self.rng.next_u32() as f64) / (u32::MAX as f64);
        let variation = (random_val * 0.2) - 0.1; // Range: -0.1 to 0.1
        let resonance = base * (1.0 + variation);
        
        // Apply 3·6·9 pattern
        let pattern = (self.event_count % 9) as f64;
        resonance * (1.0 + pattern * 0.01)
    }

    /// Generate timestamp with 9-second intervals
    fn generate_timestamp(&mut self) -> u64 {
        let base_time = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();
        
        // Align to 9-second intervals
        (base_time / 9) * 9 + (self.event_count % 9)
    }

    /// Generate description for event
    fn generate_description(&mut self, event_type: &EventType) -> String {
        let id = self.rng.next_u32();
        match event_type {
            EventType::Liquidation => format!("Liquidate position #{}", id % 1000),
            EventType::YieldHarvest => format!("Harvest yield from pool #{}", id % 100),
            EventType::Rebalance => format!("Rebalance strategy #{}", id % 50),
            EventType::Custom => format!("Custom action #{}", id),
        }
    }

    /// Generate a batch of events
    pub fn generate_batch(&mut self, count: usize) -> Vec<SyntheticEvent> {
        (0..count).map(|_| self.generate_event()).collect()
    }

    /// Get current event count
    pub fn event_count(&self) -> u64 {
        self.event_count
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_deterministic_generation() {
        let seed = [0u8; 32];
        let mut gen1 = SyntheticGenerator::new(seed, 432.0);
        let mut gen2 = SyntheticGenerator::new(seed, 432.0);

        let event1 = gen1.generate_event();
        let event2 = gen2.generate_event();

        assert_eq!(event1.resonance, event2.resonance);
        assert_eq!(event1.event_type, event2.event_type);
    }

    #[test]
    fn test_frequency_alignment() {
        let mut gen = SyntheticGenerator::new([0u8; 32], 432.0);
        let event = gen.generate_event();
        
        // Resonance should be close to 432 Hz
        assert!((event.resonance - 432.0).abs() < 50.0);
    }

    #[test]
    fn test_batch_generation() {
        let mut gen = SyntheticGenerator::new([0u8; 32], 432.0);
        let batch = gen.generate_batch(9);
        
        assert_eq!(batch.len(), 9);
        assert_eq!(gen.event_count(), 9);
    }
}
