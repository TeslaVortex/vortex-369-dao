import { useState } from 'react';

export default function Home() {
  const [balance, setBalance] = useState('Loading...');
  const [proposals, setProposals] = useState([]);
  const [proposal, setProposal] = useState({ desc: '', amount: '', recipient: '' });

  const submitProposal = () => {
    // Mock submit
    alert('Proposal submitted: ' + JSON.stringify(proposal));
    setProposals([...proposals, proposal]);
    setProposal({ desc: '', amount: '', recipient: '' });
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Vortex-369 DAO Treasury UI</h1>
      <p>Article 66 Seals the Treasury Eternal 🔒</p>
      <h2>Vault Balance</h2>
      <p>{balance} ETH</p>
      <button onClick={() => setBalance('1.5 ETH')}>Refresh Balance</button>

      <h2>Submit Proposal</h2>
      <input
        placeholder="Description (include 369, 432, 66 for resonance)"
        value={proposal.desc}
        onChange={e => setProposal({...proposal, desc: e.target.value})}
        style={{ display: 'block', margin: '10px 0', width: '300px' }}
      />
      <input
        placeholder="Amount in ETH"
        value={proposal.amount}
        onChange={e => setProposal({...proposal, amount: e.target.value})}
        style={{ display: 'block', margin: '10px 0', width: '300px' }}
      />
      <input
        placeholder="Recipient Address"
        value={proposal.recipient}
        onChange={e => setProposal({...proposal, recipient: e.target.value})}
        style={{ display: 'block', margin: '10px 0', width: '300px' }}
      />
      <button onClick={submitProposal}>Submit Proposal</button>

      <h2>Recent Proposals</h2>
      <ul>
        {proposals.map((p, i) => (
          <li key={i}>{p.desc} - {p.amount} ETH to {p.recipient}</li>
        ))}
      </ul>
    </div>
  );
}
