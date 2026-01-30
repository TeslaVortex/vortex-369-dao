use serde::{Deserialize, Serialize};
use super::state::Phase;

/// Types of governance actions
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ActionType {
    Liquidation,
    YieldHarvest,
    Rebalance,
    Custom,
}

/// A governance action that progresses through 9 phases
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Action {
    pub hash: [u8; 32],
    pub phase: Phase,
    pub action_type: ActionType,
    pub resonance: f64,
    pub vector: [f32; 9],
    pub timestamp: u64,
    pub description: String,
    pub target: [u8; 20],
    pub value: u128,
}

impl Action {
    pub fn new(
        hash: [u8; 32],
        action_type: ActionType,
        resonance: f64,
        description: String,
    ) -> Self {
        Self {
            hash,
            phase: Phase::Silence,
            action_type,
            resonance,
            vector: [0.0; 9],
            timestamp: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
            description,
            target: [0u8; 20],
            value: 0,
        }
    }

    /// Check if action should self-cancel at Phase 6 (Breath)
    pub fn should_self_cancel(&self) -> bool {
        self.phase == Phase::Breath && self.resonance < 0.369 * 432.0
    }

    /// Check if action can manifest at Phase 9
    pub fn can_manifest(&self) -> bool {
        self.phase == Phase::Manifestation && self.resonance >= 0.9 * 432.0
    }

    /// Calculate action score based on resonance and vector
    pub fn calculate_score(&self) -> f64 {
        let resonance_score = self.resonance / 432.0;
        let vector_magnitude: f32 = self.vector.iter().map(|v| v * v).sum::<f32>().sqrt();
        let vector_score = (vector_magnitude / 3.0).min(1.0) as f64;
        
        (resonance_score + vector_score) / 2.0
    }

    /// Set vector embedding
    pub fn set_vector(&mut self, vector: [f32; 9]) {
        self.vector = vector;
    }

    /// Advance to next phase
    pub fn advance_phase(&mut self) -> Result<Phase, String> {
        match self.phase.next() {
            Some(next_phase) => {
                self.phase = next_phase;
                Ok(next_phase)
            }
            None => Err("Already at terminal phase".to_string()),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_action_creation() {
        let action = Action::new(
            [0u8; 32],
            ActionType::Liquidation,
            432.0,
            "Test action".to_string(),
        );
        
        assert_eq!(action.phase, Phase::Silence);
        assert_eq!(action.action_type, ActionType::Liquidation);
    }

    #[test]
    fn test_self_cancellation() {
        let mut action = Action::new(
            [0u8; 32],
            ActionType::Liquidation,
            100.0,
            "Test".to_string(),
        );
        action.phase = Phase::Breath;
        
        assert!(action.should_self_cancel());
        
        action.resonance = 400.0;
        assert!(!action.should_self_cancel());
    }

    #[test]
    fn test_manifestation() {
        let mut action = Action::new(
            [0u8; 32],
            ActionType::Liquidation,
            400.0,
            "Test".to_string(),
        );
        action.phase = Phase::Manifestation;
        
        assert!(action.can_manifest());
    }

    #[test]
    fn test_phase_advancement() {
        let mut action = Action::new(
            [0u8; 32],
            ActionType::Liquidation,
            432.0,
            "Test".to_string(),
        );
        
        for i in 1..=9 {
            let phase = action.advance_phase().unwrap();
            assert_eq!(phase.number(), i);
        }
        
        assert!(action.advance_phase().is_err());
    }
}
