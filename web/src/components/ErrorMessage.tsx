import React from 'react';

interface ErrorMessageProps {
  message: string;
}

export const ErrorMessage: React.FC<ErrorMessageProps> = React.memo(({ message }) => {
  if (!message) return null;

  return (
    <div style={{
      color: '#dc3545',
      backgroundColor: '#f8d7da',
      border: '1px solid #f5c6cb',
      borderRadius: '4px',
      padding: '12px',
      margin: '10px 0',
    }}>
      ⚠️ {message}
    </div>
  );
});
