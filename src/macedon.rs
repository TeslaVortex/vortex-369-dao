//! Macedon API Client
//!
//! Communicates with the Python Macedon Governance Engine

use crate::types::*;
use reqwest::Client;
use serde_json::json;

pub struct MacedonClient {
    client: Client,
    base_url: String,
}

impl MacedonClient {
    pub fn new(base_url: &str) -> Result<Self, Box<dyn std::error::Error>> {
        let client = Client::builder()
            .timeout(std::time::Duration::from_secs(30))
            .build()?;
        
        Ok(Self {
            client,
            base_url: base_url.trim_end_matches('/').to_string(),
        })
    }
    
    /// Health check the Macedon engine
    pub async fn health_check(&self) -> Result<HealthResponse, String> {
        let url = format!("{}/health", self.base_url);
        
        let response = self.client
            .get(&url)
            .send()
            .await
            .map_err(|e| format!("Health check failed: {}", e))?;
        
        if !response.status().is_success() {
            return Err(format!("Health check returned {}", response.status()));
        }
        
        response.json::<HealthResponse>()
            .await
            .map_err(|e| format!("Failed to parse health response: {}", e))
    }
    
    /// Get pending events from Macedon
    pub async fn get_pending_events(&self) -> Result<Vec<SyntheticEvent>, String> {
        let url = format!("{}/proposals?state=PENDING", self.base_url);
        
        let response = self.client
            .get(&url)
            .send()
            .await
            .map_err(|e| format!("Failed to get events: {}", e))?;
        
        if !response.status().is_success() {
            return Err(format!("Get events returned {}", response.status()));
        }
        
        #[derive(serde::Deserialize)]
        struct ProposalsResponse {
            proposals: Vec<MacedonProposal>,
            count: usize,
        }
        
        #[derive(serde::Deserialize)]
        struct MacedonProposal {
            id: String,
            content: serde_json::Value,
            origin: Option<String>,
            frequency: f64,
            phase: u8,
            state: String,
            witness_record: Option<String>,
            created_at: f64,
        }
        
        let proposals = response.json::<ProposalsResponse>()
            .await
            .map_err(|e| format!("Failed to parse proposals: {}", e))?;
        
        // Convert to SyntheticEvents
        let events: Vec<SyntheticEvent> = proposals.proposals
            .into_iter()
            .map(|p| {
                let action_type = if let Some(action) = p.content.get("action") {
                    match action.as_str() {
                        Some("liquidation") => ActionType::Liquidation,
                        Some("harvest") => ActionType::YieldHarvest,
                        Some("rebalance") => ActionType::Rebalance,
                        Some("compound") => ActionType::Compound,
                        _ => ActionType::BurnToNull,
                    }
                } else {
                    ActionType::BurnToNull
                };
                
                let value = p.content.get("value")
                    .and_then(|v| v.as_u64())
                    .unwrap_or(0) as u128;
                
                let target = p.content.get("target")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();
                
                SyntheticEvent {
                    event_hash: p.id,
                    event_type: action_type,
                    target,
                    value,
                    payload: serde_json::to_vec(&p.content).unwrap_or_default(),
                    base9_witness: p.witness_record.unwrap_or_default(),
                    timestamp: p.created_at as u64,
                    phase: p.phase,
                }
            })
            .collect();
        
        Ok(events)
    }
    
    /// Submit a new proposal to Macedon
    pub async fn submit_proposal(
        &self,
        action_type: ActionType,
        target: &str,
        value: u128,
        data: serde_json::Value,
    ) -> Result<String, String> {
        let url = format!("{}/proposals", self.base_url);
        
        let action_str = match action_type {
            ActionType::Liquidation => "liquidation",
            ActionType::YieldHarvest => "harvest",
            ActionType::Rebalance => "rebalance",
            ActionType::Compound => "compound",
            ActionType::BurnToNull => "burn",
        };
        
        let body = json!({
            "content": {
                "action": action_str,
                "target": target,
                "value": value,
                "data": data
            },
            "origin": "vortex-rust-core"
        });
        
        let response = self.client
            .post(&url)
            .json(&body)
            .send()
            .await
            .map_err(|e| format!("Failed to submit proposal: {}", e))?;
        
        if !response.status().is_success() {
            let text = response.text().await.unwrap_or_default();
            return Err(format!("Submit proposal failed: {}", text));
        }
        
        #[derive(serde::Deserialize)]
        struct SubmitResponse {
            id: String,
        }
        
        let result = response.json::<SubmitResponse>()
            .await
            .map_err(|e| format!("Failed to parse submit response: {}", e))?;
        
        Ok(result.id)
    }
    
    /// Process pending proposals
    pub async fn process_proposals(&self) -> Result<Vec<ProcessingResult>, String> {
        let url = format!("{}/proposals/process", self.base_url);
        
        let response = self.client
            .post(&url)
            .send()
            .await
            .map_err(|e| format!("Failed to process proposals: {}", e))?;
        
        if !response.status().is_success() {
            return Err(format!("Process proposals returned {}", response.status()));
        }
        
        #[derive(serde::Deserialize)]
        struct ProcessResponse {
            processed: usize,
            results: Vec<MacedonResult>,
        }
        
        #[derive(serde::Deserialize)]
        struct MacedonResult {
            proposal_id: String,
            state: String,
            witness_record: Option<String>,
            processing_time: f64,
        }
        
        let process_response = response.json::<ProcessResponse>()
            .await
            .map_err(|e| format!("Failed to parse process response: {}", e))?;
        
        let results: Vec<ProcessingResult> = process_response.results
            .into_iter()
            .map(|r| ProcessingResult {
                event_hash: r.proposal_id,
                manifested: r.state == "MANIFESTED",
                cancel_phase: if r.state == "CANCELLED" { 6 } else { 0 },
                witness_record: r.witness_record.unwrap_or_default(),
                final_phase: if r.state == "MANIFESTED" { 
                    Phase::Manifestation 
                } else { 
                    Phase::Silence 
                },
                processing_time_ms: (r.processing_time * 1000.0) as u64,
            })
            .collect();
        
        Ok(results)
    }
    
    /// Submit a human petition (3, 6, or 9 words)
    pub async fn submit_petition(
        &self,
        petitioner_id: &str,
        words: Vec<&str>,
    ) -> Result<String, String> {
        // Validate word count
        let count = words.len();
        if count != 3 && count != 6 && count != 9 {
            return Err(format!("Word count must be 3, 6, or 9 (got {})", count));
        }
        
        let url = format!("{}/petitions", self.base_url);
        
        let body = json!({
            "petitioner_id": petitioner_id,
            "words": words
        });
        
        let response = self.client
            .post(&url)
            .json(&body)
            .send()
            .await
            .map_err(|e| format!("Failed to submit petition: {}", e))?;
        
        if !response.status().is_success() {
            let text = response.text().await.unwrap_or_default();
            return Err(format!("Submit petition failed: {}", text));
        }
        
        #[derive(serde::Deserialize)]
        struct PetitionResponse {
            status: String,
            message: String,
            proposal_id: Option<String>,
        }
        
        let result = response.json::<PetitionResponse>()
            .await
            .map_err(|e| format!("Failed to parse petition response: {}", e))?;
        
        if result.status == "ACCEPTED" {
            Ok(result.proposal_id.unwrap_or(result.message))
        } else {
            Err(format!("{}: {}", result.status, result.message))
        }
    }
    
    /// Get engine status
    pub async fn get_status(&self) -> Result<serde_json::Value, String> {
        let url = format!("{}/status", self.base_url);
        
        let response = self.client
            .get(&url)
            .send()
            .await
            .map_err(|e| format!("Failed to get status: {}", e))?;
        
        response.json()
            .await
            .map_err(|e| format!("Failed to parse status: {}", e))
    }
}
