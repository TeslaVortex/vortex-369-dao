use anyhow::{Result, Context};
use ethers::{
    prelude::*,
    providers::{Provider, Http, Middleware},
    signers::{LocalWallet, Signer},
    types::{Address, TransactionReceipt, H256, U256},
};
use std::sync::Arc;

/// Chain configuration
#[derive(Debug, Clone)]
pub struct ChainConfig {
    pub rpc_url: String,
    pub chain_id: u64,
    pub dao_address: Address,
    pub null_office: Address,
}

impl ChainConfig {
    pub fn base() -> Self {
        Self {
            rpc_url: "https://mainnet.base.org".to_string(),
            chain_id: 8453,
            dao_address: Address::zero(), // To be set after deployment
            null_office: "0x0000000000000000000000000000000000000369".parse().unwrap(),
        }
    }

    pub fn arbitrum() -> Self {
        Self {
            rpc_url: "https://arb1.arbitrum.io/rpc".to_string(),
            chain_id: 42161,
            dao_address: Address::zero(),
            null_office: "0x0000000000000000000000000000000000000369".parse().unwrap(),
        }
    }
}

/// Chain client for interacting with VortexDAO contracts
pub struct ChainClient {
    provider: Arc<Provider<Http>>,
    wallet: Option<LocalWallet>,
    config: ChainConfig,
}

impl ChainClient {
    /// Create new chain client
    pub async fn new(config: ChainConfig, private_key: Option<String>) -> Result<Self> {
        let provider = Provider::<Http>::try_from(&config.rpc_url)
            .context("Failed to create provider")?;
        
        let wallet = if let Some(key) = private_key {
            Some(key.parse::<LocalWallet>()
                .context("Failed to parse private key")?)
        } else {
            None
        };

        Ok(Self {
            provider: Arc::new(provider),
            wallet,
            config,
        })
    }

    /// Get current block number
    pub async fn get_block_number(&self) -> Result<u64> {
        let block_num = self.provider
            .get_block_number()
            .await
            .context("Failed to get block number")?;
        Ok(block_num.as_u64())
    }

    /// Get block hash for seeding synthetic generator
    pub async fn get_block_hash(&self, block_number: u64) -> Result<[u8; 32]> {
        let block = self.provider
            .get_block(block_number)
            .await
            .context("Failed to get block")?
            .context("Block not found")?;
        
        Ok(block.hash.unwrap_or_default().0)
    }

    /// Execute action on-chain (requires wallet)
    pub async fn execute_action(&self, action_hash: [u8; 32]) -> Result<TransactionReceipt> {
        let wallet = self.wallet.as_ref()
            .context("Wallet required for transactions")?;
        
        // TODO: Replace with actual contract call once ABI is generated
        tracing::info!("Would execute action: 0x{}", hex::encode(action_hash));
        
        // Placeholder: Send a simple transaction
        let tx = TransactionRequest::new()
            .to(self.config.dao_address)
            .value(U256::zero())
            .data(self.encode_execute_action(action_hash));
        
        let pending_tx = self.provider
            .send_transaction(tx, None)
            .await
            .context("Failed to send transaction")?;
        
        let receipt = pending_tx
            .await
            .context("Transaction failed")?
            .context("No receipt")?;
        
        Ok(receipt)
    }

    /// Advance action phase on-chain
    pub async fn advance_phase(
        &self,
        action_hash: [u8; 32],
        witness: String,
    ) -> Result<TransactionReceipt> {
        let wallet = self.wallet.as_ref()
            .context("Wallet required for transactions")?;
        
        tracing::info!(
            "Would advance phase for action: 0x{}, witness: {}",
            hex::encode(action_hash),
            witness
        );
        
        // TODO: Replace with actual contract call
        let tx = TransactionRequest::new()
            .to(self.config.dao_address)
            .value(U256::zero())
            .data(self.encode_advance_phase(action_hash, &witness));
        
        let pending_tx = self.provider
            .send_transaction(tx, None)
            .await
            .context("Failed to send transaction")?;
        
        let receipt = pending_tx
            .await
            .context("Transaction failed")?
            .context("No receipt")?;
        
        Ok(receipt)
    }

    /// Get DAO treasury balance
    pub async fn get_dao_balance(&self) -> Result<U256> {
        self.provider
            .get_balance(self.config.dao_address, None)
            .await
            .context("Failed to get DAO balance")
    }

    /// Get null office balance (burned funds)
    pub async fn get_null_balance(&self) -> Result<U256> {
        self.provider
            .get_balance(self.config.null_office, None)
            .await
            .context("Failed to get null office balance")
    }

    /// Encode executeAction call data
    fn encode_execute_action(&self, action_hash: [u8; 32]) -> Vec<u8> {
        // Function selector for executeAction(bytes32)
        let selector = &ethers::utils::keccak256(b"executeAction(bytes32)")[..4];
        let mut data = selector.to_vec();
        data.extend_from_slice(&action_hash);
        data
    }

    /// Encode advancePhase call data
    fn encode_advance_phase(&self, action_hash: [u8; 32], witness: &str) -> Vec<u8> {
        // Function selector for advancePhase(bytes32,string)
        let selector = &ethers::utils::keccak256(b"advancePhase(bytes32,string)")[..4];
        let mut data = selector.to_vec();
        data.extend_from_slice(&action_hash);
        // TODO: Properly encode string parameter
        data
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_chain_config() {
        let config = ChainConfig::base();
        assert_eq!(config.chain_id, 8453);
        assert_eq!(config.null_office, "0x0000000000000000000000000000000000000369".parse::<Address>().unwrap());
    }

    #[tokio::test]
    async fn test_client_creation_without_wallet() {
        let config = ChainConfig::base();
        let result = ChainClient::new(config, None).await;
        assert!(result.is_ok());
    }
}
