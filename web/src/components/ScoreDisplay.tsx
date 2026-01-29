import React, { useMemo } from 'react';

interface ScoreDisplayProps {
  score: number | null;
  explanation: string;
}

export const ScoreDisplay: React.FC<ScoreDisplayProps> = React.memo(({ score, explanation }) => {
  const scoreData = useMemo(() => {
    if (score === null) return null;

    const getScoreColor = (score: number) => {
      if (score >= 80) return '#28a745'; // High resonance - green
      if (score >= 60) return '#ffc107'; // Medium resonance - yellow
      if (score >= 40) return '#fd7e14'; // Low-medium resonance - orange
      return '#dc3545'; // Low resonance - red
    };

    const getScoreLabel = (score: number) => {
      if (score >= 80) return 'High Resonance 🌟';
      if (score >= 60) return 'Medium Resonance ✨';
      if (score >= 40) return 'Low-Medium Resonance ⚡';
      return 'Low Resonance 📉';
    };

    return {
      color: getScoreColor(score),
      label: getScoreLabel(score),
    };
  }, [score]);

  if (!scoreData) return null;

  return (
    <div style={{
      backgroundColor: '#f8f9fa',
      border: `2px solid ${scoreData.color}`,
      borderRadius: '12px',
      padding: '20px',
      marginTop: '20px',
    }}>
      <h2 style={{
        color: scoreData.color,
        marginTop: 0,
        fontSize: '24px',
      }}>
        Resonance Score: {score}/100
      </h2>

      <div style={{
        fontSize: '18px',
        fontWeight: 'bold',
        color: scoreData.color,
        marginBottom: '12px',
      }}>
        {scoreData.label}
      </div>

      <div style={{
        backgroundColor: 'white',
        padding: '12px',
        borderRadius: '8px',
        border: '1px solid #dee2e6',
      }}>
        <strong>Analysis:</strong>
        <p style={{ margin: '8px 0 0 0', lineHeight: '1.5' }}>
          {explanation}
        </p>
      </div>

      <div style={{
        marginTop: '16px',
        fontSize: '14px',
        color: '#6c757d',
        fontStyle: 'italic',
      }}>
        🌀 Based on 369/432 Hz frequency alignment and Vortex energy patterns
      </div>
    </div>
  );
});
