import React, { useMemo } from 'react';
import { useWeb3 } from '../hooks/useWeb3';

export const ConnectWallet: React.FC = React.memo(() => {
  const {
    address,
    chainId,
    isConnected,
    isConnecting,
    error,
    connectWallet,
    disconnectWallet,
  } = useWeb3();

  const walletInfo = useMemo(() => {
    if (!address) return null;

    const formatAddress = (addr: string) => {
      return `${addr.slice(0, 6)}...${addr.slice(-4)}`;
    };

    const getNetworkName = (chainId: number) => {
      const networks: { [key: number]: string } = {
        1: 'Ethereum',
        8453: 'Base',
        84532: 'Base Sepolia',
        31337: 'Localhost',
      };
      return networks[chainId] || `Chain ${chainId}`;
    };

    return {
      formattedAddress: formatAddress(address),
      networkName: getNetworkName(chainId || 0),
    };
  }, [address, chainId]);

  if (error && !isConnected) {
    return (
      <div style={{
        backgroundColor: '#f8d7da',
        border: '1px solid #f5c6cb',
        borderRadius: '8px',
        padding: '16px',
        marginBottom: '20px',
        textAlign: 'center',
      }}>
        <div style={{ color: '#721c24', marginBottom: '12px' }}>
          ⚠️ {error}
        </div>
        <a
          href="https://metamask.io/download/"
          target="_blank"
          rel="noopener noreferrer"
          style={{
            color: '#007bff',
            textDecoration: 'none',
            fontWeight: 'bold',
          }}
        >
          Download MetaMask →
        </a>
      </div>
    );
  }

  return (
    <div style={{
      backgroundColor: '#f8f9fa',
      border: '2px solid #369',
      borderRadius: '12px',
      padding: '20px',
      marginBottom: '20px',
      textAlign: 'center',
    }}>
      {isConnected && walletInfo ? (
        <div>
          <div style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '12px',
            marginBottom: '12px',
          }}>
            <div style={{
              width: '12px',
              height: '12px',
              borderRadius: '50%',
              backgroundColor: '#28a745',
            }} />
            <span style={{
              fontSize: '18px',
              fontWeight: 'bold',
              color: '#369',
            }}>
              Connected to {walletInfo.networkName}
            </span>
          </div>

          <div style={{
            backgroundColor: 'white',
            border: '1px solid #dee2e6',
            borderRadius: '8px',
            padding: '12px',
            marginBottom: '12px',
            fontFamily: 'monospace',
            fontSize: '16px',
          }}>
            {walletInfo.formattedAddress}
          </div>

          <button
            onClick={disconnectWallet}
            style={{
              backgroundColor: '#dc3545',
              color: 'white',
              border: 'none',
              padding: '10px 20px',
              borderRadius: '6px',
              fontSize: '14px',
              cursor: 'pointer',
            }}
          >
            Disconnect Wallet
          </button>
        </div>
      ) : (
        <div>
          <div style={{
            fontSize: '20px',
            fontWeight: 'bold',
            color: '#369',
            marginBottom: '12px',
          }}>
            🏦 Connect Your Wallet
          </div>

          <p style={{
            color: '#666',
            marginBottom: '20px',
            fontSize: '16px',
          }}>
            Connect your MetaMask wallet to interact with the Vortex-369 DAO
          </p>

          <button
            onClick={connectWallet}
            disabled={isConnecting}
            style={{
              backgroundColor: isConnecting ? '#666' : '#369',
              color: 'white',
              border: 'none',
              padding: '14px 28px',
              borderRadius: '8px',
              fontSize: '16px',
              fontWeight: 'bold',
              cursor: isConnecting ? 'not-allowed' : 'pointer',
              transition: 'background-color 0.2s',
            }}
          >
            {isConnecting ? '🔄 Connecting...' : '🔗 Connect MetaMask'}
          </button>
        </div>
      )}
    </div>
  );
});
