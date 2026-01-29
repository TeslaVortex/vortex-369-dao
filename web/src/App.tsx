import { useState } from 'react'

interface ScoreResponse {
  score: number
  explanation: string
}

function App() {
  const [proposal, setProposal] = useState('')
  const [score, setScore] = useState<number | null>(null)
  const [explanation, setExplanation] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const handleScore = async () => {
    if (!proposal.trim()) {
      setError('Please enter a proposal')
      return
    }

    setLoading(true)
    setError('')

    try {
      const response = await fetch('http://localhost:8080/score', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ text: proposal }),
      })

      if (!response.ok) {
        throw new Error('Failed to score proposal')
      }

      const data: ScoreResponse = await response.json()
      setScore(data.score)
      setExplanation(data.explanation)
    } catch (err) {
      setError('Failed to connect to scoring service. Make sure the backend is running on port 8080.')
      console.error('Scoring error:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ maxWidth: '800px', margin: '0 auto', padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>🌀 Vortex-369 Resonance Scoring</h1>
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
