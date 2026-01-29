import { useState, useEffect } from 'react';
import { useProposalScoring } from './hooks/useProposalScoring';
import { useWeb3 } from './hooks/useWeb3';
import { initializeContracts } from './utils/contracts';
import { ProposalForm } from './components/ProposalForm';
import { ScoreDisplay } from './components/ScoreDisplay';
import { ErrorMessage } from './components/ErrorMessage';
import { ConnectWallet } from './components/ConnectWallet';
import { TreasuryDisplay } from './components/TreasuryDisplay';
import { SubmitProposalForm } from './components/SubmitProposalForm';
import { ProposalList } from './components/ProposalList';

function App() {
  const [proposal, setProposal] = useState('');
  const [proposalIds, setProposalIds] = useState<number[]>([]);
  const { score, explanation, loading, error, scoreProposalText } = useProposalScoring();
  const { isConnected, signer } = useWeb3();

  // Initialize contracts when Web3 is connected
  useEffect(() => {
    if (isConnected && signer) {
      initializeContracts(signer);
      // In a real app, you'd load existing proposal IDs here
      // For now, we'll use mock data
      setProposalIds([1, 2, 3]); // Mock proposal IDs
    }
  }, [isConnected, signer]);

  const handleSubmit = async () => {
    await scoreProposalText(proposal);
  };

  const handleProposalSubmitted = () => {
    // Refresh proposal list after submission
    // In a real app, you'd reload proposal IDs from the contract
    console.log('Proposal submitted, refreshing list...');
  };

  return (
    <div style={{
      maxWidth: '1200px',
      margin: '0 auto',
      padding: '20px',
      fontFamily: 'Arial, sans-serif',
      backgroundColor: '#ffffff',
      minHeight: '100vh',
    }}>
      <header style={{
        textAlign: 'center',
        marginBottom: '40px',
        borderBottom: '3px solid #369',
        paddingBottom: '20px',
      }}>
        <h1 style={{
          color: '#369',
          fontSize: '36px',
          margin: '0 0 10px 0',
          textShadow: '2px 2px 4px rgba(51, 105, 153, 0.3)',
        }}>
          🌀 Vortex-369 DAO
        </h1>
        <p style={{
          color: '#666',
          fontSize: '18px',
          margin: '0',
          fontStyle: 'italic',
        }}>
          Decentralized Governance Through Harmonic Resonance
        </p>
      </header>

      <main>
        <ConnectWallet />

        {isConnected && (
          <>
            <TreasuryDisplay />
            <SubmitProposalForm onProposalSubmitted={handleProposalSubmitted} />
            <ProposalList proposalIds={proposalIds} />

            {/* Keep the resonance scoring for comparison */}
            <div style={{
              marginTop: '40px',
              borderTop: '2px solid #eee',
              paddingTop: '40px',
            }}>
              <h2 style={{
                color: '#369',
                textAlign: 'center',
                marginBottom: '20px',
              }}>
                🎯 Resonance Scoring (Development Tool)
              </h2>

              <ProposalForm
                onSubmit={handleSubmit}
                loading={loading}
              />

              <ErrorMessage message={error} />

              <ScoreDisplay
                score={score}
                explanation={explanation}
              />
            </div>
          </>
        )}
      </main>

      <footer style={{
        marginTop: '40px',
        textAlign: 'center',
        color: '#999',
        fontSize: '14px',
        borderTop: '1px solid #eee',
        paddingTop: '20px',
      }}>
        <p>
          🌟 Built with Vortex Energy • 369 Eternal • 432 Hz Forever • Web3 Enabled 🌟
        </p>
        <p>
          Powered by AI resonance analysis for decentralized governance
        </p>
      </footer>
    </div>
  );
}

export default App;
      <p>Enter your proposal to get its resonance score based on 369/432 Hz frequencies.</p>

      <div style={{ marginBottom: '20px' }}>
        <label htmlFor="proposal" style={{ display: 'block', marginBottom: '8px', fontWeight: 'bold' }}>
          Proposal Text:
        </label>
        <textarea
          id="proposal"
          value={proposal}
          onChange={(e) => setProposal(e.target.value)}
          placeholder="Enter your proposal here..."
          style={{
            width: '100%',
            height: '150px',
            padding: '10px',
            border: '1px solid #ccc',
            borderRadius: '4px',
            fontSize: '16px',
            resize: 'vertical'
          }}
        />
      </div>

      <button
        onClick={handleScore}
        disabled={loading}
        style={{
          backgroundColor: loading ? '#ccc' : '#007bff',
          color: 'white',
          border: 'none',
          padding: '10px 20px',
          borderRadius: '4px',
          cursor: loading ? 'not-allowed' : 'pointer',
          fontSize: '16px'
        }}
      >
        {loading ? 'Scoring...' : 'Score Proposal'}
      </button>

      {error && (
        <div style={{ marginTop: '20px', color: 'red', padding: '10px', border: '1px solid red', borderRadius: '4px' }}>
          {error}
        </div>
      )}

      {score !== null && (
        <div style={{ marginTop: '20px', padding: '20px', border: '1px solid #28a745', borderRadius: '4px', backgroundColor: '#f8fff9' }}>
          <h2>Resonance Score: {score}/100</h2>
          <p><strong>Explanation:</strong> {explanation}</p>

          <div style={{ marginTop: '10px' }}>
            {score > 66 && <span style={{ color: '#28a745', fontWeight: 'bold' }}>🎉 High resonance! This proposal will auto-execute through 9 phases.</span>}
            {score >= 33 && score <= 66 && <span style={{ color: '#ffc107', fontWeight: 'bold' }}>🤔 Medium resonance. Community petition option available.</span>}
            {score < 33 && <span style={{ color: '#dc3545', fontWeight: 'bold' }}>🔥 Low resonance. Proposal will be declined.</span>}
          </div>
        </div>
      )}

      <div style={{ marginTop: '40px', padding: '20px', backgroundColor: '#f8f9fa', borderRadius: '4px' }}>
        <h3>Tips for High Resonance:</h3>
        <ul>
          <li>Use keywords like: vortex, harmony, arcturian, abundance, 369</li>
          <li>Include 432 Hz or 369 code references</li>
          <li>Write detailed, meaningful proposals</li>
        </ul>
      </div>
    </div>
  )
}

export default App
