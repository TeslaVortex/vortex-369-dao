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
  const [proposalIds, setProposalIds] = useState<number[]>([]);
  const [submittedProposals, setSubmittedProposals] = useState<number[]>([]);
  const [proposalContents, setProposalContents] = useState<{[key: number]: {title: string, description: string}}>({});
  const { score, explanation, loading, error, scoreProposalText } = useProposalScoring();
  const { isConnected, signer } = useWeb3();

  // Load submitted proposals and contents from localStorage on mount
  useEffect(() => {
    const storedProposals = localStorage.getItem('vortex-dao-submitted-proposals');
    const storedContents = localStorage.getItem('vortex-dao-proposal-contents');
    
    if (storedProposals) {
      try {
        const parsed = JSON.parse(storedProposals);
        setSubmittedProposals(parsed);
      } catch (error) {
        console.warn('Failed to parse stored proposals:', error);
      }
    }
    
    if (storedContents) {
      try {
        const parsed = JSON.parse(storedContents);
        setProposalContents(parsed);
      } catch (error) {
        console.warn('Failed to parse stored contents:', error);
      }
    }
  }, []);

  // Save submitted proposals to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('vortex-dao-submitted-proposals', JSON.stringify(submittedProposals));
  }, [submittedProposals]);

  // Save proposal contents to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('vortex-dao-proposal-contents', JSON.stringify(proposalContents));
  }, [proposalContents]);

  // Initialize contracts when Web3 is connected
  useEffect(() => {
    if (isConnected && signer) {
      initializeContracts(signer);
      // Start with mock data plus any submitted proposals
      setProposalIds([1, 2, 3, ...submittedProposals]);
    }
  }, [isConnected, signer, submittedProposals]);

  const handleProposalSubmitted = (proposalId: number, title: string, description: string) => {
    // Add the new proposal ID to the list
    setSubmittedProposals(prev => [...prev, proposalId]);
    setProposalIds(prev => [...prev, proposalId]);
    
    // Store the proposal content
    setProposalContents(prev => ({
      ...prev,
      [proposalId]: { title, description }
    }));
    
    console.log('Proposal submitted with ID:', proposalId);
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
        borderBottom: '3px solid #FFD700',
        paddingBottom: '20px',
      }}>
        <h1 style={{
          color: '#FFD700',
          fontSize: '36px',
          margin: '0 0 10px 0',
          textShadow: '2px 2px 4px rgba(255, 215, 0, 0.3)',
        }}>
          ☀️♔ Vortex-369 DAO
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
            <ProposalList proposalIds={proposalIds} proposalContents={proposalContents} />

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
                onSubmit={async (text) => await scoreProposalText(text)}
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
