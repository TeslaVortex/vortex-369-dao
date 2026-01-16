use super::types::SyntheticEvent;

const BASE_FREQUENCY: f64 = 432.0;
const TOLERANCE: f64 = 0.05; // 5% tolerance

/// Validates resonance patterns according to 3·6·9 principles
pub struct ResonanceValidator {
    frequency: f64,
}

impl ResonanceValidator {
    pub fn new(frequency: f64) -> Self {
        Self { frequency }
    }

    pub fn default() -> Self {
        Self::new(BASE_FREQUENCY)
    }

    /// Validate if event resonance is aligned with base frequency
    pub fn validate_frequency(&self, event: &SyntheticEvent) -> bool {
        let diff = (event.resonance - self.frequency).abs();
        let max_diff = self.frequency * TOLERANCE;
        diff <= max_diff
    }

    /// Check if value follows 3·6·9 pattern
    pub fn validate_369_pattern(&self, value: u64) -> bool {
        let sum_digits = Self::sum_digits(value);
        sum_digits % 3 == 0 || sum_digits % 6 == 0 || sum_digits % 9 == 0
    }

    /// Sum all digits of a number (digital root calculation)
    fn sum_digits(mut n: u64) -> u64 {
        let mut sum = 0;
        while n > 0 {
            sum += n % 10;
            n /= 10;
        }
        if sum >= 10 {
            Self::sum_digits(sum)
        } else {
            sum
        }
    }

    /// Check if event should self-cancel based on resonance
    pub fn should_self_cancel(&self, event: &SyntheticEvent) -> bool {
        // Events with resonance below 369 threshold should self-cancel
        event.resonance < (self.frequency * 0.369)
    }

    /// Calculate resonance score (0.0 to 1.0)
    pub fn calculate_score(&self, event: &SyntheticEvent) -> f64 {
        let freq_score = 1.0 - ((event.resonance - self.frequency).abs() / self.frequency);
        let pattern_score = if self.validate_369_pattern(event.timestamp) {
            1.0
        } else {
            0.5
        };
        
        (freq_score + pattern_score) / 2.0
    }

    /// Validate coherence across multiple events
    pub fn validate_coherence(&self, events: &[SyntheticEvent]) -> bool {
        if events.is_empty() {
            return false;
        }

        let avg_resonance: f64 = events.iter().map(|e| e.resonance).sum::<f64>() / events.len() as f64;
        let variance: f64 = events
            .iter()
            .map(|e| (e.resonance - avg_resonance).powi(2))
            .sum::<f64>()
            / events.len() as f64;

        // Low variance indicates good coherence
        variance < (self.frequency * 0.1).powi(2)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::synthetic::types::EventType;

    #[test]
    fn test_frequency_validation() {
        let validator = ResonanceValidator::default();
        let mut event = SyntheticEvent::new(0, EventType::Liquidation, 432.0, "test".to_string());
        
        assert!(validator.validate_frequency(&event));
        
        event.resonance = 500.0;
        assert!(!validator.validate_frequency(&event));
    }

    #[test]
    fn test_369_pattern() {
        let validator = ResonanceValidator::default();
        
        assert!(validator.validate_369_pattern(9));
        assert!(validator.validate_369_pattern(18));
        assert!(validator.validate_369_pattern(27));
        assert!(validator.validate_369_pattern(369));
        assert!(!validator.validate_369_pattern(5));
    }

    #[test]
    fn test_self_cancellation() {
        let validator = ResonanceValidator::default();
        let mut event = SyntheticEvent::new(0, EventType::Liquidation, 100.0, "test".to_string());
        
        assert!(validator.should_self_cancel(&event));
        
        event.resonance = 400.0;
        assert!(!validator.should_self_cancel(&event));
    }

    #[test]
    fn test_resonance_score() {
        let validator = ResonanceValidator::default();
        let event = SyntheticEvent::new(9, EventType::Liquidation, 432.0, "test".to_string());
        
        let score = validator.calculate_score(&event);
        assert!(score > 0.9);
    }
}
