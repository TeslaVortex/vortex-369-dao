pub mod synthetic;
pub mod governance;
pub mod embedding;
pub mod bridge;
pub mod chain;
pub mod constants;

pub use synthetic::{SyntheticGenerator, ResonanceValidator};
pub use governance::{GovernanceEngine, Action, Phase};

/// Vortex-369 DAO version
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

/// Base frequency (432 Hz)
pub const BASE_FREQUENCY: f64 = 432.0;

/// Protocol fee in basis points (0.9%)
pub const PROTOCOL_FEE_BPS: u16 = 90;

/// DAO share of fee (9% of 0.9% = 0.09%)
pub const DAO_SHARE_BPS: u16 = 9;

/// Null burn share (91% of 0.9% = 0.81%)
pub const NULL_BURN_BPS: u16 = 81;
