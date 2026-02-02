import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../hooks/useWeb3';
import {
  grantScorerRole,
  revokeScorerRole,
  grantAdminRole,
  revokeAdminRole,
  grantEmergencyRole,
  revokeEmergencyRole,
  getAdminConfiguration,
  isMultiSigAdmin
} from '../utils/contracts';

interface RoleManagementProps {}

export const RoleManagement: React.FC<RoleManagementProps> = () => {
  const { isConnected, signer } = useWeb3();
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(false);
  const [address, setAddress] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [adminConfig, setAdminConfig] = useState<any>(null);

  useEffect(() => {
    if (isConnected && signer) {
      checkAdminStatus();
      loadAdminConfig();
    }
  }, [isConnected, signer]);

  const checkAdminStatus = async () => {
    if (!signer) return;
    try {
      const userAddress = await signer.getAddress();
      const isAdminUser = await isMultiSigAdmin(userAddress);
      setIsAdmin(isAdminUser);
    } catch (err) {
      console.error('Failed to check admin status:', err);
    }
  };

  const loadAdminConfig = async () => {
    try {
      const config = await getAdminConfiguration();
      setAdminConfig(config);
    } catch (err) {
      console.error('Failed to load admin config:', err);
    }
  };

  const handleRoleAction = async (action: string, role: string) => {
    if (!address.trim()) {
      setError('Please enter an address');
      return;
    }

    setLoading(true);
    setError('');
    setSuccess('');

    try {
      switch (action) {
        case 'grant':
          switch (role) {
            case 'scorer':
              await grantScorerRole(address.trim());
              break;
            case 'admin':
              await grantAdminRole(address.trim());
              break;
            case 'emergency':
              await grantEmergencyRole(address.trim());
              break;
          }
          break;
        case 'revoke':
          switch (role) {
            case 'scorer':
              await revokeScorerRole(address.trim());
              break;
            case 'admin':
              await revokeAdminRole(address.trim());
              break;
            case 'emergency':
              await revokeEmergencyRole(address.trim());
              break;
          }
          break;
      }

      setSuccess(`${action.charAt(0).toUpperCase() + action.slice(1)}ed ${role} role for ${address.trim()}`);
      setAddress('');
      await loadAdminConfig(); // Refresh config
    } catch (err: any) {
      setError(err.message || `Failed to ${action} ${role} role`);
    } finally {
      setLoading(false);
    }
  };

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
        <div style={{ fontSize: '24px', marginBottom: '8px' }}>🔐</div>
        <div>Connect wallet to manage roles</div>
      </div>
    );
  }

  if (!isAdmin) {
    return (
      <div style={{
        backgroundColor: '#f8f9fa',
        border: '2px solid #dc3545',
        borderRadius: '12px',
        padding: '20px',
        textAlign: 'center',
        color: '#dc3545',
      }}>
        <div style={{ fontSize: '24px', marginBottom: '8px' }}>🚫</div>
        <div>Admin access required for role management</div>
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
        🔐 Role Management
      </h3>

      {/* Address Input */}
      <div style={{ marginBottom: '16px' }}>
        <label htmlFor="roleAddress" style={{
          display: 'block',
          marginBottom: '8px',
          fontWeight: 'bold',
          color: '#369',
        }}>
          Address:
        </label>
        <input
          id="roleAddress"
          type="text"
          value={address}
          onChange={(e) => setAddress(e.target.value)}
          placeholder="0x..."
          style={{
            width: '100%',
            padding: '12px',
            border: '2px solid #369',
            borderRadius: '8px',
            fontSize: '16px',
            fontFamily: 'inherit',
            boxSizing: 'border-box',
          }}
          disabled={loading}
        />
      </div>

      {/* Error Message */}
      {error && (
        <div style={{
          color: '#dc3545',
          backgroundColor: '#f8d7da',
          border: '1px solid #f5c6cb',
          borderRadius: '4px',
          padding: '8px 12px',
          marginBottom: '12px',
          fontSize: '14px',
        }}>
          ⚠️ {error}
        </div>
      )}

      {/* Success Message */}
      {success && (
        <div style={{
          color: '#155724',
          backgroundColor: '#d4edda',
          border: '1px solid #c3e6cb',
          borderRadius: '4px',
          padding: '8px 12px',
          marginBottom: '12px',
          fontSize: '14px',
        }}>
          ✅ {success}
        </div>
      )}

      {/* Role Actions */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '12px' }}>
        {/* SCORER_ROLE */}
        <div style={{
          border: '1px solid #ddd',
          borderRadius: '8px',
          padding: '12px',
          backgroundColor: '#fff',
        }}>
          <h4 style={{ margin: '0 0 8px 0', color: '#369' }}>🎯 SCORER_ROLE</h4>
          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              onClick={() => handleRoleAction('grant', 'scorer')}
              disabled={loading || !address.trim()}
              style={{
                flex: 1,
                backgroundColor: loading ? '#666' : '#28a745',
                color: 'white',
                border: 'none',
                padding: '8px',
                borderRadius: '4px',
                cursor: loading ? 'not-allowed' : 'pointer',
                fontSize: '14px',
              }}
            >
              Grant
            </button>
            <button
              onClick={() => handleRoleAction('revoke', 'scorer')}
              disabled={loading || !address.trim()}
              style={{
                flex: 1,
                backgroundColor: loading ? '#666' : '#dc3545',
                color: 'white',
                border: 'none',
                padding: '8px',
                borderRadius: '4px',
                cursor: loading ? 'not-allowed' : 'pointer',
                fontSize: '14px',
              }}
            >
              Revoke
            </button>
          </div>
        </div>

        {/* ADMIN_ROLE */}
        <div style={{
          border: '1px solid #ddd',
          borderRadius: '8px',
          padding: '12px',
          backgroundColor: '#fff',
        }}>
          <h4 style={{ margin: '0 0 8px 0', color: '#369' }}>👑 ADMIN_ROLE</h4>
          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              onClick={() => handleRoleAction('grant', 'admin')}
              disabled={loading || !address.trim()}
              style={{
                flex: 1,
                backgroundColor: loading ? '#666' : '#28a745',
                color: 'white',
                border: 'none',
                padding: '8px',
                borderRadius: '4px',
                cursor: loading ? 'not-allowed' : 'pointer',
                fontSize: '14px',
              }}
            >
              Grant
            </button>
            <button
              onClick={() => handleRoleAction('revoke', 'admin')}
              disabled={loading || !address.trim()}
              style={{
                flex: 1,
                backgroundColor: loading ? '#666' : '#dc3545',
                color: 'white',
                border: 'none',
                padding: '8px',
                borderRadius: '4px',
                cursor: loading ? 'not-allowed' : 'pointer',
                fontSize: '14px',
              }}
            >
              Revoke
            </button>
          </div>
        </div>

        {/* EMERGENCY_ROLE */}
        <div style={{
          border: '1px solid #ddd',
          borderRadius: '8px',
          padding: '12px',
          backgroundColor: '#fff',
        }}>
          <h4 style={{ margin: '0 0 8px 0', color: '#369' }}>🚨 EMERGENCY_ROLE</h4>
          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              onClick={() => handleRoleAction('grant', 'emergency')}
              disabled={loading || !address.trim()}
              style={{
                flex: 1,
                backgroundColor: loading ? '#666' : '#28a745',
                color: 'white',
                border: 'none',
                padding: '8px',
                borderRadius: '4px',
                cursor: loading ? 'not-allowed' : 'pointer',
                fontSize: '14px',
              }}
            >
              Grant
            </button>
            <button
              onClick={() => handleRoleAction('revoke', 'emergency')}
              disabled={loading || !address.trim()}
              style={{
                flex: 1,
                backgroundColor: loading ? '#666' : '#dc3545',
                color: 'white',
                border: 'none',
                padding: '8px',
                borderRadius: '4px',
                cursor: loading ? 'not-allowed' : 'pointer',
                fontSize: '14px',
              }}
            >
              Revoke
            </button>
          </div>
        </div>
      </div>

      {/* Admin Configuration Display */}
      {adminConfig && (
        <div style={{
          marginTop: '20px',
          padding: '12px',
          backgroundColor: '#e9ecef',
          borderRadius: '8px',
          fontSize: '14px',
        }}>
          <h4 style={{ margin: '0 0 8px 0', color: '#369' }}>Admin Configuration</h4>
          <pre style={{ margin: 0, whiteSpace: 'pre-wrap', wordBreak: 'break-all' }}>
            {JSON.stringify(adminConfig, null, 2)}
          </pre>
        </div>
      )}
    </div>
  );
};
