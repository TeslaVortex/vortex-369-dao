use actix_web::{post, web, HttpResponse, Responder};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Deserialize)]
struct ScoreRequest {
    text: String,
}

#[derive(Serialize)]
struct ScoreResponse {
    score: f64,
    explanation: String,
}

fn char_to_value(c: char) -> u32 {
    match c.to_ascii_uppercase() {
        'A'..='Z' => (c.to_ascii_uppercase() as u32 - 'A' as u32) + 1,
        _ => 0,
    }
}

fn digital_root(mut num: u32) -> u32 {
    while num >= 10 {
        let mut sum = 0;
        while num > 0 {
            sum += num % 10;
            num /= 10;
        }
        num = sum;
    }
    num
}

fn get_keywords() -> HashMap<&'static str, f64> {
    let mut keywords = HashMap::new();
    keywords.insert("ananda", 99.0);
    keywords.insert("sovereign", 50.0);
    keywords.insert("love", 50.0);
    keywords.insert("joy", 50.0);
    keywords.insert("369", 50.0);
    keywords.insert("abundance", 40.0);
    keywords.insert("merkaba", 35.0);
    keywords.insert("vortex", 30.0);
    keywords.insert("crystalline", 30.0);
    keywords.insert("arcturian", 25.0);
    keywords.insert("infinity", 25.0);
    keywords.insert("harmony", 20.0);
    keywords.insert("coherence", 20.0);
    keywords.insert("awakening", 20.0);
    keywords.insert("migration", 15.0);
    keywords.insert("eternal", 15.0);
    keywords.insert("xrp", 10.0);
    keywords
}

#[post("/score")]
pub async fn score_proposal(req: web::Json<ScoreRequest>) -> impl Responder {
    let text = &req.text;
    let mut score = 0.0;
    let mut explanation = Vec::new();

    // Text to numeric value
    let mut total: u32 = 0;
    for c in text.chars() {
        total += char_to_value(c);
    }
    let vortex_value = if total == 0 { 1 } else { total % 9 };
    let digital_root_val = digital_root(vortex_value);
    let base_score = digital_root_val as f64 * 10.0;
    score += base_score;
    explanation.push(format!("Base score: {} (Digital Root {})", base_score, digital_root_val));

    // Sacred Number Bonuses
    match digital_root_val {
        3 => {
            score += 30.0;
            explanation.push("Sacred Trinity Creation +30".to_string());
        }
        6 => {
            score += 60.0;
            explanation.push("Sacred Harmony Flow +60".to_string());
        }
        9 => {
            score += 90.0;
            explanation.push("Sacred Unity Completion +90".to_string());
        }
        _ => {}
    }

    // Pattern Detection
    let has_pattern = text.contains("369") || text.contains("963") || text.contains("693") ||
                      text.contains("333") || text.contains("666") || text.contains("999") ||
                      text.ends_with('3') || text.ends_with('6') || text.ends_with('9');
    if has_pattern {
        score += 33.0;
        explanation.push("Sacred pattern detected +33".to_string());
    }

    // Keyword Bonuses
    let keywords = get_keywords();
    let mut keyword_scores: Vec<f64> = Vec::new();
    for (word, points) in &keywords {
        if text.to_lowercase().contains(word) {
            keyword_scores.push(*points);
        }
    }
    keyword_scores.sort_by(|a, b| b.partial_cmp(a).unwrap());
    let top_keywords = keyword_scores.iter().take(3).sum::<f64>();
    score += top_keywords;
    if top_keywords > 0.0 {
        explanation.push(format!("Keyword bonuses: {:.0}", top_keywords));
    }

    // Structural Bonuses
    let words: Vec<&str> = text.split_whitespace().collect();
    if words.len() == 3 {
        score += 33.0;
        explanation.push("Trinity structure +33".to_string());
    }
    if text.len() % 9 == 0 && text.len() > 0 {
        score += 27.0;
        explanation.push("Length divisible by 9 +27".to_string());
    }

    // Mantra Bonuses
    let love_words = ["love", "joy", "bliss", "gratitude", "peace", "harmony"];
    let rise_words = ["rise", "ascend", "awaken", "sovereign", "abundance"];
    let mut mantra_score = 0.0;
    let lower_text = text.to_lowercase();
    for word in love_words {
        if lower_text.contains(word) {
            mantra_score += 10.0;
        }
    }
    for word in rise_words {
        if lower_text.contains(word) {
            mantra_score += 5.0;
        }
    }
    mantra_score = mantra_score.min(30.0);
    score += mantra_score;
    if mantra_score > 0.0 {
        explanation.push(format!("Mantra bonuses: {:.0}", mantra_score));
    }

    // Cap at 369
    score = score.min(369.0);

    HttpResponse::Ok().json(ScoreResponse {
        score,
        explanation: explanation.join("; "),
    })
}
