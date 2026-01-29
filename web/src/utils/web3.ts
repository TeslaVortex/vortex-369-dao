import { ethers } from 'ethers';

// Web3 connection types
export interface Web3State {
  provider: ethers.BrowserProvider | null;
  signer: ethers.Signer | null;
  address: string | null;
  chainId: number | null;
  isConnected: boolean;
  isConnecting: boolean;
  error: string | null;
}

// Contract addresses (to be configured from environment)
export const CONTRACT_ADDRESSES = {
  VORTEX_DAO: import.meta.env.VITE_VORTEX_DAO_ADDRESS || '',
  VORTEX_RESOLVER: import.meta.env.VITE_VORTEX_RESOLVER_ADDRESS || '',
  PELLION_SHIELD: import.meta.env.VITE_PELLION_SHIELD_ADDRESS || '',
};

// Network configuration
export const NETWORKS = {
  8453: {
    name: 'Base Mainnet',
    rpcUrl: 'https://mainnet.base.org',
    blockExplorer: 'https://basescan.org',
  },
  84532: {
    name: 'Base Sepolia',
    rpcUrl: 'https://sepolia.base.org',
    blockExplorer: 'https://sepolia.basescan.org',
  },
  31337: {
    name: 'Localhost',
    rpcUrl: 'http://localhost:8545',
    blockExplorer: '',
  },
};

// Check if MetaMask is installed
export const isMetaMaskInstalled = (): boolean => {
  return typeof window !== 'undefined' && !!(window as any).ethereum;
};

// Get MetaMask provider
export const getMetaMaskProvider = (): any => {
  if (!isMetaMaskInstalled()) {
    throw new Error('MetaMask is not installed');
  }
  return (window as any).ethereum;
};

// Create ethers provider from MetaMask
export const createProvider = async (): Promise<ethers.BrowserProvider> => {
  const ethereum = getMetaMaskProvider();
  return new ethers.BrowserProvider(ethereum);
};

// Request account access
export const requestAccounts = async (): Promise<string[]> => {
  const ethereum = getMetaMaskProvider();
  return await ethereum.request({ method: 'eth_requestAccounts' });
};

// Switch to specific network
export const switchToNetwork = async (chainId: number): Promise<void> => {
  const ethereum = getMetaMaskProvider();

  try {
    await ethereum.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId: `0x${chainId.toString(16)}` }],
    });
  } catch (error: any) {
    // If network doesn't exist, add it
    if (error.code === 4902) {
      await addNetwork(chainId);
    } else {
      throw error;
    }
  }
};

// Add network to MetaMask
export const addNetwork = async (chainId: number): Promise<void> => {
  const network = NETWORKS[chainId as keyof typeof NETWORKS];
  if (!network) {
    throw new Error(`Network with chainId ${chainId} not configured`);
  }

  const ethereum = getMetaMaskProvider();
  await ethereum.request({
    method: 'wallet_addEthereumChain',
    params: [{
      chainId: `0x${chainId.toString(16)}`,
      chainName: network.name,
      rpcUrls: [network.rpcUrl],
      blockExplorerUrls: network.blockExplorer ? [network.blockExplorer] : undefined,
      nativeCurrency: {
        name: 'Ether',
        symbol: 'ETH',
        decimals: 18,
      },
    }],
  });
};
