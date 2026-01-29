use actix_web::{web, App, HttpResponse, HttpServer, Result};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Deserialize)]
struct ScoreRequest {
    text: String,
}

#[derive(Serialize)]
struct ScoreResponse {
    score: u8,
    explanation: String,
}

#[derive(Serialize)]
struct HealthResponse {
    status: String,
    version: String,
}

/// Calculate resonance score based on 369/432 Hz keywords and patterns
fn calculate_resonance_score(text: &str) -> (u8, String) {
    let mut score: u8 = 50; // Base score
    let mut explanations = Vec::new();

    // Convert to lowercase for case-insensitive matching
    let lower_text = text.to_lowercase();

    // High-value keywords (+20 points each)
    let high_keywords = vec![
        "vortex", "harmony", "arcturian", "abundance", "369"
    ];

    // Medium-value keywords (+15 points each)
    let medium_keywords = vec![
        "resonance", "432", "manifest", "light", "healing"
    ];

    // Low-value keywords (+10 points each)
    let low_keywords = vec![
        "frequency", "energy", "consciousness", "unity", "love"
    ];

    // Count high-value keywords
    for keyword in &high_keywords {
        if lower_text.contains(keyword) {
            score += 20u8;
            explanations.push(format!("+20 for '{}'", keyword));
        }
    }

    // Count medium-value keywords
    for keyword in &medium_keywords {
        if lower_text.contains(keyword) {
            score += 15u8;
            explanations.push(format!("+15 for '{}'", keyword));
        }
    }

    // Count low-value keywords
    for keyword in &low_keywords {
        if lower_text.contains(keyword) {
            score += 10u8;
            explanations.push(format!("+10 for '{}'", keyword));
        }
    }

    // Bonus for multiple keywords
    let total_keywords = explanations.len();
    if total_keywords > 3 {
        score += 10u8;
        explanations.push("+10 for multiple resonance keywords".to_string());
    }

    // Bonus for length (encourages detailed proposals)
    let word_count = text.split_whitespace().count();
    if word_count > 20 {
        score += 5u8;
        explanations.push("+5 for detailed proposal".to_string());
    }

    // Penalty for too short
    if word_count < 5 {
        score = score.saturating_sub(20u8);
        explanations.push("-20 for too brief".to_string());
    }

    // Cap at 100
    if score > 100u8 {
        score = 100u8;
    }

    // Special bonuses
    if lower_text.contains("432 hz") {
        score += 5u8;
        explanations.push("+5 for 432 Hz reference".to_string());
    }

    if lower_text.contains("369 code") {
        score += 5u8;
        explanations.push("+5 for 369 code reference".to_string());
    }

    let explanation = if explanations.is_empty() {
        "Base resonance score".to_string()
    } else {
        explanations.join("; ")
    };

    (score, explanation)
}

async fn score_proposal(req: web::Json<ScoreRequest>) -> Result<HttpResponse> {
    let (score, explanation) = calculate_resonance_score(&req.text);

    let response = ScoreResponse { score, explanation };

    Ok(HttpResponse::Ok().json(response))
}

async fn health_check() -> Result<HttpResponse> {
    let response = HealthResponse {
        status: "healthy".to_string(),
        version: env!("CARGO_PKG_VERSION").to_string(),
    };

    Ok(HttpResponse::Ok().json(response))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init();

    log::info!("Starting Vortex-369 DAO Backend on port 8080");

    HttpServer::new(|| {
        App::new()
            .route("/health", web::get().to(health_check))
            .route("/score", web::post().to(score_proposal))
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_high_resonance_keywords() {
        let (score, explanation) = calculate_resonance_score("Create harmony through 369 resonance");
        assert!(score > 66u8, "Should score high with resonance keywords");
        assert!(explanation.contains("+20"));
    }

    #[test]
    fn test_medium_resonance() {
        let (score, _) = calculate_resonance_score("Moderate proposal with some keywords");
        assert!(score >= 33u8 && score <= 66u8, "Should score medium");
    }

    #[test]
    fn test_low_resonance() {
        let (score, _) = calculate_resonance_score("Buy a new car for the DAO");
        assert!(score < 33u8, "Should score low for irrelevant proposal");
    }

    #[test]
    fn test_empty_proposal() {
        let (score, _) = calculate_resonance_score("");
        assert_eq!(score, 0u8, "Empty proposal should score 0");
    }

    #[test]
    fn test_432_hz_bonus() {
        let (score1, _) = calculate_resonance_score("Proposal with 432 hz");
        let (score2, _) = calculate_resonance_score("Proposal without");
        assert!(score1 > score2, "432 Hz should give bonus");
    }

    #[test]
    fn test_detailed_proposal_bonus() {
        let (score1, _) = calculate_resonance_score("Short proposal");
        let (score2, _) = calculate_resonance_score("This is a very detailed proposal with many words explaining the harmony and resonance through 369 codes and 432 hz frequencies");
        assert!(score2 > score1, "Detailed proposal should score higher");
    }
}
