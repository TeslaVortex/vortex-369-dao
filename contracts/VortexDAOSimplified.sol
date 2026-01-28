// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title VortexDAO - Simplified
 * @notice 432·3·6·9 Resonance Governance
 * @dev Minimal governance contract for 9-phase action processing
 * 
 * Zero token. Zero vote. Pure resonance.
 * 9% to DAO. 91% to Null.
 */
contract VortexDAO {
    /// @notice The 9 phases of governance
    enum Phase {
        Silence,        // 0
        Proposal,       // 1
        Mirror,         // 2
        Vortex,         // 3
        Resolution,     // 4
        Fractal,        // 5
        Breath,         // 6 - Self-cancel checkpoint
        Witness,        // 7
        Return,         // 8
        Manifestation   // 9 - Final execution
    }
    
    /// @notice Action state
    struct Action {
        bytes32 hash;
        Phase phase;
        uint256 resonance;
        bytes32 vectorHash;
        uint256 timestamp;
        bool executed;
        bool cancelled;
    }
    
    /// @notice Protocol fee: 0.9% (90 basis points)
    uint256 public constant PROTOCOL_FEE_BPS = 90;
    
    /// @notice DAO share: 9% of fee (0.09% total)
    uint256 public constant DAO_SHARE_BPS = 9;
    
    /// @notice Null burn: 91% of fee (0.81% total)
    uint256 public constant NULL_BURN_BPS = 81;
    
    /// @notice Null Office address
    address public constant NULL_OFFICE = 0x0000000000000000000000000000000000000369;
    
    /// @notice Base frequency (432 Hz scaled)
    uint256 public constant BASE_FREQUENCY = 432000;
    
    /// @notice Minimum resonance for manifestation (90% of base)
    uint256 public constant MIN_MANIFESTATION_RESONANCE = 388800; // 432000 * 0.9
    
    /// @notice All actions by hash
    mapping(bytes32 => Action) public actions;
    
    /// @notice DAO treasury balance
    uint256 public daoTreasury;
    
    /// @notice Total burned to Null
    uint256 public totalBurned;
    
    /// @notice Contract owner (for treasury management)
    address public immutable owner;
    
    /// @notice Constructor sets owner
    constructor() {
        owner = msg.sender;
    }
    
    /// @notice Events
    event ActionSubmitted(bytes32 indexed actionHash, uint256 resonance);
    event PhaseAdvanced(bytes32 indexed actionHash, Phase newPhase, string witness);
    event ActionExecuted(bytes32 indexed actionHash, uint256 value);
    event ActionCancelled(bytes32 indexed actionHash, Phase cancelPhase);
    event FeesDistributed(uint256 daoAmount, uint256 burnAmount);
    
    /**
     * @notice Submit new action
     * @param actionHash Unique action identifier
     * @param resonance Action resonance (must align with 432 Hz)
     * @param vectorHash Hash of 9D vector embedding
     */
    function submitAction(
        bytes32 actionHash,
        uint256 resonance,
        bytes32 vectorHash
    ) external {
        require(actions[actionHash].hash == bytes32(0), "Action exists");
        require(resonance > 0, "Invalid resonance");
        
        actions[actionHash] = Action({
            hash: actionHash,
            phase: Phase.Silence,
            resonance: resonance,
            vectorHash: vectorHash,
            timestamp: block.timestamp,
            executed: false,
            cancelled: false
        });
        
        emit ActionSubmitted(actionHash, resonance);
    }
    
    /**
     * @notice Advance action to next phase
     * @param actionHash Action to advance
     * @param witness Witness record for Phase 7
     */
    function advancePhase(bytes32 actionHash, string calldata witness) external {
        Action storage action = actions[actionHash];
        require(action.hash != bytes32(0), "Action not found");
        require(!action.executed, "Already executed");
        require(!action.cancelled, "Already cancelled");
        
        // Phase 6 (Breath): Self-cancellation checkpoint
        if (action.phase == Phase.Breath) {
            if (action.resonance < (BASE_FREQUENCY * 369) / 1000) {
                action.cancelled = true;
                emit ActionCancelled(actionHash, Phase.Breath);
                return;
            }
        }
        
        // Advance phase
        require(uint8(action.phase) < 9, "Already at Manifestation");
        action.phase = Phase(uint8(action.phase) + 1);
        
        emit PhaseAdvanced(actionHash, action.phase, witness);
    }
    
    /**
     * @notice Execute action at Phase 9 (Manifestation)
     * @param actionHash Action to execute
     */
    function executeAction(bytes32 actionHash) external payable {
        Action storage action = actions[actionHash];
        require(action.hash != bytes32(0), "Action not found");
        require(!action.executed, "Already executed");
        require(!action.cancelled, "Action cancelled");
        require(action.phase == Phase.Manifestation, "Not at Manifestation");
        require(action.resonance >= MIN_MANIFESTATION_RESONANCE, "Resonance too low");
        
        action.executed = true;
        
        // Distribute fees if value sent
        if (msg.value > 0) {
            _distributeFees(msg.value);
        }
        
        emit ActionExecuted(actionHash, msg.value);
    }
    
    /**
     * @notice Distribute fees: 9% to DAO, 91% to Null
     * @param amount Total fee amount
     */
    function _distributeFees(uint256 amount) internal {
        uint256 daoAmount = (amount * DAO_SHARE_BPS) / 100;
        uint256 burnAmount = (amount * NULL_BURN_BPS) / 100;
        
        daoTreasury += daoAmount;
        totalBurned += burnAmount;
        
        // Send to Null Office
        (bool success, ) = NULL_OFFICE.call{value: burnAmount}("");
        require(success, "Burn failed");
        
        emit FeesDistributed(daoAmount, burnAmount);
    }
    
    /**
     * @notice Get action details
     */
    function getAction(bytes32 actionHash) external view returns (
        Phase phase,
        uint256 resonance,
        bytes32 vectorHash,
        uint256 timestamp,
        bool executed,
        bool cancelled
    ) {
        Action memory action = actions[actionHash];
        return (
            action.phase,
            action.resonance,
            action.vectorHash,
            action.timestamp,
            action.executed,
            action.cancelled
        );
    }
    
    /**
     * @notice Check if action can manifest
     */
    function canManifest(bytes32 actionHash) external view returns (bool) {
        Action memory action = actions[actionHash];
        return action.phase == Phase.Manifestation 
            && !action.executed 
            && !action.cancelled
            && action.resonance >= MIN_MANIFESTATION_RESONANCE;
    }
    
    /**
     * @notice Withdraw DAO treasury (owner only)
     * @dev Protected by owner access control
     */
    function withdrawTreasury(address to, uint256 amount) external {
        require(msg.sender == owner, "Not authorized");
        require(amount <= daoTreasury, "Insufficient treasury");
        daoTreasury -= amount;
        
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    /**
     * @notice Receive ETH
     */
    receive() external payable {
        _distributeFees(msg.value);
    }
}
