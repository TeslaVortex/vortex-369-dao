import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import {
  Web3State,
  createProvider,
  requestAccounts,
  switchToNetwork,
  getMetaMaskProvider,
  isMetaMaskInstalled,
} from '../utils/web3';

const TARGET_CHAIN_ID = 8453; // Base Mainnet

export const useWeb3 = () => {
  const [web3State, setWeb3State] = useState<Web3State>({
    provider: null,
    signer: null,
    address: null,
    chainId: null,
    isConnected: false,
    isConnecting: false,
    error: null,
  });

  // Initialize on mount and listen for account/chain changes
  useEffect(() => {
    if (!isMetaMaskInstalled()) {
      setWeb3State(prev => ({
        ...prev,
        error: 'MetaMask is not installed. Please install MetaMask to connect to the blockchain.',
      }));
      return;
    }

    const ethereum = getMetaMaskProvider();

    // Listen for account changes
    const handleAccountsChanged = (accounts: string[]) => {
      if (accounts.length > 0) {
        connectWallet();
      } else {
        disconnectWallet();
      }
    };

    // Listen for chain changes
    const handleChainChanged = () => {
      window.location.reload(); // MetaMask recommends reloading on chain change
    };

    ethereum.on('accountsChanged', handleAccountsChanged);
    ethereum.on('chainChanged', handleChainChanged);

    // Try to connect if already connected
    connectWallet();

    return () => {
      ethereum.removeListener('accountsChanged', handleAccountsChanged);
      ethereum.removeListener('chainChanged', handleChainChanged);
    };
  }, []);

  const connectWallet = async () => {
    if (!isMetaMaskInstalled()) {
      setWeb3State(prev => ({
        ...prev,
        error: 'MetaMask is not installed',
      }));
      return;
    }

    setWeb3State(prev => ({ ...prev, isConnecting: true, error: null }));

    try {
      // Request account access
      await requestAccounts();

      // Create provider and signer
      const provider = await createProvider();
      const signer = await provider.getSigner();
      const address = await signer.getAddress();
      const network = await provider.getNetwork();
      const chainId = Number(network.chainId);

      // Switch to target network if not already on it
      if (chainId !== TARGET_CHAIN_ID) {
        await switchToNetwork(TARGET_CHAIN_ID);
        // Reload after network switch
        window.location.reload();
        return;
      }

      setWeb3State({
        provider,
        signer,
        address,
        chainId,
        isConnected: true,
        isConnecting: false,
        error: null,
      });
    } catch (error: any) {
      console.error('Failed to connect wallet:', error);
      setWeb3State(prev => ({
        ...prev,
        isConnecting: false,
        error: error.message || 'Failed to connect wallet',
      }));
    }
  };

  const disconnectWallet = () => {
    setWeb3State({
      provider: null,
      signer: null,
      address: null,
      chainId: null,
      isConnected: false,
      isConnecting: false,
      error: null,
    });
  };

  const switchNetwork = async (chainId: number) => {
    try {
      await switchToNetwork(chainId);
      // This will trigger a page reload via the chainChanged listener
    } catch (error: any) {
      setWeb3State(prev => ({
        ...prev,
        error: error.message || 'Failed to switch network',
      }));
    }
  };

  return {
    ...web3State,
    connectWallet,
    disconnectWallet,
    switchNetwork,
  };
};
