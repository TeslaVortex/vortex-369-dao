use actix_web::{post, web, HttpResponse, Responder};
use serde::{Deserialize, Serialize};
use regex::Regex;

#[derive(Deserialize)]
struct ScoreRequest {
    text: String,
}

#[derive(Serialize)]
struct ScoreResponse {
    score: f64,
    explanation: String,
}

#[post("/score")]
pub async fn score_proposal(req: web::Json<ScoreRequest>) -> impl Responder {
    let text = &req.text;
    let mut score = 0.0;
    let mut explanation = Vec::new();

    // Simple scoring logic
    let length = text.len() as f64;
    if length > 100.0 {
        score += 10.0;
        explanation.push("Long proposal".to_string());
    } else if length > 50.0 {
        score += 5.0;
        explanation.push("Medium length proposal".to_string());
    }

    // Check for keywords
    let keywords = ["dao", "vortex", "proposal", "community", "governance"];
    for keyword in keywords {
        if text.to_lowercase().contains(keyword) {
            score += 2.0;
            explanation.push(format!("Contains keyword: {}", keyword));
        }
    }

    // Check for numbers (resonance-like)
    let re = Regex::new(r"\d+").unwrap();
    let number_count = re.find_iter(text).count() as f64;
    score += number_count * 0.5;
    if number_count > 0.0 {
        explanation.push(format!("Contains {} numbers", number_count));
    }

    // Ensure score is between 0 and 100
    score = score.min(100.0).max(0.0);

    HttpResponse::Ok().json(ScoreResponse {
        score,
        explanation: explanation.join("; "),
    })
}
