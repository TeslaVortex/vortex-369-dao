import { ethers } from 'ethers';
import { CONTRACT_ADDRESSES } from './web3';

// Import contract ABIs (you would generate these from the Solidity contracts)
const VORTEX_DAO_ABI = [
  // Add the actual ABI here - this is a placeholder
  "function submitProposal(string memory _text) external returns (uint256)",
  "function getProposal(uint256 _proposalId) external view returns (uint256 id, address proposer, string memory text, uint8 score, uint8 phase, uint256 timestamp, uint256 votesFor, uint256 votesAgainst)",
  "function vote(uint256 _proposalId, bool _support) external",
  "function executeProposal(uint256 _proposalId) external",
  // Add other functions as needed
];

const NULL_OFFICE_ABI = [
  "function totalBurned() external view returns (uint256)",
  "function burn() external payable",
];

// Contract instances
let vortexDaoContract: ethers.Contract | null = null;
let nullOfficeContract: ethers.Contract | null = null;

// Initialize contracts with provider/signer
export const initializeContracts = (signer: ethers.Signer) => {
  vortexDaoContract = new ethers.Contract(CONTRACT_ADDRESSES.VORTEX_DAO, VORTEX_DAO_ABI, signer);
  nullOfficeContract = new ethers.Contract(CONTRACT_ADDRESSES.NULL_OFFICE, NULL_OFFICE_ABI, signer);
};

// Proposal types
export interface Proposal {
  id: number;
  proposer: string;
  text: string;
  score: number;
  phase: number;
  timestamp: number;
  votesFor: number;
  votesAgainst: number;
  executed: boolean;
}

// DAO functions
export const submitProposal = async (text: string): Promise<number> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.submitProposal(text);
  const receipt = await tx.wait();
  return receipt.events[0].args.proposalId;
};

export const getProposal = async (proposalId: number): Promise<Proposal> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const proposal = await vortexDaoContract.getProposal(proposalId);
  return {
    id: proposal.id,
    proposer: proposal.proposer,
    text: proposal.text,
    score: proposal.score,
    phase: proposal.phase,
    timestamp: proposal.timestamp,
    votesFor: proposal.votesFor,
    votesAgainst: proposal.votesAgainst,
    executed: proposal.executed,
  };
};

export const voteOnProposal = async (proposalId: number, support: boolean): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.vote(proposalId, support);
  await tx.wait();
};

export const executeProposal = async (proposalId: number): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.executeProposal(proposalId);
  await tx.wait();
};

export const getTotalBurned = async (): Promise<string> => {
  if (!nullOfficeContract) throw new Error('Contracts not initialized');

  const total = await nullOfficeContract.totalBurned();
  return ethers.formatEther(total);
};

export const burnTokens = async (amount: string): Promise<void> => {
  if (!nullOfficeContract) throw new Error('Contracts not initialized');

  const tx = await nullOfficeContract.burn({ value: ethers.parseEther(amount) });
  await tx.wait();
};
