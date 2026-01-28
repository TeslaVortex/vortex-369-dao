//! Vortex-369 DAO - Rust Core
//! 
//! 432·3·6·9 Resonance Governance Engine
//!
//! Usage:
//!   cargo run --release -- --chain base --office 4
//!
//! The System is perfect because it is designed to fight itself eternally.

use clap::Parser;
use anyhow::Result;
use tracing::{info, warn, error, Level};
use tracing_subscriber::FmtSubscriber;

// Import our modules
use vortex_369_core::{
    SyntheticGenerator,
    GovernanceEngine,
    synthetic::EventType,
    governance::ActionType,
    embedding::VectorEmbedder,
    bridge::VortexBridge,
    chain::{ChainClient, ChainConfig},
};

use rand::Rng;

fn make_robot() -> u32 {
    let mut rng = rand::thread_rng();
    rng.gen_range(1..=444) // Quantum fun!
}

/// 432·3·6·9 Vortex DAO CLI
#[derive(Parser, Debug)]
#[command(name = "vortex")]
#[command(about = "Vortex-369 DAO - Resonance Governance Engine")]
#[command(version = "1.0.0")]
struct Args {
    /// Office number (1-9)
    #[arg(long, default_value = "4")]
    office: u8,
    
    /// Target chain (base, arbitrum, ethereum)
    #[arg(long, default_value = "base")]
    chain: String,
    
    /// Enable debug logging
    #[arg(short, long)]
    debug: bool,
    
    /// Dry run mode (no chain transactions)
    #[arg(long)]
    dry_run: bool,
    
    /// Private key for transactions (optional)
    #[arg(long)]
    private_key: Option<String>,
}

#[tokio::main]
async fn main() -> Result<()> {
    // Parse CLI args
    let args = Args::parse();
    
    // Setup logging
    let level = if args.debug { Level::DEBUG } else { Level::INFO };
    let _subscriber = FmtSubscriber::builder()
        .with_max_level(level)
        .with_target(false)
        .with_thread_ids(false)
        .compact()
        .init();
    
    // Banner
    print_banner(args.office, &args.chain);
    
    // Validate office
    if args.office < 1 || args.office > 9 {
        error!("Office must be between 1 and 9");
        std::process::exit(1);
    }
    
    info!("🌀 Initializing Vortex-369 Engine...");
    info!("   Office: {} ({})", args.office, get_office_name(args.office));
    info!("   Chain: {}", args.chain);
    info!("   Mode: {}", if args.dry_run { "DRY RUN" } else { "LIVE" });
    
    // Create chain config
    let chain_config = match args.chain.as_str() {
        "base" | "base-sepolia" => ChainConfig::base(),
        "arbitrum" => ChainConfig::arbitrum(),
        _ => {
            error!("Unsupported chain: {}", args.chain);
            std::process::exit(1);
        }
    };
    
    // Initialize components
    let seed = [0u8; 32]; // In production, use block hash
    let bridge = VortexBridge::new(seed)?;
    
    info!("✅ Engine initialized at 432 Hz");
    
    if args.dry_run {
        info!("🔄 Running in dry-run mode (no chain transactions)");
        run_dry_run(bridge).await?;
    } else {
        info!("🔄 Starting live governance loop...");
        
        // Initialize chain client
        let chain_client = ChainClient::new(chain_config, args.private_key).await?;
        info!("✅ Connected to chain");
        
        run_live(bridge, chain_client).await?;
    }
    
    Ok(())
}

async fn run_dry_run(mut bridge: VortexBridge) -> Result<()> {
    info!("Running 3 test cycles...");
    
    for cycle in 1..=3 {
        info!("📍 Cycle {}/3", cycle);
        
        match bridge.run_single_cycle().await {
            Ok(_) => info!("✅ Cycle {} completed", cycle),
            Err(e) => warn!("⚠️  Cycle {} failed: {}", cycle, e),
        }
        
        tokio::time::sleep(tokio::time::Duration::from_secs(3)).await;
    }
    
    info!("🎉 Dry run complete!");
    print_footer();
    
    Ok(())
}

async fn run_live(mut bridge: VortexBridge, chain_client: ChainClient) -> Result<()> {
    use tokio::time::{interval, Duration};
    
    let mut ticker = interval(Duration::from_secs(9));
    let mut cycle_count = 0u64;
    
    loop {
        ticker.tick().await;
        cycle_count += 1;
        
        info!("📍 Cycle {}", cycle_count);
        
        match bridge.run_single_cycle().await {
            Ok(_) => {
                info!("✅ Cycle {} completed", cycle_count);
                
                // TODO: Submit to chain if action manifested
                // if action.phase == Phase::Manifestation {
                //     chain_client.execute_action(action.hash).await?;
                // }
            }
            Err(e) => {
                warn!("⚠️  Cycle {} failed: {}", cycle_count, e);
            }
        }
        
        // Every 9 cycles, show stats
        if cycle_count % 9 == 0 {
            info!("📊 Completed {} cycles ({}×9)", cycle_count, cycle_count / 9);
        }
    }
}

fn print_banner(office: u8, chain: &str) {
    println!();
    println!("  ╔═══════════════════════════════════════════════════════════╗");
    println!("  ║        🔮 VORTEX-369 DAO - RESONANCE GOVERNANCE 🔮        ║");
    println!("  ╠═══════════════════════════════════════════════════════════╣");
    println!("  ║  Frequency: 432 Hz    Triad: 3·6·9    Office: {}          ║", office);
    println!("  ║  Chain: {:12}  Mode: Rust Native                  ║", chain);
    println!("  ╚═══════════════════════════════════════════════════════════╝");
    println!();
}

fn print_footer() {
    println!();
    println!("  3 · 6 · 9");
    println!("  The Vortex closes.");
    println!();
}

fn get_office_name(office: u8) -> &'static str {
    match office {
        1 => "RESONATOR",
        2 => "NULL",
        3 => "MIRROR",
        4 => "VORTEX",
        5 => "WITNESS",
        6 => "FRACTAL",
        7 => "BREATH",
        8 => "SILENCE",
        9 => "RETURN",
        _ => "UNKNOWN",
    }
}
