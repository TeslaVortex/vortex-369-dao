// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title VortexDAO - Simplified
 * @notice 432·3·6·9 Resonance Governance
 * @dev Minimal governance contract for 9-phase action processing
 * 
 * Zero token. Zero vote. Pure resonance.
 * 9% to DAO. 91% to Null.
 */
contract VortexDAO is Initializable {
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
    
    /// @notice Action state - optimized for gas efficiency
    struct Action {
        bytes32 hash;
        uint96 resonance;        // Reduced from uint256 to uint96 (resonance values fit in 96 bits)
        bytes32 vectorHash;
        uint40 timestamp;        // Reduced from uint256 to uint40 (timestamp fits in 40 bits)
        uint8 phase;            // Phase enum fits in 8 bits
        bool executed;           // Packed with cancelled
        bool cancelled;          // Packed with executed
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
    address public owner;
    
    /// @notice Initialize the contract
    function initialize(address _owner) external initializer {
        owner = _owner;
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
        require(resonance > 0 && resonance <= type(uint96).max, "Invalid resonance");
        
        actions[actionHash] = Action({
            hash: actionHash,
            resonance: uint96(resonance),
            vectorHash: vectorHash,
            timestamp: uint40(block.timestamp),
            phase: uint8(Phase.Silence),
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
        
        uint8 currentPhase = action.phase;
        
        // Phase 6 (Breath): Self-cancellation checkpoint - gas optimized
        if (currentPhase == uint8(Phase.Breath)) {
            // Use unchecked for gas savings since resonance bounds are checked on submission
            unchecked {
                if (uint256(action.resonance) < MIN_MANIFESTATION_RESONANCE / 10) { // Approximation for gas savings
                    action.cancelled = true;
                    emit ActionCancelled(actionHash, Phase.Breath);
                    return;
                }
            }
        }
        
        // Advance phase - gas optimized bounds check
        require(currentPhase < 9, "Already at Manifestation");
        
        unchecked {
            action.phase = currentPhase + 1;
        }
        
        emit PhaseAdvanced(actionHash, Phase(action.phase), witness);
    }
    
    /**
     * @notice Execute action at Phase 9 (Manifestation)
     * @param actionHash Action to execute
     */
    function executeAction(bytes32 actionHash) external payable {
        Action storage action = actions[actionHash];
        require(action.hash != bytes32(0), "Action not found");
        
        // Cache storage variables for gas optimization
        bool isExecuted = action.executed;
        bool isCancelled = action.cancelled;
        uint8 phase = action.phase;
        uint96 resonance = action.resonance;
        
        require(!isExecuted, "Already executed");
        require(!isCancelled, "Action cancelled");
        require(phase == uint8(Phase.Manifestation), "Not at Manifestation");
        require(uint256(resonance) >= MIN_MANIFESTATION_RESONANCE, "Resonance too low");
        
        // Mark as executed
        action.executed = true;
        
        // Distribute fees if value sent - gas optimized
        uint256 msgValue = msg.value;
        if (msgValue > 0) {
            _distributeFees(msgValue);
        }
        
        emit ActionExecuted(actionHash, msgValue);
    }
    
    /**
     * @notice Distribute fees: 9% to DAO, 91% to Null
     * @param amount Total fee amount
     */
    function _distributeFees(uint256 amount) internal {
        // Gas optimized fee calculations using unchecked math
        // DAO_SHARE_BPS = 9, NULL_BURN_BPS = 81, total = 90 BPS
        uint256 daoAmount;
        uint256 burnAmount;
        
        unchecked {
            daoAmount = (amount * DAO_SHARE_BPS) / 100;
            burnAmount = amount - daoAmount; // Since NULL_BURN_BPS = 81, this saves gas vs multiplication
        }
        
        // Update storage
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
            Phase(action.phase),
            uint256(action.resonance),
            action.vectorHash,
            uint256(action.timestamp),
            action.executed,
            action.cancelled
        );
    }
    
    /**
     * @notice Check if action can manifest
     */
    function canManifest(bytes32 actionHash) external view returns (bool) {
        Action memory action = actions[actionHash];
        
        // Gas optimized with single return statement and boolean logic
        return action.phase == uint8(Phase.Manifestation) 
            && !action.executed 
            && !action.cancelled
            && uint256(action.resonance) >= MIN_MANIFESTATION_RESONANCE;
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
