// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title VortexResolver
 * @notice 0x369...432 - The canonical resolver for synthetic events
 * @dev Bridges Macedon engine outputs to on-chain execution
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IVortexDAO {
    function proposeAction(
        uint8 actionType,
        address target,
        uint256 value,
        bytes calldata data
    ) external returns (bytes32);
    
    function advancePhase(bytes32 actionHash, string calldata witnessRecord) external;
}

contract VortexResolver is Ownable {
    using ECDSA for bytes32;
    
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════
    
    uint256 public constant BASE_FREQUENCY = 432;
    uint8 public constant TOTAL_PHASES = 9;
    
    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════
    
    address public vortexDAO;
    address public macedonOracle;       // Off-chain Macedon engine signer
    
    mapping(bytes32 => SyntheticEvent) public events;
    mapping(bytes32 => bool) public resolvedEvents;
    mapping(address => bool) public authorizedNodes;
    
    uint256 public totalEventsProcessed;
    uint256 public totalEventsResolved;
    
    // ═══════════════════════════════════════════════════════════════════════════
    // STRUCTS
    // ═══════════════════════════════════════════════════════════════════════════
    
    struct SyntheticEvent {
        bytes32 eventHash;
        uint8 eventType;
        uint8 phase;
        uint256 timestamp;
        uint256 value;
        address target;
        bytes payload;
        string base9Witness;
        bytes macedonSignature;
        bool resolved;
    }
    
    struct PhaseProof {
        bytes32 eventHash;
        uint8 fromPhase;
        uint8 toPhase;
        string witnessRecord;
        bytes signature;
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════
    
    event SyntheticEventReceived(bytes32 indexed eventHash, uint8 eventType, uint256 value);
    event EventPhaseAdvanced(bytes32 indexed eventHash, uint8 newPhase);
    event EventResolved(bytes32 indexed eventHash, bool executable, string witnessRecord);
    event NodeAuthorized(address indexed node);
    event NodeRevoked(address indexed node);
    
    // ═══════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════════════════════════════
    
    modifier onlyAuthorizedNode() {
        require(authorizedNodes[msg.sender], "Not authorized node");
        _;
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════
    
    constructor(address _vortexDAO, address _macedonOracle) Ownable() {
        vortexDAO = _vortexDAO;
        macedonOracle = _macedonOracle;
        authorizedNodes[msg.sender] = true;
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // CORE: RECEIVE SYNTHETIC EVENTS
    // ═══════════════════════════════════════════════════════════════════════════
    
    /**
     * @notice Receive a synthetic event from the Macedon engine
     * @dev Verifies signature from authorized Macedon oracle
     */
    function receiveSyntheticEvent(
        uint8 eventType,
        address target,
        uint256 value,
        bytes calldata payload,
        string calldata base9Witness,
        bytes calldata signature
    ) external onlyAuthorizedNode returns (bytes32 eventHash) {
        // Compute event hash
        eventHash = keccak256(abi.encodePacked(
            eventType,
            target,
            value,
            payload,
            base9Witness,
            block.timestamp
        ));
        
        // Verify Macedon signature
        bytes32 messageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            eventHash
        ));
        address signer = messageHash.recover(signature);
        require(signer == macedonOracle, "Invalid Macedon signature");
        
        // Store event
        events[eventHash] = SyntheticEvent({
            eventHash: eventHash,
            eventType: eventType,
            phase: 1,
            timestamp: block.timestamp,
            value: value,
            target: target,
            payload: payload,
            base9Witness: base9Witness,
            macedonSignature: signature,
            resolved: false
        });
        
        totalEventsProcessed++;
        
        emit SyntheticEventReceived(eventHash, eventType, value);
        return eventHash;
    }
    
    /**
     * @notice Submit phase proof from Macedon engine
     */
    function submitPhaseProof(PhaseProof calldata proof) external onlyAuthorizedNode {
        SyntheticEvent storage evt = events[proof.eventHash];
        require(evt.timestamp > 0, "Event not found");
        require(evt.phase == proof.fromPhase, "Phase mismatch");
        require(proof.toPhase == proof.fromPhase + 1, "Invalid phase transition");
        require(proof.toPhase <= TOTAL_PHASES, "Exceeds max phase");
        
        // Verify phase proof signature
        bytes32 proofHash = keccak256(abi.encodePacked(
            proof.eventHash,
            proof.fromPhase,
            proof.toPhase,
            proof.witnessRecord
        ));
        bytes32 messageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            proofHash
        ));
        address signer = messageHash.recover(proof.signature);
        require(signer == macedonOracle, "Invalid proof signature");
        
        // Advance phase
        evt.phase = proof.toPhase;
        
        // Update witness record if phase 7
        if (proof.toPhase == 7) {
            evt.base9Witness = proof.witnessRecord;
        }
        
        emit EventPhaseAdvanced(proof.eventHash, proof.toPhase);
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // RESOLUTION
    // ═══════════════════════════════════════════════════════════════════════════
    
    /**
     * @notice Resolve an event that has reached Phase 9
     * @return executable Whether the event survived and should execute
     */
    function resolveAction(
        bytes32 eventHash,
        uint8 phase
    ) external view returns (bool executable) {
        SyntheticEvent storage evt = events[eventHash];
        
        // Must be at requested phase
        if (evt.phase != phase) return false;
        
        // Must have reached manifestation (phase 9)
        if (evt.phase < TOTAL_PHASES) return false;
        
        // Must not already be resolved
        if (evt.resolved) return false;
        
        return true;
    }
    
    /**
     * @notice Execute resolution - push to DAO
     */
    function executeResolution(bytes32 eventHash) external onlyAuthorizedNode {
        SyntheticEvent storage evt = events[eventHash];
        require(evt.phase == TOTAL_PHASES, "Not at phase 9");
        require(!evt.resolved, "Already resolved");
        
        evt.resolved = true;
        resolvedEvents[eventHash] = true;
        totalEventsResolved++;
        
        // Push to DAO
        IVortexDAO(vortexDAO).proposeAction(
            evt.eventType,
            evt.target,
            evt.value,
            evt.payload
        );
        
        emit EventResolved(eventHash, true, evt.base9Witness);
    }
    
    /**
     * @notice Get witness record for an event
     */
    function getWitnessRecord(bytes32 eventHash) external view returns (string memory) {
        return events[eventHash].base9Witness;
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // NODE MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════
    
    function authorizeNode(address node) external onlyOwner {
        authorizedNodes[node] = true;
        emit NodeAuthorized(node);
    }
    
    function revokeNode(address node) external onlyOwner {
        authorizedNodes[node] = false;
        emit NodeRevoked(node);
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════
    
    function getEvent(bytes32 eventHash) external view returns (SyntheticEvent memory) {
        return events[eventHash];
    }
    
    function getStats() external view returns (
        uint256 processed,
        uint256 resolved
    ) {
        return (totalEventsProcessed, totalEventsResolved);
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════
    
    function setVortexDAO(address _vortexDAO) external onlyOwner {
        vortexDAO = _vortexDAO;
    }
    
    function setMacedonOracle(address _macedonOracle) external onlyOwner {
        macedonOracle = _macedonOracle;
    }
}
