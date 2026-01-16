use super::action::Action;
use super::state::Phase;
use std::collections::HashMap;

/// Manages phase transitions and fractal scaling
pub struct PhaseEngine {
    witness_records: HashMap<[u8; 32], Vec<String>>,
}

impl PhaseEngine {
    pub fn new() -> Self {
        Self {
            witness_records: HashMap::new(),
        }
    }

    /// Advance action to next phase with validation
    pub async fn advance_phase(&mut self, action: &mut Action) -> Result<Phase, String> {
        let current_phase = action.phase;

        // Phase 6 (Breath): Self-cancellation checkpoint
        if current_phase == Phase::Breath {
            if action.should_self_cancel() {
                return Err("Action self-cancelled at Phase 6 (Breath)".to_string());
            }
        }

        // Phase 9 (Manifestation): Final gate
        if current_phase == Phase::Manifestation {
            if !action.can_manifest() {
                return Err("Action failed manifestation gate".to_string());
            }
        }

        // Record witness at Phase 7
        if current_phase == Phase::Witness {
            self.record_witness(&action.hash, &action.description);
        }

        // Advance phase
        action.advance_phase()
    }

    /// Record witness for an action
    fn record_witness(&mut self, action_hash: &[u8; 32], record: &str) {
        self.witness_records
            .entry(*action_hash)
            .or_insert_with(Vec::new)
            .push(record.to_string());
    }

    /// Get witness records for an action
    pub fn get_witness_records(&self, action_hash: &[u8; 32]) -> Option<&Vec<String>> {
        self.witness_records.get(action_hash)
    }

    /// Calculate fractal scaling factor (3→9→27→81)
    pub fn calculate_fractal_scale(&self, iteration: u32) -> u64 {
        let base: u64 = 3;
        base.pow(iteration + 1)
    }

    /// Validate phase transition is valid
    pub fn validate_transition(&self, from: Phase, to: Phase) -> bool {
        from.next() == Some(to)
    }

    /// Get phase duration in seconds (aligned with 9-second intervals)
    pub fn get_phase_duration(&self, phase: Phase) -> u64 {
        match phase {
            Phase::Silence => 9,
            Phase::Proposal => 9,
            Phase::Mirror => 9,
            Phase::Vortex => 18,  // 2x for vortex dynamics
            Phase::Resolution => 9,
            Phase::Fractal => 27, // 3x for fractal scaling
            Phase::Breath => 9,
            Phase::Witness => 9,
            Phase::Return => 9,
            Phase::Manifestation => 9,
        }
    }

    /// Calculate total cycle time
    pub fn total_cycle_time(&self) -> u64 {
        (0..=9)
            .filter_map(Phase::from_number)
            .map(|p| self.get_phase_duration(p))
            .sum()
    }
}

impl Default for PhaseEngine {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::governance::action::ActionType;

    #[tokio::test]
    async fn test_phase_advancement() {
        let mut engine = PhaseEngine::new();
        let mut action = Action::new(
            [0u8; 32],
            ActionType::Liquidation,
            432.0,
            "Test".to_string(),
        );

        for i in 1..=9 {
            let phase = engine.advance_phase(&mut action).await.unwrap();
            assert_eq!(phase.number(), i);
        }
    }

    #[tokio::test]
    async fn test_self_cancellation() {
        let mut engine = PhaseEngine::new();
        let mut action = Action::new(
            [0u8; 32],
            ActionType::Liquidation,
            100.0, // Low resonance
            "Test".to_string(),
        );

        // Advance to Phase 6 (Breath)
        for _ in 0..6 {
            engine.advance_phase(&mut action).await.unwrap();
        }

        // Should fail at Phase 6
        let result = engine.advance_phase(&mut action).await;
        assert!(result.is_err());
    }

    #[test]
    fn test_fractal_scaling() {
        let engine = PhaseEngine::new();
        
        assert_eq!(engine.calculate_fractal_scale(0), 3);
        assert_eq!(engine.calculate_fractal_scale(1), 9);
        assert_eq!(engine.calculate_fractal_scale(2), 27);
        assert_eq!(engine.calculate_fractal_scale(3), 81);
    }

    #[test]
    fn test_cycle_time() {
        let engine = PhaseEngine::new();
        let total = engine.total_cycle_time();
        
        // Should be divisible by 9
        assert_eq!(total % 9, 0);
    }
}
