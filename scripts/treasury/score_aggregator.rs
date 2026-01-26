use reqwest::Client;
use serde_json::Value;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new();
    let url = "https://hub.snapshot.org/graphql";
    let query = r#"
    {
      proposals(where: { space: "vortex369dao" }) {
        id
        title
        votes {
          voter
          choice
        }
      }
    }
    "#;
    let response = client.post(url)
        .json(&serde_json::json!({"query": query}))
        .send()
        .await?;
    let data: Value = response.json().await?;
    println!("Snapshot Proposals and Votes: {:?}", data);
    // Aggregate scores: for simplicity, sum the choice values
    if let Some(proposals) = data["data"]["proposals"].as_array() {
        for proposal in proposals {
            let mut total_score = 0;
            if let Some(votes) = proposal["votes"].as_array() {
                for vote in votes {
                    if let Some(choice) = vote["choice"].as_i64() {
                        total_score += choice;
                    }
                }
            }
            println!("Proposal {}: Total Score {}", proposal["id"], total_score);
        }
    }
    Ok(())
}
