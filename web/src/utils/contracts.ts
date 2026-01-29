import { ethers } from 'ethers';
import { CONTRACT_ADDRESSES } from './web3';

// Import contract ABIs (you would generate these from the Solidity contracts)
const VORTEX_DAO_ABI = [
  // Actual contract functions from VortexDAOSimplified.sol
  "function submitAction(bytes32 actionHash, uint256 resonance, bytes32 vectorHash) external",
  "function getAction(bytes32 actionHash) external view returns (uint8 phase, uint256 resonance, bytes32 vectorHash, uint256 timestamp, bool executed, bool cancelled)",
  "function advancePhase(bytes32 actionHash, string calldata witness) external",
  "function executeAction(bytes32 actionHash) external payable",
  "function canManifest(bytes32 actionHash) external view returns (bool)",
  "function withdrawTreasury(address to, uint256 amount) external",
  "function owner() external view returns (address)",
  "function daoTreasury() external view returns (uint256)",
  "function totalBurned() external view returns (uint256)",
  // Events
  "event ActionSubmitted(bytes32 indexed actionHash, uint256 resonance)",
  "event PhaseAdvanced(bytes32 indexed actionHash, uint8 newPhase, string witness)",
  "event ActionExecuted(bytes32 indexed actionHash, uint256 value)",
  "event ActionCancelled(bytes32 indexed actionHash, uint8 cancelPhase)",
  "event FeesDistributed(uint256 daoAmount, uint256 burnAmount)"
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

  // Generate a unique hash for the proposal
  const proposalHash = ethers.keccak256(ethers.toUtf8Bytes(text));

  const tx = await vortexDaoContract.submitAction(proposalHash, 432000, ethers.keccak256(ethers.toUtf8Bytes('vector')));
  const receipt = await tx.wait();

  if (!receipt) {
    throw new Error('Transaction failed - no receipt received');
  }

  // For now, return a simple ID since event parsing is unreliable on testnet
  // In production, we would parse the event to get the actual proposal ID
  return Date.now(); // Return timestamp as temporary ID
};

export const getProposal = async (proposalId: number): Promise<Proposal> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  // For now, generate hash from ID since contract uses hashes
  const proposalHash = ethers.keccak256(ethers.toUtf8Bytes(`proposal-${proposalId}`));

  try {
    const action = await vortexDaoContract.getAction(proposalHash);

    // Convert the returned data to our Proposal interface
    return {
      id: proposalId,
      proposer: '0x' + '0'.repeat(40), // Placeholder - contract doesn't return proposer
      text: `Proposal ${proposalId}`, // Placeholder - contract uses hash not text
      score: Number(action[1]), // resonance
      phase: Number(action[0]), // phase
      timestamp: Number(action[3]), // timestamp
      votesFor: 0, // Placeholder - contract doesn't track votes
      votesAgainst: 0, // Placeholder - contract doesn't track votes
      executed: action[4], // executed
    };
  } catch (error) {
    // If proposal doesn't exist, return a placeholder
    console.warn(`Proposal ${proposalId} not found, returning placeholder`);
    return {
      id: proposalId,
      proposer: '0x' + '0'.repeat(40),
      text: `Proposal ${proposalId} (Not Found)`,
      score: 0,
      phase: 0,
      timestamp: 0,
      votesFor: 0,
      votesAgainst: 0,
      executed: false,
    };
  }
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
