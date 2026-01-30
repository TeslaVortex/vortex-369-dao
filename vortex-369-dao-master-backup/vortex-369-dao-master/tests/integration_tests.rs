//! Integration tests for Vortex-369 DAO
//! 
//! Tests the full system working together:
//! Synthetic → Embedding → Governance → (Chain)

use anyhow::Result;
use vortex_369_core::{
    SyntheticGenerator,
    ResonanceValidator,
    GovernanceEngine,
    synthetic::EventType,
    governance::{ActionType, Phase},
    embedding::{VectorEmbedder, SemanticAnalyzer},
    bridge::VortexBridge,
};

#[tokio::test]
async fn test_full_governance_cycle() {
    let seed = [0u8; 32];
    let mut generator = SyntheticGenerator::new(seed, 432.0);
    let embedder = VectorEmbedder::default();
    let mut governance = GovernanceEngine::new();

    // Generate event
    let event = generator.generate_event();
    assert!(event.resonance > 0.0);

    // Embed
    let vector = embedder.embed(&event.description).unwrap();
    assert_eq!(vector.len(), 9);

    // Process through governance
    let action_hash = calculate_hash(&event.description);
    let action_type = ActionType::Liquidation;

    let result = governance.process_event(
        action_hash,
        action_type,
        event.resonance,
        event.description,
        vector,
    ).await;

    // Should either manifest or self-cancel
    match result {
        Ok(action) => {
            assert_eq!(action.phase, Phase::Manifestation);
            assert!(action.can_manifest());
        }
        Err(_) => {
            // Self-cancelled at Phase 6 (low resonance)
            assert!(event.resonance < 432.0 * 0.369);
        }
    }
}

#[tokio::test]
async fn test_high_resonance_manifests() {
    let mut governance = GovernanceEngine::new();
    let embedder = VectorEmbedder::default();

    let action_hash = [1u8; 32];
    let high_resonance = 432.0; // High resonance
    let description = "High resonance action".to_string();
    let vector = embedder.embed(&description).unwrap();

    let result = governance.process_event(
        action_hash,
        ActionType::Liquidation,
        high_resonance,
        description,
        vector,
    ).await;

    assert!(result.is_ok());
    let action = result.unwrap();
    assert_eq!(action.phase, Phase::Manifestation);
    assert!(action.can_manifest());
}

#[tokio::test]
async fn test_low_resonance_cancels() {
    let mut governance = GovernanceEngine::new();
    let embedder = VectorEmbedder::default();

    let action_hash = [2u8; 32];
    let low_resonance = 100.0; // Low resonance (< 432 * 0.369)
    let description = "Low resonance action".to_string();
    let vector = embedder.embed(&description).unwrap();

    let result = governance.process_event(
        action_hash,
        ActionType::Liquidation,
        low_resonance,
        description,
        vector,
    ).await;

    // Should fail at Phase 6 (Breath)
    assert!(result.is_err());
}

#[tokio::test]
async fn test_bridge_single_cycle() {
    let seed = [0u8; 32];
    let mut bridge = VortexBridge::new(seed).unwrap();

    let result = bridge.run_single_cycle().await;
    
    // Should complete without error (may self-cancel, that's ok)
    match result {
        Ok(_) => assert!(true),
        Err(e) => {
            // Self-cancellation is expected for some events
            let error_msg = e.to_string();
            assert!(
                error_msg.contains("self-cancel") || 
                error_msg.contains("manifestation")
            );
        }
    }
}

#[test]
fn test_deterministic_generation() {
    let seed = [0u8; 32];
    let mut gen1 = SyntheticGenerator::new(seed, 432.0);
    let mut gen2 = SyntheticGenerator::new(seed, 432.0);

    let event1 = gen1.generate_event();
    let event2 = gen2.generate_event();

    assert_eq!(event1.resonance, event2.resonance);
    assert_eq!(event1.event_type, event2.event_type);
    assert_eq!(event1.description, event2.description);
}

#[test]
fn test_embedding_deterministic() {
    let embedder = VectorEmbedder::default();
    let text = "Test proposal for liquidation";

    let emb1 = embedder.embed(text).unwrap();
    let emb2 = embedder.embed(text).unwrap();

    assert_eq!(emb1, emb2);
}

#[test]
fn test_369_pattern_validation() {
    let validator = ResonanceValidator::default();

    // Test 3·6·9 numbers
    assert!(validator.validate_369_pattern(3));
    assert!(validator.validate_369_pattern(6));
    assert!(validator.validate_369_pattern(9));
    assert!(validator.validate_369_pattern(18)); // 1+8=9
    assert!(validator.validate_369_pattern(27)); // 2+7=9
    assert!(validator.validate_369_pattern(369)); // 3+6+9=18→9

    // Test non-369 numbers
    assert!(!validator.validate_369_pattern(5));
    assert!(!validator.validate_369_pattern(7));
}

#[test]
fn test_vector_similarity() {
    let embedder = VectorEmbedder::default();
    let analyzer = SemanticAnalyzer::default();

    let text1 = "Liquidate position";
    let text2 = "Liquidate position"; // Same
    let text3 = "Harvest yield"; // Different

    let emb1 = embedder.embed(text1).unwrap();
    let emb2 = embedder.embed(text2).unwrap();
    let emb3 = embedder.embed(text3).unwrap();

    let sim_same = analyzer.cosine_similarity(&emb1, &emb2);
    let sim_diff = analyzer.cosine_similarity(&emb1, &emb3);

    assert_eq!(sim_same, 1.0); // Identical
    assert!(sim_diff < 1.0); // Different
}

#[tokio::test]
async fn test_batch_processing() {
    let seed = [0u8; 32];
    let mut generator = SyntheticGenerator::new(seed, 432.0);
    let embedder = VectorEmbedder::default();

    // Generate 9 events (one per phase)
    let events = generator.generate_batch(9);
    assert_eq!(events.len(), 9);

    // Embed all descriptions
    let descriptions: Vec<String> = events.iter()
        .map(|e| e.description.clone())
        .collect();
    
    let embeddings = embedder.embed_batch(&descriptions).unwrap();
    assert_eq!(embeddings.len(), 9);

    // All embeddings should be 9D
    for emb in embeddings {
        assert_eq!(emb.len(), 9);
    }
}

#[test]
fn test_resonance_scoring() {
    let validator = ResonanceValidator::default();
    let embedder = VectorEmbedder::default();

    let high_res_event = vortex_369_core::synthetic::SyntheticEvent::new(
        0,
        EventType::Liquidation,
        432.0,
        "High resonance".to_string(),
    );

    let low_res_event = vortex_369_core::synthetic::SyntheticEvent::new(
        0,
        EventType::Liquidation,
        100.0,
        "Low resonance".to_string(),
    );

    let high_score = validator.calculate_score(&high_res_event);
    let low_score = validator.calculate_score(&low_res_event);

    assert!(high_score > low_score);
    assert!(high_score > 0.8); // Should be high
    assert!(low_score < 0.5); // Should be low
}

// Helper function
fn calculate_hash(text: &str) -> [u8; 32] {
    use sha3::{Digest, Keccak256};
    let mut hasher = Keccak256::new();
    hasher.update(text.as_bytes());
    hasher.finalize().into()
}
