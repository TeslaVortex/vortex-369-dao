use reqwest::Client;
use serde_json::Value;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new();
    let response = client.get("https://api.metals.live/v1/spot").send().await?;
    let data: Value = response.json().await?;
    if let Some(gold) = data.as_array().and_then(|arr| arr.iter().find(|item| item["metal"] == "gold")) {
        if let Some(price) = gold["price"].as_f64() {
            println!("Current Gold Price: ${}", price);
        }
    } else {
        println!("Gold price not found");
    }
    Ok(())
}
