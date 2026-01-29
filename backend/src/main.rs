mod api;
mod services;
mod models;
mod utils;

use actix_web::{App, HttpServer};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init();

    println!("🌀 Vortex-369 DAO Backend starting...");

    HttpServer::new(|| {
        App::new()
            .service(api::health::health_check)
            // Add more routes here
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
