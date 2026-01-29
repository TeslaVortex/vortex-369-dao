import React, { useState } from 'react';
import { Proposal, voteOnProposal, executeProposal } from '../utils/contracts';
import { useWeb3 } from '../hooks/useWeb3';

interface ProposalCardProps {
  proposal: Proposal;
  onVote: () => void;
}

export const ProposalCard: React.FC<ProposalCardProps> = ({ proposal, onVote }) => {
  const { isConnected, address } = useWeb3();
  const [voting, setVoting] = useState(false);
  const [executing, setExecuting] = useState(false);
  const [error, setError] = useState('');

  const getPhaseName = (phase: number) => {
    const phases = [
      'Silence', 'Proposal', 'Mirror', 'Vortex', 'Resolution',
      'Fractal', 'Breath', 'Witness', 'Return', 'Manifestation'
    ];
    return phases[phase] || 'Unknown';
  };

  const getPhaseColor = (phase: number) => {
    if (phase >= 9) return '#28a745'; // Manifestation - green
    if (phase >= 6) return '#ffc107'; // Active phases - yellow
    return '#6c757d'; // Early phases - gray
  };

  const handleVote = async (support: boolean) => {
    if (!isConnected) {
      setError('Please connect your wallet first');
      return;
    }

    setVoting(true);
    setError('');

    try {
      await voteOnProposal(proposal.id, support);
      onVote(); // Refresh proposals
    } catch (err: any) {
      setError(err.message || 'Failed to vote');
    } finally {
      setVoting(false);
    }
  };

  const handleExecute = async () => {
    if (!isConnected) {
      setError('Please connect your wallet first');
      return;
    }

    setExecuting(true);
    setError('');

    try {
      await executeProposal(proposal.id);
      onVote(); // Refresh proposals
    } catch (err: any) {
      setError(err.message || 'Failed to execute proposal');
    } finally {
      setExecuting(false);
    }
  };

  const canVote = isConnected && !proposal.executed && proposal.phase >= 1 && proposal.phase <= 8;
  const canExecute = isConnected && !proposal.executed && proposal.phase === 9 && proposal.score >= 80;

  return (
    <div style={{
      backgroundColor: '#ffffff',
      border: `2px solid ${getPhaseColor(proposal.phase)}`,
      borderRadius: '12px',
      padding: '20px',
      marginBottom: '16px',
      boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
    }}>
      {/* Header */}
      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: '16px',
      }}>
        <div>
          <h3 style={{ margin: '0 0 4px 0', color: '#369' }}>
            Proposal #{proposal.id}
          </h3>
          <div style={{
            fontSize: '14px',
            color: '#666',
            fontFamily: 'monospace',
          }}>
            {proposal.proposer.slice(0, 6)}...{proposal.proposer.slice(-4)}
          </div>
        </div>

        <div style={{ textAlign: 'right' }}>
          <div style={{
            fontSize: '18px',
            fontWeight: 'bold',
            color: getPhaseColor(proposal.phase),
          }}>
            {getPhaseName(proposal.phase)}
          </div>
          <div style={{
            fontSize: '14px',
            color: '#666',
          }}>
            Score: {proposal.score}/100
          </div>
        </div>
      </div>

      {/* Proposal Text */}
      <div style={{
        backgroundColor: '#f8f9fa',
        padding: '16px',
        borderRadius: '8px',
        marginBottom: '16px',
        border: '1px solid #dee2e6',
      }}>
        <p style={{
          margin: '0',
          lineHeight: '1.5',
          fontSize: '16px',
        }}>
          {proposal.text}
        </p>
      </div>

      {/* Voting Stats */}
      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: '16px',
        padding: '12px',
        backgroundColor: '#f8f9fa',
        borderRadius: '8px',
      }}>
        <div>
          <strong>👍 For:</strong> {proposal.votesFor}
        </div>
        <div>
          <strong>👎 Against:</strong> {proposal.votesAgainst}
        </div>
        <div>
          <strong>📅 Phase:</strong> {proposal.phase}/9
        </div>
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
          {error}
        </div>
      )}

      {/* Action Buttons */}
      <div style={{
        display: 'flex',
        gap: '12px',
        flexWrap: 'wrap',
      }}>
        {canVote && (
          <>
            <button
              onClick={() => handleVote(true)}
              disabled={voting}
              style={{
                backgroundColor: '#28a745',
                color: 'white',
                border: 'none',
                padding: '10px 16px',
                borderRadius: '6px',
                cursor: voting ? 'not-allowed' : 'pointer',
                fontSize: '14px',
                fontWeight: 'bold',
              }}
            >
              {voting ? '🗳️ Voting...' : '👍 Vote For'}
            </button>

            <button
              onClick={() => handleVote(false)}
              disabled={voting}
              style={{
                backgroundColor: '#dc3545',
                color: 'white',
                border: 'none',
                padding: '10px 16px',
                borderRadius: '6px',
                cursor: voting ? 'not-allowed' : 'pointer',
                fontSize: '14px',
                fontWeight: 'bold',
              }}
            >
              {voting ? '🗳️ Voting...' : '👎 Vote Against'}
            </button>
          </>
        )}

        {canExecute && (
          <button
            onClick={handleExecute}
            disabled={executing}
            style={{
              backgroundColor: '#ffc107',
              color: '#212529',
              border: 'none',
              padding: '10px 16px',
              borderRadius: '6px',
              cursor: executing ? 'not-allowed' : 'pointer',
              fontSize: '14px',
              fontWeight: 'bold',
            }}
          >
            {executing ? '⚡ Executing...' : '⚡ Execute Proposal'}
          </button>
        )}

        {proposal.executed && (
          <div style={{
            color: '#28a745',
            fontWeight: 'bold',
            padding: '8px 12px',
            backgroundColor: '#d4edda',
            borderRadius: '6px',
            border: '1px solid #c3e6cb',
          }}>
            ✅ Executed
          </div>
        )}
      </div>
    </div>
  );
};
