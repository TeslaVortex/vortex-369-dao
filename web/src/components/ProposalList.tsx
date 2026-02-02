import React, { useState, useEffect } from 'react';
import { Proposal, getProposal } from '../utils/contracts';
import { ProposalCard } from './ProposalCard';

interface ProposalListProps {
  proposalIds: string[];
  proposalContents: { [key: string]: { title: string, description: string } };
}

export const ProposalList: React.FC<ProposalListProps> = React.memo(({ proposalIds, proposalContents }) => {
  const [proposals, setProposals] = useState<Proposal[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadProposals = async () => {
    try {
      setLoading(true);
      setError('');

      const proposalPromises = proposalIds.map(id => getProposal(id));
      const loadedProposals = await Promise.all(proposalPromises);

      setProposals(loadedProposals);
    } catch (err: any) {
      setError('Failed to load proposals');
      console.error('Error loading proposals:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (proposalIds.length > 0) {
      loadProposals();
      
      // Set up polling for real-time updates
      const pollInterval = setInterval(() => {
        loadProposals();
      }, 30000); // Poll every 30 seconds
      
      return () => clearInterval(pollInterval);
    } else {
      setLoading(false);
    }
  }, [proposalIds]);

  const handleVoteUpdate = () => {
    // Reload proposals after voting
    loadProposals();
  };

  if (loading) {
    return (
      <div style={{
        textAlign: 'center',
        padding: '40px',
        color: '#666',
      }}>
        <div style={{
          fontSize: '24px',
          marginBottom: '16px',
        }}>
          🌀
        </div>
        Loading proposals...
      </div>
    );
  }

  if (error) {
    return (
      <div style={{
        backgroundColor: '#f8d7da',
        border: '1px solid #f5c6cb',
        borderRadius: '8px',
        padding: '20px',
        textAlign: 'center',
        color: '#721c24',
      }}>
        <div style={{ fontSize: '20px', marginBottom: '8px' }}>⚠️</div>
        {error}
        <br />
        <button
          onClick={loadProposals}
          style={{
            marginTop: '12px',
            padding: '8px 16px',
            backgroundColor: '#dc3545',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer',
          }}
        >
          Retry
        </button>
      </div>
    );
  }

  if (proposals.length === 0) {
    return (
      <div style={{
        textAlign: 'center',
        padding: '40px',
        color: '#666',
      }}>
        <div style={{
          fontSize: '48px',
          marginBottom: '16px',
        }}>
          📝
        </div>
        <h3>No proposals yet</h3>
        <p>Be the first to submit a proposal to the Vortex-369 DAO!</p>
      </div>
    );
  }

  return (
    <div>
      <div style={{
        marginBottom: '20px',
        textAlign: 'center',
      }}>
        <h2 style={{
          color: '#369',
          margin: '0 0 8px 0',
        }}>
          🗳️ Active Proposals
        </h2>
        <p style={{
          color: '#666',
          margin: '0',
          fontSize: '16px',
        }}>
          Vote on proposals to shape the future of the Vortex-369 DAO
        </p>
      </div>

      <div>
        {proposals.map((proposal) => (
          <ProposalCard
            key={proposal.id}
            proposal={proposal}
            content={proposalContents[proposal.id]}
            onVote={handleVoteUpdate}
          />
        ))}
      </div>
    </div>
  );
});
