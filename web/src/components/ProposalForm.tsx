import React, { useState } from 'react';

interface ProposalFormProps {
  onSubmit: (text: string) => void;
  loading: boolean;
}

export const ProposalForm: React.FC<ProposalFormProps> = ({ onSubmit, loading }) => {
  const [text, setText] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(text);
  };

  return (
    <form onSubmit={handleSubmit} style={{ marginBottom: '20px' }}>
      <div style={{ marginBottom: '12px' }}>
        <label htmlFor="proposal" style={{ display: 'block', marginBottom: '8px', fontWeight: 'bold' }}>
          Enter your DAO proposal:
        </label>
        <textarea
          id="proposal"
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="Describe your proposal for the Vortex-369 DAO..."
          rows={4}
          style={{
            width: '100%',
            padding: '12px',
            border: '2px solid #369',
            borderRadius: '8px',
            fontSize: '16px',
            fontFamily: 'inherit',
            resize: 'vertical',
          }}
          disabled={loading}
        />
      </div>

      <button
        type="submit"
        disabled={loading || !text.trim()}
        style={{
          backgroundColor: loading ? '#666' : '#369',
          color: 'white',
          border: 'none',
          padding: '12px 24px',
          borderRadius: '8px',
          fontSize: '16px',
          fontWeight: 'bold',
          cursor: loading ? 'not-allowed' : 'pointer',
          transition: 'background-color 0.2s',
        }}
      >
        {loading ? '🌀 Calculating Resonance...' : '🎯 Calculate Resonance Score'}
      </button>
    </form>
  );
};
