mod api;
mod services;
mod models;
mod utils;

use actix_web::{App, HttpServer};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init();

    let port = std::env::var("PORT").unwrap_or("8080".to_string());
    let port: u16 = port.parse().unwrap();

    println!("🌀 Vortex-369 DAO Backend starting on port {}...", port);

    HttpServer::new(|| {
        App::new()
            .service(api::health::health_check)
            .service(api::score::score_proposal)
            // Add more routes here
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}
