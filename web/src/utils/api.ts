import { ScoreResponse } from './types';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080';

export const scoreProposal = async (text: string): Promise<ScoreResponse> => {
  const response = await fetch(`${API_BASE_URL}/score`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ text }),
  });

  if (!response.ok) {
    throw new Error('Failed to score proposal');
  }

  return response.json();
};

export const checkHealth = async (): Promise<{ status: string; version: string }> => {
  const response = await fetch(`${API_BASE_URL}/health`);
  return response.json();
};
