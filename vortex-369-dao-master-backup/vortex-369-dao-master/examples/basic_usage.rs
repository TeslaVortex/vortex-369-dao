//! Basic usage example for Vortex-369 DAO
//! 
//! This example shows how to:
//! 1. Generate synthetic events
//! 2. Embed them into vectors
//! 3. Process through governance
//! 4. Check for manifestation

use anyhow::Result;
use vortex_369_core::{
    SyntheticGenerator,
    ResonanceValidator,
    GovernanceEngine,
    synthetic::EventType,
    governance::ActionType,
    embedding::{VectorEmbedder, SemanticAnalyzer},
};

#[tokio::main]
async fn main() -> Result<()> {
    println!("🌀 Vortex-369 DAO - Basic Usage Example");
    println!("========================================\n");

    // Step 1: Create synthetic generator
    println!("1️⃣ Creating synthetic generator...");
    let seed = [0u8; 32]; // Use block hash in production
    let mut generator = SyntheticGenerator::new(seed, 432.0);
    println!("   ✅ Generator created with 432 Hz frequency\n");

    // Step 2: Generate an event
    println!("2️⃣ Generating synthetic event...");
    let event = generator.generate_event();
    println!("   Event type: {:?}", event.event_type);
    println!("   Resonance: {} Hz", event.resonance);
    println!("   Description: {}", event.description);
    println!("   ✅ Event generated\n");

    // Step 3: Validate resonance
    println!("3️⃣ Validating resonance...");
    let validator = ResonanceValidator::default();
    let is_valid = validator.validate_frequency(&event);
    let score = validator.calculate_score(&event);
    println!("   Frequency valid: {}", is_valid);
    println!("   Resonance score: {:.2}", score);
    println!("   ✅ Resonance validated\n");

    // Step 4: Create vector embedding
    println!("4️⃣ Creating vector embedding...");
    let embedder = VectorEmbedder::default();
    let vector = embedder.embed(&event.description)?;
    println!("   Vector (9D): {:?}", vector);
    println!("   Magnitude: {:.4}", embedder.magnitude(&vector));
    println!("   ✅ Vector embedded\n");

    // Step 5: Analyze semantics
    println!("5️⃣ Analyzing semantics...");
    let analyzer = SemanticAnalyzer::default();
    let anti_vector = analyzer.generate_anti_proposal(&vector);
    let similarity = analyzer.cosine_similarity(&vector, &anti_vector);
    println!("   Anti-proposal similarity: {:.4}", similarity);
    println!("   ✅ Semantics analyzed\n");

    // Step 6: Submit to governance
    println!("6️⃣ Submitting to governance...");
    let mut governance = GovernanceEngine::new();
    
    let action_hash = calculate_hash(&event.description);
    let action_type = match event.event_type {
        EventType::Liquidation => ActionType::Liquidation,
        EventType::YieldHarvest => ActionType::YieldHarvest,
        EventType::Rebalance => ActionType::Rebalance,
        EventType::Custom => ActionType::Custom,
    };
    
    governance.submit_action(
        action_hash,
        action_type,
        event.resonance,
        event.description.clone(),
    )?;
    println!("   ✅ Action submitted\n");

    // Step 7: Process through 9 phases
    println!("7️⃣ Processing through 9 phases...");
    let result = governance.process_event(
        action_hash,
        action_type,
        event.resonance,
        event.description,
        vector,
    ).await;

    match result {
        Ok(action) => {
            println!("   ✅ Action manifested!");
            println!("   Final phase: {:?}", action.phase);
            println!("   Can manifest: {}", action.can_manifest());
            println!("   Score: {:.4}", action.calculate_score());
        }
        Err(e) => {
            println!("   ⚠️  Action cancelled: {}", e);
        }
    }

    println!("\n🎉 Example complete!");
    println!("\n3 · 6 · 9");
    println!("Zero marginal cost. Infinite scale.\n");

    Ok(())
}

fn calculate_hash(text: &str) -> [u8; 32] {
    use sha3::{Digest, Keccak256};
    let mut hasher = Keccak256::new();
    hasher.update(text.as_bytes());
    hasher.finalize().into()
}
