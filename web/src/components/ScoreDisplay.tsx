import React, { useMemo } from 'react';

interface ScoreDisplayProps {
  score: number | null;
  explanation: string;
}

export const ScoreDisplay: React.FC<ScoreDisplayProps> = React.memo(({ score, explanation }) => {
  const scoreData = useMemo(() => {
    if (score === null) return null;

    const getScoreColor = (score: number) => {
      if (score > 66) return '#FFD700'; // Vergina Sun ignition - gold
      if (score >= 60) return '#ffc107'; // Medium resonance - yellow
      if (score >= 40) return '#fd7e14'; // Low-medium resonance - orange
      return '#dc3545'; // Low resonance - red
    };

    const getScoreLabel = (score: number) => {
      if (score > 66) return 'Vergina Sun Ignition 💛🔥';
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

      {/* 16-Ray Vergina Sun Meter */}
      <div style={{ textAlign: 'center', margin: '16px 0' }}>
        <svg width="120" height="120" viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg">
          <circle cx="60" cy="60" r="10" fill={score > 66 ? "#FFD700" : "#ccc"} />
          {Array.from({ length: 16 }, (_, i) => {
            const angle = (i * 360) / 16;
            const rad = angle * (Math.PI / 180);
            const x1 = 60 + 15 * Math.cos(rad);
            const y1 = 60 + 15 * Math.sin(rad);
            const x2 = 60 + 35 * Math.cos(rad);
            const y2 = 60 + 35 * Math.sin(rad);
            const filled = score > 66 || i < Math.floor(score * 16 / 100);
            return (
              <line
                key={i}
                x1={x1}
                y1={y1}
                x2={x2}
                y2={y2}
                stroke={filled ? "#FFD700" : "#ddd"}
                strokeWidth="3"
              />
            );
          })}
        </svg>
      </div>

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
        ☀️ Based on 369/432 Hz frequency alignment and Vergina Sun energy patterns
      </div>
    </div>
  );
});
