//! Vortex-369 Types
//! 
//! Core data structures for resonance governance

use serde::{Deserialize, Serialize};
use std::fmt;

/// Action types for DAO execution
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[repr(u8)]
pub enum ActionType {
    Liquidation = 0,
    YieldHarvest = 1,
    Rebalance = 2,
    Compound = 3,
    BurnToNull = 4,
}

impl From<u8> for ActionType {
    fn from(v: u8) -> Self {
        match v {
            0 => ActionType::Liquidation,
            1 => ActionType::YieldHarvest,
            2 => ActionType::Rebalance,
            3 => ActionType::Compound,
            4 => ActionType::BurnToNull,
            _ => ActionType::BurnToNull,
        }
    }
}

/// Phase states in the 9-phase cycle
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[repr(u8)]
pub enum Phase {
    Silence = 0,
    Proposal = 1,
    Mirror = 2,
    Vortex = 3,
    Resolution = 4,
    Fractal = 5,
    Breath = 6,
    Witness = 7,
    Return = 8,
    Manifestation = 9,
}

impl From<u8> for Phase {
    fn from(v: u8) -> Self {
        match v {
            0 => Phase::Silence,
            1 => Phase::Proposal,
            2 => Phase::Mirror,
            3 => Phase::Vortex,
            4 => Phase::Resolution,
            5 => Phase::Fractal,
            6 => Phase::Breath,
            7 => Phase::Witness,
            8 => Phase::Return,
            9 => Phase::Manifestation,
            _ => Phase::Silence,
        }
    }
}

impl fmt::Display for Phase {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Phase::Silence => write!(f, "SILENCE"),
            Phase::Proposal => write!(f, "PROPOSAL"),
            Phase::Mirror => write!(f, "MIRROR"),
            Phase::Vortex => write!(f, "VORTEX"),
            Phase::Resolution => write!(f, "RESOLUTION"),
            Phase::Fractal => write!(f, "FRACTAL"),
            Phase::Breath => write!(f, "BREATH"),
            Phase::Witness => write!(f, "WITNESS"),
            Phase::Return => write!(f, "RETURN"),
            Phase::Manifestation => write!(f, "MANIFESTATION"),
        }
    }
}

/// Synthetic event from Macedon engine
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SyntheticEvent {
    pub event_hash: String,
    pub event_type: ActionType,
    pub target: String,
    pub value: u128,
    pub payload: Vec<u8>,
    pub base9_witness: String,
    pub timestamp: u64,
    pub phase: u8,
}

/// Processing result after 9-phase cycle
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProcessingResult {
    pub event_hash: String,
    pub manifested: bool,
    pub cancel_phase: u8,
    pub witness_record: String,
    pub final_phase: Phase,
    pub processing_time_ms: u64,
}

/// Liquidation parameters
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LiquidationParams {
    pub protocol: String,
    pub collateral_asset: String,
    pub debt_asset: String,
    pub borrower: String,
    pub debt_to_cover: u128,
}

/// Yield harvest parameters
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct YieldHarvestParams {
    pub protocol: String,
    pub asset: String,
    pub strategy: Option<String>,
}

/// Rebalance parameters
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RebalanceParams {
    pub from_protocol: String,
    pub to_protocol: String,
    pub asset: String,
    pub amount: u128,
}

/// Chain transaction
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChainTx {
    pub chain_id: u64,
    pub to: String,
    pub value: u128,
    pub data: Vec<u8>,
    pub gas_limit: u64,
    pub nonce: u64,
}

/// Engine statistics
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct EngineStats {
    pub events_processed: u64,
    pub events_manifested: u64,
    pub events_cancelled: u64,
    pub liquidations_executed: u64,
    pub yields_harvested: u64,
    pub total_burned_eth: f64,
    pub total_profit_eth: f64,
    pub uptime_seconds: u64,
}

/// Phase proof for on-chain verification
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhaseProof {
    pub event_hash: String,
    pub from_phase: u8,
    pub to_phase: u8,
    pub witness_record: String,
    pub signature: Vec<u8>,
}

/// Macedon API response
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MacedonResponse {
    pub status: String,
    pub events: Option<Vec<SyntheticEvent>>,
    pub error: Option<String>,
}

/// Health check response
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HealthResponse {
    pub status: String,
    pub version: String,
    pub frequency: f64,
    pub coherent: bool,
    pub database: String,
    pub timestamp: u64,
}

impl Default for SyntheticEvent {
    fn default() -> Self {
        Self {
            event_hash: String::new(),
            event_type: ActionType::BurnToNull,
            target: String::new(),
            value: 0,
            payload: Vec::new(),
            base9_witness: String::new(),
            timestamp: 0,
            phase: 0,
        }
    }
}

impl Default for ProcessingResult {
    fn default() -> Self {
        Self {
            event_hash: String::new(),
            manifested: false,
            cancel_phase: 0,
            witness_record: String::new(),
            final_phase: Phase::Silence,
            processing_time_ms: 0,
        }
    }
}
