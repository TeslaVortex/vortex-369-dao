import { useState } from 'react';

export default function Home() {
  const [balance, setBalance] = useState('Loading...');
  const [proposals, setProposals] = useState([]);
  const [proposal, setProposal] = useState({ desc: '', amount: '', recipient: '' });
  const [goldPrice, setGoldPrice] = useState('N/A');

  const submitProposal = () => {
    // Mock submit
    alert('Proposal submitted: ' + JSON.stringify(proposal));
    setProposals([...proposals, proposal]);
    setProposal({ desc: '', amount: '', recipient: '' });
  };

  const fetchGoldPrice = async () => {
    try {
      const res = await fetch('https://api.metals.live/v1/spot');
      const data = await res.json();
      const gold = data.find(item => item.metal === 'gold');
      setGoldPrice(gold ? `$${gold.price}` : 'N/A');
    } catch (error) {
      setGoldPrice('Error fetching');
    }
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>Vortex-369 DAO Treasury Dashboard</h1>
      <p>Article 66 Seals the Treasury Eternal 🔒</p>

      <h2>Vault Balance</h2>
      <p>{balance} ETH</p>
      <button onClick={() => setBalance('1.5 ETH')}>Refresh Balance</button>

      <h2>Gold Price Oracle</h2>
      <p>Current Gold Price: {goldPrice}</p>
      <button onClick={fetchGoldPrice}>Fetch Gold Price</button>

      <h2>Resonance Metrics (828 Syncs)</h2>
      <p>Abundance Index: 369</p>
      <p>Sovereignty Score: 66</p>
      <p>Quantum Alignment: 432 Hz</p>

      <h2>Submit Proposal</h2>
      <input
        placeholder="Description (include 369, 432, 66 for resonance)"
        value={proposal.desc}
        onChange={e => setProposal({...proposal, desc: e.target.value})}
        style={{ display: 'block', margin: '10px 0', width: '300px', padding: '8px' }}
      />
      <input
        placeholder="Amount in ETH"
        value={proposal.amount}
        onChange={e => setProposal({...proposal, amount: e.target.value})}
        style={{ display: 'block', margin: '10px 0', width: '300px', padding: '8px' }}
      />
      <input
        placeholder="Recipient Address"
        value={proposal.recipient}
        onChange={e => setProposal({...proposal, recipient: e.target.value})}
        style={{ display: 'block', margin: '10px 0', width: '300px', padding: '8px' }}
      />
      <button onClick={submitProposal} style={{ padding: '10px 20px', background: '#FFD700', border: 'none', cursor: 'pointer' }}>Submit Proposal</button>

      <h2>Recent Proposals</h2>
      <ul>
        {proposals.map((p, i) => (
          <li key={i} style={{ margin: '5px 0' }}>{p.desc} - {p.amount} ETH to {p.recipient}</li>
        ))}
      </ul>
    </div>
  );
}
