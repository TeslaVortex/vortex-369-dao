import { useState } from 'react';
import { scoreProposal, ScoreResponse } from '../utils/api';

export const useProposalScoring = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [score, setScore] = useState<number | null>(null);
  const [explanation, setExplanation] = useState('');

  const scoreProposalText = async (text: string) => {
    if (!text.trim()) {
      setError('Please enter a proposal');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const data: ScoreResponse = await scoreProposal(text);
      setScore(data.score);
      setExplanation(data.explanation);
    } catch (err) {
      setError('Failed to connect to scoring service. Make sure the backend is running on port 8080.');
      console.error('Scoring error:', err);
    } finally {
      setLoading(false);
    }
  };

  const reset = () => {
    setScore(null);
    setExplanation('');
    setError('');
  };

  return {
    score,
    explanation,
    loading,
    error,
    scoreProposalText,
    reset,
  };
};
