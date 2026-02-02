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

const PELLION_SHIELD_ABI = [
  "function verifySecret(uint256[2] calldata _pA, uint256[2][2] calldata _pB, uint256[2] calldata _pC, uint256[3] calldata _pubSignals) external view returns (bool)",
];

// Contract instances
let vortexDaoContract: ethers.Contract | null = null;
let nullOfficeContract: ethers.Contract | null = null;
let pellionShieldContract: ethers.Contract | null = null;

// Initialize contracts with provider/signer
export const initializeContracts = (signer: ethers.Signer) => {
  vortexDaoContract = new ethers.Contract(CONTRACT_ADDRESSES.VORTEX_DAO, VORTEX_DAO_ABI, signer);
  nullOfficeContract = new ethers.Contract(CONTRACT_ADDRESSES.NULL_OFFICE, NULL_OFFICE_ABI, signer);
  pellionShieldContract = new ethers.Contract(CONTRACT_ADDRESSES.PELLION_SHIELD || CONTRACT_ADDRESSES.VORTEX_DAO, PELLION_SHIELD_ABI, signer); // Assuming same address or add to addresses
};

// Proposal types
export interface Proposal {
  id: string;
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
export const submitProposal = async (text: string): Promise<string> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  // Generate a unique hash for the proposal
  const proposalHash = ethers.keccak256(ethers.toUtf8Bytes(text));

  const tx = await vortexDaoContract.submitAction(proposalHash, 0, ethers.keccak256(ethers.toUtf8Bytes('vector')));
  const receipt = await tx.wait();

  if (!receipt) {
    throw new Error('Transaction failed - no receipt received');
  }

  // For now, return the actionHash as string since event parsing is unreliable on testnet
  // In production, we would parse the event to get the actual proposal ID
  return proposalHash; // Return actionHash as proposal ID
};

export const getProposal = async (proposalId: string): Promise<Proposal> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  // Use the proposalId as the actionHash directly since it's now a string
  const actionHash = proposalId;

  try {
    const action = await vortexDaoContract.getAction(actionHash);

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

export const voteOnProposal = async (_proposalId: string, _support: boolean): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  // This function might not exist in the contract, as the ABI doesn't have vote
  // For now, throw error or implement if available
  throw new Error('Voting not implemented in contract');
};

export const executeProposal = async (proposalId: string): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  // Use proposalId as actionHash
  const tx = await vortexDaoContract.executeAction(proposalId);
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

// Role management functions
export const grantScorerRole = async (address: string): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.grantScorerRole(address);
  await tx.wait();
};

export const revokeScorerRole = async (address: string): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.revokeScorerRole(address);
  await tx.wait();
};

export const grantAdminRole = async (address: string): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.grantAdminRole(address);
  await tx.wait();
};

export const revokeAdminRole = async (address: string): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.revokeAdminRole(address);
  await tx.wait();
};

export const grantEmergencyRole = async (address: string): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.grantEmergencyRole(address);
  await tx.wait();
};

export const revokeEmergencyRole = async (address: string): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.revokeEmergencyRole(address);
  await tx.wait();
};

export const getAdminConfiguration = async (): Promise<any> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  return await vortexDaoContract.getAdminConfiguration();
};

export const isMultiSigAdmin = async (address: string): Promise<boolean> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  return await vortexDaoContract.isMultiSigAdmin(address);
};

// ZK Proof verification
export const verifyZKProof = async (
  pA: [string, string],
  pB: [[string, string], [string, string]],
  pC: [string, string],
  pubSignals: [string, string, string]
): Promise<boolean> => {
  if (!pellionShieldContract) throw new Error('Contracts not initialized');

  try {
    const result = await pellionShieldContract.verifySecret(
      pA.map(x => ethers.toBigInt(x)),
      pB.map(row => row.map(x => ethers.toBigInt(x))),
      pC.map(x => ethers.toBigInt(x)),
      pubSignals.map(x => ethers.toBigInt(x))
    );
    return result;
  } catch (error) {
    console.error('ZK proof verification failed:', error);
    return false;
  }
};

// Timelock and Multi-sig functions
export const setTimelock = async (delay: number): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.setTimelock(delay);
  await tx.wait();
};

export const executeTimelockOperation = async (
  target: string,
  value: string,
  data: string,
  predecessor: string,
  salt: string
): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.executeTimelockOperation(target, value, data, predecessor, salt);
  await tx.wait();
};

export const scheduleGrantAdminRole = async (address: string): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.scheduleGrantAdminRole(address);
  await tx.wait();
};

export const transferAdminToSafe = async (): Promise<void> => {
  if (!vortexDaoContract) throw new Error('Contracts not initialized');

  const tx = await vortexDaoContract.transferAdminToSafe();
  await tx.wait();
};
