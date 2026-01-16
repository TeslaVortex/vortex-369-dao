use super::action::{Action, ActionType};
use super::phase_engine::PhaseEngine;
use super::state::Phase;
use std::collections::HashMap;
use anyhow::Result;

/// Main governance engine managing all actions
pub struct GovernanceEngine {
    actions: HashMap<[u8; 32], Action>,
    phase_engine: PhaseEngine,
}

impl GovernanceEngine {
    pub fn new() -> Self {
        Self {
            actions: HashMap::new(),
            phase_engine: PhaseEngine::new(),
        }
    }

    /// Submit a new action to governance
    pub fn submit_action(
        &mut self,
        hash: [u8; 32],
        action_type: ActionType,
        resonance: f64,
        description: String,
    ) -> Result<()> {
        let action = Action::new(hash, action_type, resonance, description);
        self.actions.insert(hash, action);
        Ok(())
    }

    /// Get action by hash
    pub fn get_action(&self, hash: &[u8; 32]) -> Option<&Action> {
        self.actions.get(hash)
    }

    /// Get mutable action by hash
    pub fn get_action_mut(&mut self, hash: &[u8; 32]) -> Option<&mut Action> {
        self.actions.get_mut(hash)
    }

    /// Advance action to next phase
    pub async fn advance_action_phase(&mut self, hash: &[u8; 32]) -> Result<Phase> {
        let action = self
            .actions
            .get_mut(hash)
            .ok_or_else(|| anyhow::anyhow!("Action not found"))?;

        let new_phase = self.phase_engine.advance_phase(action).await
            .map_err(|e| anyhow::anyhow!(e))?;

        Ok(new_phase)
    }

    /// Process event through governance
    pub async fn process_event(
        &mut self,
        hash: [u8; 32],
        action_type: ActionType,
        resonance: f64,
        description: String,
        vector: [f32; 9],
    ) -> Result<Action> {
        // Submit action
        self.submit_action(hash, action_type, resonance, description)?;

        // Set vector embedding
        if let Some(action) = self.get_action_mut(&hash) {
            action.set_vector(vector);
        }

        // Progress through all phases
        for _ in 0..10 {
            match self.advance_action_phase(&hash).await {
                Ok(phase) => {
                    if phase == Phase::Manifestation {
                        break;
                    }
                }
                Err(e) => {
                    // Remove action if it fails
                    self.actions.remove(&hash);
                    return Err(e);
                }
            }
        }

        // Return final action
        self.actions
            .get(&hash)
            .cloned()
            .ok_or_else(|| anyhow::anyhow!("Action was removed"))
    }

    /// Get all actions in a specific phase
    pub fn get_actions_by_phase(&self, phase: Phase) -> Vec<&Action> {
        self.actions
            .values()
            .filter(|a| a.phase == phase)
            .collect()
    }

    /// Get actions ready for manifestation
    pub fn get_manifestable_actions(&self) -> Vec<&Action> {
        self.actions
            .values()
            .filter(|a| a.phase == Phase::Manifestation && a.can_manifest())
            .collect()
    }

    /// Remove action (after execution or cancellation)
    pub fn remove_action(&mut self, hash: &[u8; 32]) -> Option<Action> {
        self.actions.remove(hash)
    }

    /// Get total number of active actions
    pub fn action_count(&self) -> usize {
        self.actions.len()
    }

    /// Clear all actions
    pub fn clear(&mut self) {
        self.actions.clear();
    }
}

impl Default for GovernanceEngine {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_submit_and_retrieve() {
        let mut engine = GovernanceEngine::new();
        let hash = [1u8; 32];

        engine
            .submit_action(hash, ActionType::Liquidation, 432.0, "Test".to_string())
            .unwrap();

        let action = engine.get_action(&hash).unwrap();
        assert_eq!(action.hash, hash);
        assert_eq!(action.phase, Phase::Silence);
    }

    #[tokio::test]
    async fn test_full_cycle() {
        let mut engine = GovernanceEngine::new();
        let hash = [2u8; 32];

        let action = engine
            .process_event(
                hash,
                ActionType::Liquidation,
                432.0,
                "Test action".to_string(),
                [0.5; 9],
            )
            .await
            .unwrap();

        assert_eq!(action.phase, Phase::Manifestation);
        assert!(action.can_manifest());
    }

    #[tokio::test]
    async fn test_self_cancellation() {
        let mut engine = GovernanceEngine::new();
        let hash = [3u8; 32];

        let result = engine
            .process_event(
                hash,
                ActionType::Liquidation,
                100.0, // Low resonance - will self-cancel
                "Test".to_string(),
                [0.1; 9],
            )
            .await;

        assert!(result.is_err());
        assert!(engine.get_action(&hash).is_none());
    }

    #[tokio::test]
    async fn test_get_by_phase() {
        let mut engine = GovernanceEngine::new();
        
        for i in 0..5 {
            let hash = [i; 32];
            engine
                .submit_action(hash, ActionType::Liquidation, 432.0, "Test".to_string())
                .unwrap();
        }

        let silence_actions = engine.get_actions_by_phase(Phase::Silence);
        assert_eq!(silence_actions.len(), 5);
    }
}
