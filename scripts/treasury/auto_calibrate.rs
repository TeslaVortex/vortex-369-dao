use reqwest::Client;
use serde_json::Value;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let bearer_token = "YOUR_BEARER_TOKEN"; // Placeholder for Twitter API v2 Bearer Token
    let client = Client::new();
    let url = "https://api.twitter.com/2/users/by/username/Vortex369X";
    let response = client.get(url).bearer_auth(bearer_token).send().await?;
    let user: Value = response.json().await?;
    let user_id = user["data"]["id"].as_str().unwrap();
    let tweets_url = format!("https://api.twitter.com/2/users/{}/tweets?max_results=10", user_id);
    let tweets_response = client.get(&tweets_url).bearer_auth(bearer_token).send().await?;
    let tweets: Value = tweets_response.json().await?;
    println!("Recent posts from @Vortex369X for real-time truth calibration: {:?}", tweets);
    Ok(())
}
