mod api;
mod services;
mod models;
mod utils;
mod config;
mod constants;
mod types;
mod relayer;

use actix_web::{App, HttpServer};
use actix_web::web;
use config::VortexConfig;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init();

    // Load configuration
    let chain = std::env::var("CHAIN").unwrap_or("base".to_string());
    let macedon_api = std::env::var("MACEDON_API").unwrap_or("http://localhost:3001".to_string());
    let config_path = std::env::var("CONFIG_PATH").unwrap_or("config.toml".to_string());
    let config = VortexConfig::load(&config_path, &chain, &macedon_api)
        .expect("Failed to load configuration");

    let port = std::env::var("PORT").unwrap_or("8080".to_string());
    let port: u16 = port.parse().unwrap();

    println!("🌀 Vortex-369 DAO Backend starting on port {}...", port);
    println!("Chain: {}, Oracle enabled: {}", config.chain.name, config.oracle.enabled);

    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(config.clone()))
            .wrap(actix_cors::Cors::default().allow_any_origin().allow_any_method().allow_any_header())
            .service(api::health::health_check)
            .service(api::score::score_proposal)
            // Add more routes here
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}
