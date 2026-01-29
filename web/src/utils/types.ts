export interface ScoreResponse {
  score: number;
  explanation: string;
}

export interface ProposalData {
  text: string;
  score: number | null;
  explanation: string;
}
