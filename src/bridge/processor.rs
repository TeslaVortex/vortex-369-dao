use crate::synthetic::SyntheticGenerator;
use crate::embedding::VectorEmbedder;
use crate::governance::{GovernanceEngine, ActionType};
use anyhow::Result;
use tokio::time::{interval, Duration};

/// Main bridge connecting all components
pub struct VortexBridge {
    generator: SyntheticGenerator,
    embedder: VectorEmbedder,
    governance: GovernanceEngine,
}

impl VortexBridge {
    pub fn new(seed: [u8; 32]) -> Result<Self> {
        Ok(Self {
            generator: SyntheticGenerator::new(seed, 432.0),
            embedder: VectorEmbedder::new(None)?,
            governance: GovernanceEngine::new(),
        })
    }

    /// Start the governance bridge
    pub async fn start(&mut self) -> Result<()> {
        let mut ticker = interval(Duration::from_secs(9));

        loop {
            ticker.tick().await;

            // Generate synthetic event
            let event = self.generator.generate_event();
            
            // Embed description
            let vector = self.embedder.embed(&event.description)?;
            
            // Calculate hash
            let hash = self.calculate_hash(&event.description);
            
            // Convert event type
            let action_type = match event.event_type {
                crate::synthetic::EventType::Liquidation => ActionType::Liquidation,
                crate::synthetic::EventType::YieldHarvest => ActionType::YieldHarvest,
                crate::synthetic::EventType::Rebalance => ActionType::Rebalance,
                crate::synthetic::EventType::Custom => ActionType::Custom,
            };

            // Process through governance
            match self.governance.process_event(
                hash,
                action_type,
                event.resonance,
                event.description.clone(),
                vector,
            ).await {
                Ok(action) => {
                    tracing::info!(
                        "Action manifested: {} (resonance: {})",
                        event.description,
                        action.resonance
                    );
                    // TODO: Submit to chain
                }
                Err(e) => {
                    tracing::warn!("Action failed: {}", e);
                }
            }
        }
    }

    /// Calculate hash for event
    fn calculate_hash(&self, description: &str) -> [u8; 32] {
        use sha3::{Digest, Keccak256};
        let mut hasher = Keccak256::new();
        hasher.update(description.as_bytes());
        hasher.finalize().into()
    }

    /// Run a single cycle (for testing)
    pub async fn run_single_cycle(&mut self) -> Result<()> {
        let event = self.generator.generate_event();
        let vector = self.embedder.embed(&event.description)?;
        let hash = self.calculate_hash(&event.description);
        
        let action_type = match event.event_type {
            crate::synthetic::EventType::Liquidation => ActionType::Liquidation,
            crate::synthetic::EventType::YieldHarvest => ActionType::YieldHarvest,
            crate::synthetic::EventType::Rebalance => ActionType::Rebalance,
            crate::synthetic::EventType::Custom => ActionType::Custom,
        };

        self.governance.process_event(
            hash,
            action_type,
            event.resonance,
            event.description,
            vector,
        ).await?;

        Ok(())
    }
}
