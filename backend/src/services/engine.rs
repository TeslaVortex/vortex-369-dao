//! Vortex-369 Engine
//!
//! Core processing engine that bridges Macedon to on-chain execution

use crate::config::VortexConfig;
use crate::constants::*;
use crate::services::macedon::MacedonClient;
use crate::relayer::ChainRelayer;
use crate::types::*;

use sha2::{Digest, Sha256};
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};
use tracing::{debug, info, warn};

pub struct VortexEngine {
    pub config: VortexConfig,
    pub office: u8,
    pub macedon: MacedonClient,
    pub relayer: ChainRelayer,
    pub stats: EngineStats,
    start_time: Instant,
}

impl VortexEngine {
    /// Create new engine instance
    pub async fn new(
        config: VortexConfig,
        office: u8,
    ) -> Result<Self, Box<dyn std::error::Error>> {
        let macedon = MacedonClient::new(&config.macedon.api_url)?;
        let relayer = ChainRelayer::new(&config)?;

        Ok(Self {
            config,
            office,
            macedon,
            relayer,
            stats: EngineStats::default(),
            start_time: Instant::now(),
        })
    }

    /// Poll Macedon for new synthetic events
    pub async fn poll_macedon_events(&mut self) -> Result<Vec<SyntheticEvent>, String> {
        // Health check first
        let health = self.macedon.health_check().await?;

        if !health.coherent {
            warn!("⚠️ Macedon engine not coherent");
            return Ok(Vec::new());
        }

        // Get pending proposals from Macedon
        let events: Vec<SyntheticEvent> = self.macedon.get_pending_events().await?;

        debug!("Polled {} events from Macedon", events.len());

        Ok(events)
    }

    /// Process event through the 9-phase cycle
    pub async fn process_event(
        &mut self,
        mut event: SyntheticEvent,
    ) -> Result<ProcessingResult, String> {
        let start = Instant::now();
        self.stats.events_processed += 1;

        let mut result = ProcessingResult {
            event_hash: event.event_hash.clone(),
            manifested: false,
            cancel_phase: 0,
            witness_record: String::new(),
            final_phase: Phase::Silence,
            processing_time_ms: 0,
        };

        // Process through each phase
        for phase_num in 1..=TOTAL_PHASES {
            let phase = Phase::from(phase_num);
            debug!("Processing phase {}: {}", phase_num, phase);

            event.phase = phase_num;

            match phase {
                Phase::Proposal => {
                    // Validate event structure
                    if !self.validate_event(&event) {
                        result.cancel_phase = 1;
                        return Ok(result);
                    }
                }

                Phase::Mirror => {
                    // Create inversion (anti-proposal)
                    // The system fights itself
                    let inversion = self.create_inversion(&event);
                    debug!("Created inversion: {}", inversion.event_hash);
                }

                Phase::Vortex => {
                    // Spin dynamics - separate truth from lies
                    let spin_result = self.calculate_spin(&event);
                    if spin_result < 0.5 {
                        debug!("Spin failed: {}", spin_result);
                    }
                }

                Phase::Resolution => {
                    // Original vs inverse battle
                    let survives = self.resolve_conflict(&event);
                    if !survives {
                        result.cancel_phase = 4;
                        self.stats.events_cancelled += 1;
                        return Ok(result);
                    }
                }

                Phase::Fractal => {
                    // Replicate across scales (3, 9, 27, 81...)
                    let scales_valid = self.validate_fractal_scales(&event);
                    if !scales_valid {
                        result.cancel_phase = 5;
                        self.stats.events_cancelled += 1;
                        return Ok(result);
                    }
                }

                Phase::Breath => {
                    // Phase 6: Self-cancel checkpoint
                    // Events must either cancel here or amplify by phase 9
                    let should_cancel = self.check_self_cancel(&event);
                    if should_cancel {
                        result.cancel_phase = CANCEL_PHASE;
                        self.stats.events_cancelled += 1;
                        return Ok(result);
                    }
                }

                Phase::Witness => {
                    // Record in base-9 notation
                    result.witness_record = self.generate_witness_record(&event);
                    event.base9_witness = result.witness_record.clone();
                }

                Phase::Return => {
                    // Ensure loop closure
                    if !self.verify_loop_closure(&event) {
                        result.cancel_phase = 8;
                        self.stats.events_cancelled += 1;
                        return Ok(result);
                    }
                }

                Phase::Manifestation => {
                    // Phase 9: Reality integration
                    result.manifested = true;
                    result.final_phase = Phase::Manifestation;
                    self.stats.events_manifested += 1;
                    info!("✨ Event manifested: {}", event.event_hash);
                }

                _ => {}
            }
        }

        result.processing_time_ms = start.elapsed().as_millis() as u64;

        Ok(result)
    }

    /// Push manifested event to chain
    pub async fn push_to_chain(
        &mut self,
        result: &ProcessingResult,
    ) -> Result<String, String> {
        if !result.manifested {
            return Err("Event not manifested".to_string());
        }

        // Build transaction
        let tx_hash = self.relayer.submit_action(result).await?;

        info!("📤 Pushed to chain: {}", tx_hash);

        Ok(tx_hash)
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PHASE IMPLEMENTATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    fn validate_event(&self, event: &SyntheticEvent) -> bool {
        // Check hash is valid
        if event.event_hash.is_empty() {
            return false;
        }

        // Check timestamp is reasonable
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_secs();

        if event.timestamp > now + 300 || event.timestamp < now - 3600 {
            return false;
        }

        true
    }

    fn create_inversion(&self, event: &SyntheticEvent) -> SyntheticEvent {
        let mut inverted = event.clone();

        // Invert the hash
        let mut hasher = Sha256::new();
        hasher.update(format!("INVERT:{}", event.event_hash));
        let hash_bytes = hasher.finalize();
        inverted.event_hash = hex::encode(&hash_bytes[..18]);

        // Invert the value (anti-proposal)
        inverted.value = u128::MAX - event.value;

        inverted
    }

    fn calculate_spin(&self, event: &SyntheticEvent) -> f64 {
        // Calculate alignment with 432 Hz
        let value_root = digital_root(event.value as u64);

        // Higher spin for 3-6-9 aligned values
        if value_root == 9 {
            0.9
        } else if value_root == 6 {
            0.8
        } else if value_root == 3 {
            0.7
        } else {
            0.4
        }
    }

    fn resolve_conflict(&self, event: &SyntheticEvent) -> bool {
        // Original survives if:
        // 1. Value is 369-aligned
        // 2. Timestamp is valid
        // 3. Target is not zero address

        let value_aligned = is_369_aligned(event.value as u64);
        let target_valid = !event.target.is_empty() &&
                          event.target != "0x0000000000000000000000000000000000000000";

        value_aligned || target_valid
    }

    fn validate_fractal_scales(&self, event: &SyntheticEvent) -> bool {
        // Check if event can replicate at scales 3, 9, 27, 81...
        let scales = [3u64, 9, 27, 81, 243, 729];

        let mut valid_scales = 0;
        for scale in scales.iter() {
            // Event is valid at scale if value * scale doesn't overflow
            // and result is still 369-aligned
            if let Some(scaled) = (event.value as u64).checked_mul(*scale) {
                if is_369_aligned(scaled) {
                    valid_scales += 1;
                }
            }
        }

        // Need at least 3 valid scales
        valid_scales >= 3
    }

    fn check_self_cancel(&self, event: &SyntheticEvent) -> bool {
        // Events should self-cancel at phase 6 if:
        // 1. Conditions have changed (we'd need to re-check on-chain state)
        // 2. Value is too small to be profitable
        // 3. Gas price is too high

        // For now, simple check: don't cancel if value > minimum
        let min_value = 1_000_000_000_000_000u128; // 0.001 ETH in wei

        event.value < min_value
    }

    fn generate_witness_record(&self, event: &SyntheticEvent) -> String {
        // Generate base-9 witness record
        let mut hasher = Sha256::new();
        hasher.update(&event.event_hash);
        hasher.update(event.value.to_le_bytes());
        hasher.update(event.phase.to_le_bytes());

        let hash_bytes = hasher.finalize();
        let hash_int = u64::from_le_bytes(hash_bytes[..8].try_into().unwrap());

        to_base9(hash_int, 9)
    }

    fn verify_loop_closure(&self, event: &SyntheticEvent) -> bool {
        // Verify the witness record reduces to 9
        if event.base9_witness.is_empty() {
            return false;
        }

        // Sum all digits
        let sum: u64 = event.base9_witness
            .chars()
            .filter_map(|c: char| c.to_digit(10))
            .map(|d| d as u64)
            .sum();

        // Digital root should be 9 for closure
        digital_root(sum) == 9
    }
}
