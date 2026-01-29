import React, { useState, useEffect } from 'react';
import { getTotalBurned } from '../utils/contracts';
import { useWeb3 } from '../hooks/useWeb3';

export const TreasuryDisplay: React.FC = () => {
  const { isConnected } = useWeb3();
  const [totalBurned, setTotalBurned] = useState<string>('0');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const loadTreasuryData = async () => {
    if (!isConnected) return;

    try {
      setLoading(true);
      setError('');
      const burned = await getTotalBurned();
      setTotalBurned(burned);
    } catch (err: any) {
      setError('Failed to load treasury data');
      console.error('Error loading treasury:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadTreasuryData();
  }, [isConnected]);

  if (!isConnected) {
    return (
      <div style={{
        backgroundColor: '#f8f9fa',
        border: '2px solid #6c757d',
        borderRadius: '12px',
        padding: '20px',
        textAlign: 'center',
        color: '#6c757d',
      }}>
        <div style={{ fontSize: '24px', marginBottom: '8px' }}>🏦</div>
        <div>Connect wallet to view treasury</div>
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
    }}>
      <h3 style={{
        color: '#369',
        margin: '0 0 16px 0',
        textAlign: 'center',
      }}>
        🏦 DAO Treasury
      </h3>

      <div style={{
        display: 'grid',
        gridTemplateColumns: '1fr 1fr',
        gap: '16px',
      }}>
        {/* Total Burned */}
        <div style={{
          backgroundColor: 'white',
          borderRadius: '8px',
          padding: '16px',
          textAlign: 'center',
          border: '1px solid #dee2e6',
        }}>
          <div style={{
            fontSize: '24px',
            fontWeight: 'bold',
            color: '#dc3545',
            marginBottom: '4px',
          }}>
            🔥
          </div>
          <div style={{
            fontSize: '18px',
            fontWeight: 'bold',
            color: '#dc3545',
          }}>
            {loading ? '...' : `${parseFloat(totalBurned).toFixed(4)} ETH`}
          </div>
          <div style={{
            fontSize: '14px',
            color: '#666',
          }}>
            Total Burned
          </div>
        </div>

        {/* Active Proposals */}
        <div style={{
          backgroundColor: 'white',
          borderRadius: '8px',
          padding: '16px',
          textAlign: 'center',
          border: '1px solid #dee2e6',
        }}>
          <div style={{
            fontSize: '24px',
            fontWeight: 'bold',
            color: '#ffc107',
            marginBottom: '4px',
          }}>
            📋
          </div>
          <div style={{
            fontSize: '18px',
            fontWeight: 'bold',
            color: '#ffc107',
          }}>
            --
          </div>
          <div style={{
            fontSize: '14px',
            color: '#666',
          }}>
            Active Proposals
          </div>
        </div>
      </div>

      {error && (
        <div style={{
          marginTop: '16px',
          color: '#dc3545',
          backgroundColor: '#f8d7da',
          border: '1px solid #f5c6cb',
          borderRadius: '4px',
          padding: '8px 12px',
          fontSize: '14px',
          textAlign: 'center',
        }}>
          {error}
        </div>
      )}

      <div style={{
        marginTop: '16px',
        textAlign: 'center',
      }}>
        <button
          onClick={loadTreasuryData}
          disabled={loading}
          style={{
            backgroundColor: '#369',
            color: 'white',
            border: 'none',
            padding: '8px 16px',
            borderRadius: '6px',
            cursor: loading ? 'not-allowed' : 'pointer',
            fontSize: '14px',
          }}
        >
          {loading ? '🔄' : '🔄'} Refresh
        </button>
      </div>
    </div>
  );
};
