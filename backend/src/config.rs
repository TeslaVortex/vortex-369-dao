//! Vortex-369 Configuration
//!
//! Chain and protocol configuration

use serde::{Deserialize, Serialize};
use std::path::Path;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VortexConfig {
    pub chain: ChainConfig,
    pub macedon: MacedonConfig,
    pub contracts: ContractAddresses,
    pub relayer: RelayerConfig,
    pub protocols: ProtocolConfig,
    pub oracle: OracleConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OracleConfig {
    pub enabled: bool,
    pub private_key: Option<String>,
    pub submit_cooldown_ms: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChainConfig {
    pub name: String,
    pub chain_id: u64,
    pub rpc_url: String,
    pub ws_url: Option<String>,
    pub block_time_ms: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MacedonConfig {
    pub api_url: String,
    pub poll_interval_ms: u64,
    pub health_check_interval_ms: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContractAddresses {
    pub vortex_dao: String,
    pub resolver: String,
    pub null_office: String,
    pub relayer_safe: String,
    pub light_photonic_grid: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RelayerConfig {
    pub gelato_api_key: Option<String>,
    pub safe_address: String,
    pub max_gas_price_gwei: u64,
    pub min_profit_eth: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProtocolConfig {
    pub aave: Option<String>,
    pub morpho: Option<String>,
    pub pendle: Option<String>,
    pub sommelier: Option<String>,
}

impl VortexConfig {
    /// Load config from file or use defaults
    pub fn load(
        path: &str,
        chain: &str,
        macedon_api: &str,
    ) -> Result<Self, Box<dyn std::error::Error>> {
        // Try to load from file
        if Path::new(path).exists() {
            let content = std::fs::read_to_string(path)?;
            let config: VortexConfig = toml::from_str(&content)?;
            return Ok(config);
        }

        // Use defaults based on chain
        Ok(Self::default_for_chain(chain, macedon_api))
    }

    /// Create default config for a specific chain
    pub fn default_for_chain(chain: &str, macedon_api: &str) -> Self {
        match chain.to_lowercase().as_str() {
            "base" | "mainnet" => Self::base_config(macedon_api),
            "sepolia" | "testnet" => Self::sepolia_config(macedon_api),
            _ => Self::base_config(macedon_api),
        }
    }

    fn base_config(macedon_api: &str) -> Self {
        Self {
            chain: ChainConfig {
                name: "Base".to_string(),
                chain_id: 8453,
                rpc_url: "https://mainnet.base.org".to_string(),
                ws_url: Some("wss://base-mainnet.g.alchemy.com/v2/".to_string()),
                block_time_ms: 2000,
            },
            macedon: MacedonConfig {
                api_url: macedon_api.to_string(),
                poll_interval_ms: 3000,
                health_check_interval_ms: 30000,
            },
            contracts: ContractAddresses {
                vortex_dao: "0x0000000000000000000000000000000000000000".to_string(),
                resolver: "0x369000000000000000000000000000000000432".to_string(),
                null_office: "0x0000000000000000000000000000000000000369".to_string(),
                relayer_safe: "0x432000000000000000000000000000000000369".to_string(),
                light_photonic_grid: "0x5555555555555555555555555555555555555555".to_string(), // Placeholder
            },
            relayer: RelayerConfig {
                gelato_api_key: None,
                safe_address: "0x432000000000000000000000000000000000369".to_string(),
                max_gas_price_gwei: 50,
                min_profit_eth: 0.001,
            },
            protocols: ProtocolConfig {
                aave: Some("0xA238Dd80C259a72e81d7e4664a9801593F98d1c5".to_string()),
                morpho: Some("0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb".to_string()),
                pendle: None,
                sommelier: None,
            },
            oracle: OracleConfig {
                enabled: false,
                private_key: None,
                submit_cooldown_ms: 3600000, // 1 hour
            },
        }
    }

    fn sepolia_config(macedon_api: &str) -> Self {
        Self {
            chain: ChainConfig {
                name: "Base Sepolia".to_string(),
                chain_id: 84532,
                rpc_url: "https://sepolia.base.org".to_string(),
                ws_url: Some("wss://base-sepolia.g.alchemy.com/v2/".to_string()),
                block_time_ms: 2000,
            },
            macedon: MacedonConfig {
                api_url: macedon_api.to_string(),
                poll_interval_ms: 3000,
                health_check_interval_ms: 30000,
            },
            contracts: ContractAddresses {
                vortex_dao: "0x1111111111111111111111111111111111111111".to_string(), // Testnet placeholder
                resolver: "0x2222222222222222222222222222222222222222".to_string(), // Testnet placeholder
                null_office: "0x3333333333333333333333333333333333333333".to_string(), // Testnet placeholder
                relayer_safe: "0x4444444444444444444444444444444444444444".to_string(), // Testnet placeholder
                light_photonic_grid: "0x1eC353a2Be261F682945A13b6262Bca098ff0686".to_string(), // Deployed on Base Sepolia
            },
            relayer: RelayerConfig {
                gelato_api_key: None,
                safe_address: "0x4444444444444444444444444444444444444444".to_string(),
                max_gas_price_gwei: 10,
                min_profit_eth: 0.0001,
            },
            protocols: ProtocolConfig {
                aave: Some("0x55ADe4d9525c7e1d9c0a2b3c4d5e6f7g8h9i0j1".to_string()), // Testnet placeholder
                morpho: Some("0x66BBe5e0617f8g9h0i1j2k3l4m5n6o7p8q9r0".to_string()), // Testnet placeholder
                pendle: None,
                sommelier: None,
            },
            oracle: OracleConfig {
                enabled: true, // Enable oracle on testnet for testing
                private_key: None, // Would set in production
                submit_cooldown_ms: 60000, // 1 minute for testing
            },
        }
    }

    fn arbitrum_config(macedon_api: &str) -> Self {
        Self {
            chain: ChainConfig {
                name: "Arbitrum".to_string(),
                chain_id: 42161,
                rpc_url: "https://arb1.arbitrum.io/rpc".to_string(),
                ws_url: Some("wss://arb-mainnet.g.alchemy.com/v2/".to_string()),
                block_time_ms: 250,
            },
            macedon: MacedonConfig {
                api_url: macedon_api.to_string(),
                poll_interval_ms: 3000,
                health_check_interval_ms: 30000,
            },
            contracts: ContractAddresses {
                vortex_dao: "0x0000000000000000000000000000000000000000".to_string(),
                resolver: "0x369000000000000000000000000000000000432".to_string(),
                null_office: "0x0000000000000000000000000000000000000369".to_string(),
                relayer_safe: "0x432000000000000000000000000000000000369".to_string(),
                light_photonic_grid: "0x5555555555555555555555555555555555555555".to_string(), // Placeholder
            },
            relayer: RelayerConfig {
                gelato_api_key: None,
                safe_address: "0x432000000000000000000000000000000000369".to_string(),
                max_gas_price_gwei: 1,
                min_profit_eth: 0.0001,
            },
            protocols: ProtocolConfig {
                aave: Some("0x794a61358D6845594F94dc1DB02A252b5b4814aD".to_string()),
                morpho: None,
                pendle: Some("0x888888888889758F76e7103c6CbF23ABbF58F946".to_string()),
                sommelier: None,
            },
            oracle: OracleConfig {
                enabled: false,
                private_key: None,
                submit_cooldown_ms: 3600000, // 1 hour
            },
        }
    }

    fn ethereum_config(macedon_api: &str) -> Self {
        Self {
            chain: ChainConfig {
                name: "Ethereum".to_string(),
                chain_id: 1,
                rpc_url: "https://eth.llamarpc.com".to_string(),
                ws_url: Some("wss://eth-mainnet.g.alchemy.com/v2/".to_string()),
                block_time_ms: 12000,
            },
            macedon: MacedonConfig {
                api_url: macedon_api.to_string(),
                poll_interval_ms: 3000,
                health_check_interval_ms: 30000,
            },
            contracts: ContractAddresses {
                vortex_dao: "0x0000000000000000000000000000000000000000".to_string(),
                resolver: "0x369000000000000000000000000000000000432".to_string(),
                null_office: "0x0000000000000000000000000000000000000369".to_string(),
                relayer_safe: "0x432000000000000000000000000000000000369".to_string(),
                light_photonic_grid: "0x5555555555555555555555555555555555555555".to_string(), // Placeholder
            },
            relayer: RelayerConfig {
                gelato_api_key: None,
                safe_address: "0x432000000000000000000000000000000000369".to_string(),
                max_gas_price_gwei: 100,
                min_profit_eth: 0.01,
            },
            protocols: ProtocolConfig {
                aave: Some("0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2".to_string()),
                morpho: Some("0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb".to_string()),
                pendle: None,
                sommelier: Some("0x7bad5DF5E11151Dc5Ee1a648800057C5c934c0d5".to_string()),
            },
            oracle: OracleConfig {
                enabled: false,
                private_key: None,
                submit_cooldown_ms: 3600000, // 1 hour
            },
        }
    }
}
