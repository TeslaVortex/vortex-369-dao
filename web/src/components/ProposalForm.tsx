import React, { useState, useCallback } from 'react';

interface ProposalFormProps {
  onSubmit: (text: string) => void;
  loading: boolean;
}

export const ProposalForm: React.FC<ProposalFormProps> = React.memo(({ onSubmit, loading }) => {
  const [text, setText] = useState('');

  const handleSubmit = useCallback((e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(text);
  }, [onSubmit, text]);

  const handleTextChange = useCallback((e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setText(e.target.value);
  }, []);

  return (
    <form onSubmit={handleSubmit} style={{ marginBottom: '20px' }}>
      <div style={{ marginBottom: '12px' }}>
        <label htmlFor="proposal" style={{ display: 'block', marginBottom: '8px', fontWeight: 'bold' }}>
          Enter your proposal to score:
        </label>
        <textarea
          id="proposal"
          value={text}
          onChange={handleTextChange}
          placeholder="Describe your proposal..."
          rows={4}
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
        {loading ? ' Calculating...' : ' Calculate Resonance'}
      </button>
    </form>
  );
});
