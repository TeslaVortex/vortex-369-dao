use serde::{Deserialize, Serialize};

/// Types of synthetic events that can be generated
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum EventType {
    Liquidation,
    YieldHarvest,
    Rebalance,
    Custom,
}

/// A synthetic governance event
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SyntheticEvent {
    pub timestamp: u64,
    pub event_type: EventType,
    pub resonance: f64,
    pub description: String,
    pub target_address: [u8; 20],
    pub value: u128,
    pub phase: u8,
}

impl SyntheticEvent {
    pub fn new(
        timestamp: u64,
        event_type: EventType,
        resonance: f64,
        description: String,
    ) -> Self {
        Self {
            timestamp,
            event_type,
            resonance,
            description,
            target_address: [0u8; 20],
            value: 0,
            phase: 0,
        }
    }
}
