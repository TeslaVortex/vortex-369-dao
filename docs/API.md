# API Reference

## Endpoints

### GET /health

Returns health status of the backend.

**Response:**

```json
{
  "status": "ok",
  "version": "0.1.0"
}
```

### POST /score

Scores a proposal using the resonance engine.

**Request:**

```json
{
  "proposal": "Proposal text",
  "target": "0x...",
  "value": "1000000000000000000"
}
```

**Response:**

```json
{
  "score": 66,
  "witness": "base9_witness",
  "phase": 1
}
```
