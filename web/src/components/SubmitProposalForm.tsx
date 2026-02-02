import React, { useState } from 'react';
import { submitProposal } from '../utils/contracts';
import { useWeb3 } from '../hooks/useWeb3';

interface SubmitProposalFormProps {
  onProposalSubmitted: (proposalId: string, title: string, description: string) => void;
}

export const SubmitProposalForm: React.FC<SubmitProposalFormProps> = React.memo(({ onProposalSubmitted }) => {
  const { isConnected } = useWeb3();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!isConnected) {
      setError('Please connect your wallet first');
      return;
    }

    if (!title.trim() || !description.trim()) {
      setError('Please fill in both title and description');
      return;
    }

    setSubmitting(true);
    setError('');
    setSuccess('');

    try {
      // Combine title and description for the proposal text
      const proposalText = `${title.trim()}\n\n${description.trim()}`;

      const proposalId = await submitProposal(proposalText);

      // Score the proposal and submit to oracle
      try {
        const scoreResponse = await fetch('/score', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            text: proposalText,
            proposal_id: proposalId,
          }),
        });

        if (scoreResponse.ok) {
          const scoreData = await scoreResponse.json();
          console.log('Proposal scored:', scoreData);
        } else {
          console.warn('Scoring failed:', await scoreResponse.text());
        }
      } catch (scoreError) {
        console.warn('Scoring API call failed:', scoreError);
      }

      setSuccess(`Proposal submitted successfully! ID: ${proposalId}`);
      setTitle('');
      setDescription('');

      // Notify parent component with the proposal ID and content
      onProposalSubmitted(proposalId, title.trim(), description.trim());

      // Clear success message after 5 seconds
      setTimeout(() => setSuccess(''), 5000);
    } catch (err: any) {
      setError(err.message || 'Failed to submit proposal');
    } finally {
      setSubmitting(false);
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
        <div style={{ fontSize: '24px', marginBottom: '8px' }}>📝</div>
        <div>Connect wallet to submit proposals</div>
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
        📝 Submit New Proposal
      </h3>

      <form onSubmit={handleSubmit}>
        {/* Title */}
        <div style={{ marginBottom: '16px' }}>
          <label htmlFor="title" style={{
            display: 'block',
            marginBottom: '8px',
            fontWeight: 'bold',
            color: '#369',
          }}>
            Proposal Title:
          </label>
          <input
            id="title"
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="Enter a clear, concise title..."
            maxLength={100}
            style={{
              width: '100%',
              padding: '12px',
              border: '2px solid #369',
              borderRadius: '8px',
              fontSize: '16px',
              fontFamily: 'inherit',
              boxSizing: 'border-box',
            }}
            disabled={submitting}
          />
          <div style={{
            fontSize: '12px',
            color: '#666',
            marginTop: '4px',
          }}>
            {title.length}/100 characters
          </div>
        </div>

        {/* Description */}
        <div style={{ marginBottom: '16px' }}>
          <label htmlFor="description" style={{
            display: 'block',
            marginBottom: '8px',
            fontWeight: 'bold',
            color: '#369',
          }}>
            Detailed Description:
          </label>
          <textarea
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Describe your proposal in detail. Explain the problem, your solution, and expected impact..."
            rows={6}
            maxLength={2000}
            style={{
              width: '100%',
              padding: '12px',
              border: '2px solid #369',
              borderRadius: '8px',
              fontSize: '16px',
              fontFamily: 'inherit',
              resize: 'vertical',
              boxSizing: 'border-box',
            }}
            disabled={submitting}
          />
          <div style={{
            fontSize: '12px',
            color: '#666',
            marginTop: '4px',
          }}>
            {description.length}/2000 characters
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

        {/* Submit Button */}
        <div style={{ textAlign: 'center' }}>
          <button
            type="submit"
            disabled={submitting || !title.trim() || !description.trim()}
            style={{
              backgroundColor: submitting ? '#666' : '#369',
              color: 'white',
              border: 'none',
              padding: '14px 28px',
              borderRadius: '8px',
              fontSize: '16px',
              fontWeight: 'bold',
              cursor: submitting ? 'not-allowed' : 'pointer',
              transition: 'background-color 0.2s',
            }}
          >
            {submitting ? '🚀 Submitting...' : '📤 Submit Proposal'}
          </button>
        </div>

        <div style={{
          marginTop: '16px',
          fontSize: '12px',
          color: '#666',
          textAlign: 'center',
          fontStyle: 'italic',
        }}>
          Proposals will be scored for resonance and may require community voting
        </div>
      </form>
    </div>
  );
});
