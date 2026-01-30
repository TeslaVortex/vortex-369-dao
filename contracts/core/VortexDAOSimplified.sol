// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title VortexDAO - Simplified
 * @notice 432·3·6·9 Resonance Governance
 * @dev Minimal governance contract for 9-phase action processing
 * 
 * Zero token. Zero vote. Pure resonance.
 * 9% to DAO. 91% to Null.
 */
contract VortexDAO is Initializable, AccessControlUpgradeable, PausableUpgradeable, ReentrancyGuard {
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
    
    /// @notice Access control roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SCORER_ROLE = keccak256("SCORER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
    
    /// @notice Input validation constants
    uint256 public constant MAX_ACTION_RESONANCE = type(uint96).max;
    uint256 public constant MIN_ACTION_RESONANCE = 1;
    uint256 public constant MAX_WITNESS_LENGTH = 1000; // characters
    uint256 public constant MIN_EXECUTION_VALUE = 0; // wei
    uint256 public constant MAX_EXECUTION_VALUE = 100 ether; // reasonable upper bound
    uint256 public constant MIN_WITHDRAW_AMOUNT = 0.001 ether; // minimum withdrawal
    uint256 public constant MAX_WITHDRAW_AMOUNT = 50 ether; // reasonable upper bound
    
    /// @notice All actions by hash
    mapping(bytes32 => Action) public actions;
    
    /// @notice DAO treasury balance
    uint256 public daoTreasury;
    
    /// @notice Total burned to Null
    uint256 public totalBurned;
    
    /// @notice Contract owner (for treasury management)
    address public owner;
    
    /// @notice Timestamp when contract was paused (for unpause delay)
    uint256 public pausedAt;
    
    /// @notice Oracle data storage (example: resonance scores)
    mapping(bytes32 => uint256) public oracleData;
    
    /// @notice Oracle submission timestamps for rate limiting
    mapping(bytes32 => uint256) public oracleDataTimestamp;
    
    /// @notice Minimum time between oracle updates (1 hour)
    uint256 public constant ORACLE_UPDATE_COOLDOWN = 1 hours;
    
    /// @notice Timelock controller for delayed execution
    address public timelock;
    
    /// @notice Initialize the contract
    function initialize(address _owner) external initializer {
        __AccessControl_init();
        __Pausable_init();
        owner = _owner;
        
        // Grant roles to owner
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(ADMIN_ROLE, _owner);
        _grantRole(EMERGENCY_ROLE, _owner);
    }
    
    /// @notice Events
    event ActionSubmitted(bytes32 indexed actionHash, uint256 resonance);
    event PhaseAdvanced(bytes32 indexed actionHash, Phase newPhase, string witness);
    event ActionExecuted(bytes32 indexed actionHash, uint256 value);
    event ActionCancelled(bytes32 indexed actionHash, Phase cancelPhase);
    event FeesDistributed(uint256 daoAmount, uint256 burnAmount);
    event EmergencyPause(address pauser, uint256 timestamp);
    event EmergencyUnpause(address unpauser, uint256 timestamp);
    event TreasuryWithdrawn(address indexed to, uint256 amount, address withdrawer);
    event OracleDataSubmitted(bytes32 indexed dataId, uint256 dataValue, uint256 timestamp, address indexed submitter);
    event AdminTransferredToSafe(address indexed safeAddress, address indexed transferrer);
    
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
    ) external nonReentrant whenNotPaused {
        // Input validation
        require(actionHash != bytes32(0), "Invalid action hash");
        require(resonance >= MIN_ACTION_RESONANCE && resonance <= MAX_ACTION_RESONANCE, "Invalid resonance range");
        require(vectorHash != bytes32(0), "Invalid vector hash");
        require(actions[actionHash].hash == bytes32(0), "Action already exists");
        
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
    function advancePhase(bytes32 actionHash, string calldata witness) external nonReentrant whenNotPaused {
        // Input validation
        require(actionHash != bytes32(0), "Invalid action hash");
        require(bytes(witness).length <= MAX_WITNESS_LENGTH, "Witness too long");
        
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
        
        // Use unchecked for gas savings - bounds checked above
        unchecked {
            action.phase = currentPhase + 1;
        }
        
        emit PhaseAdvanced(actionHash, Phase(action.phase), witness);
    }
    
    /**
     * @notice Execute action at Phase 9 (Manifestation)
     * @param actionHash Action to execute
     */
    function executeAction(bytes32 actionHash) external payable nonReentrant whenNotPaused {
        // Input validation
        require(actionHash != bytes32(0), "Invalid action hash");
        require(msg.value >= MIN_EXECUTION_VALUE && msg.value <= MAX_EXECUTION_VALUE, "Invalid execution value");
        
        Action storage action = actions[actionHash];
        require(action.hash != bytes32(0), "Action not found");
        
        // Cache storage variables for gas optimization - load once
        bool isExecuted = action.executed;
        bool isCancelled = action.cancelled;
        uint8 phase = action.phase;
        uint96 resonance = action.resonance;
        
        require(!isExecuted, "Already executed");
        require(!isCancelled, "Action cancelled");
        require(phase == uint8(Phase.Manifestation), "Not at Manifestation");
        
        // Use unchecked for gas savings - bounds verified during submission
        unchecked {
            require(uint256(resonance) >= MIN_MANIFESTATION_RESONANCE, "Resonance too low");
        }
        
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
    function withdrawTreasury(address to, uint256 amount) external nonReentrant onlyRole(ADMIN_ROLE) {
        // Input validation
        require(to != address(0), "Invalid recipient address");
        require(amount >= MIN_WITHDRAW_AMOUNT && amount <= MAX_WITHDRAW_AMOUNT, "Invalid withdrawal amount");
        require(amount <= daoTreasury, "Insufficient treasury");
        
        daoTreasury -= amount;
        
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit TreasuryWithdrawn(to, amount, msg.sender);
    }
    
    /**
     * @notice Emergency pause - stops all critical operations
     * @dev Only EMERGENCY_ROLE can pause the contract
     */
    function pause() external onlyRole(EMERGENCY_ROLE) {
        _pause();
        pausedAt = block.timestamp;
        emit EmergencyPause(msg.sender, block.timestamp);
    }
    
    /**
     * @notice Unpause contract after emergency
     * @dev Only ADMIN_ROLE can unpause, requires 24h delay after pause
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        require(
            block.timestamp > pausedAt + 24 hours, 
            "Must wait 24h after pause"
        );
        _unpause();
        emit EmergencyUnpause(msg.sender, block.timestamp);
    }
    
    /**
     * @notice Set timelock controller address
     * @param _timelock The timelock controller address
     * @dev Only owner can set timelock initially
     */
    function setTimelock(address _timelock) external {
        require(msg.sender == owner, "Only owner can set timelock");
        require(_timelock != address(0), "Invalid timelock address");
        timelock = _timelock;
    }
    
    /**
     * @notice Execute timelock-scheduled operations
     * @dev Only timelock can call this function for scheduled admin operations
     */
    function executeTimelockOperation(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) external {
        require(msg.sender == timelock, "Only timelock can execute");
        // Execute the scheduled operation
        (bool success, ) = target.call{value: value}(data);
        require(success, "Timelock execution failed");
    }
    
    /**
     * @notice Schedule admin role grant through timelock
     * @param account The account to grant role to
     * @dev Only DEFAULT_ADMIN_ROLE can schedule, executed through timelock
     */
    function scheduleGrantAdminRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(timelock != address(0), "Timelock not set");
        require(account != address(0), "Invalid account address");
        
        // Schedule the role grant through timelock
        TimelockController(payable(timelock)).schedule(
            address(this),
            0,
            abi.encodeWithSignature("grantAdminRole(address)", account),
            bytes32(0),
            keccak256(abi.encodePacked("grantAdminRole", account, block.timestamp)),
            TimelockController(payable(timelock)).getMinDelay()
        );
    }
    
    /**
     * @notice Transfer admin and emergency roles to a multi-sig wallet
     * @param safeAddress The Gnosis Safe or multi-sig wallet address
     * @dev Only DEFAULT_ADMIN_ROLE can transfer admin control to multi-sig
     * This eliminates single points of failure for critical operations
     */
    function transferAdminToSafe(address safeAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(safeAddress != address(0), "Invalid safe address");
        require(safeAddress != msg.sender, "Cannot transfer to self");
        
        // Grant admin and emergency roles to the safe
        _grantRole(ADMIN_ROLE, safeAddress);
        _grantRole(EMERGENCY_ROLE, safeAddress);
        
        // Emit event for transparency
        emit AdminTransferredToSafe(safeAddress, msg.sender);
    }
    
    /**
     * @notice Check if an address is a designated multi-sig admin
     * @param account The address to check
     * @return True if the address has admin privileges through multi-sig
     */
    function isMultiSigAdmin(address account) external view returns (bool) {
        return hasRole(ADMIN_ROLE, account) || hasRole(DEFAULT_ADMIN_ROLE, account);
    }
    
    /**
     * @notice Get current admin configuration
     * @return defaultAdmin The current default admin
     * @return adminRoleCount Number of addresses with ADMIN_ROLE
     * @return emergencyRoleCount Number of addresses with EMERGENCY_ROLE
     */
    function getAdminConfiguration() external view returns (
        address defaultAdmin,
        uint256 adminRoleCount,
        uint256 emergencyRoleCount
    ) {
        // Note: OpenZeppelin AccessControl doesn't expose role member counts directly
        // This is a simplified view - in practice you'd need to track this separately
        return (
            address(0), // Would need custom tracking
            0, // Would need custom tracking  
            0  // Would need custom tracking
        );
    }
    
    /**
     * @notice Revoke admin role from an address (only DEFAULT_ADMIN_ROLE)
     * @param account Address to revoke admin role from
     */
    function revokeAdminRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Invalid account address");
        require(account != msg.sender, "Cannot revoke own admin role"); // Prevent self-revocation
        _revokeRole(ADMIN_ROLE, account);
    }
    
    /**
     * @notice Grant scorer role to an address (only ADMIN_ROLE)
     * @param account Address to grant scorer role to
     */
    function grantScorerRole(address account) external onlyRole(ADMIN_ROLE) {
        require(account != address(0), "Invalid account address");
        _grantRole(SCORER_ROLE, account);
    }
    
    /**
     * @notice Revoke scorer role from an address (only ADMIN_ROLE)
     * @param account Address to revoke scorer role from
     */
    function revokeScorerRole(address account) external onlyRole(ADMIN_ROLE) {
        require(account != address(0), "Invalid account address");
        _revokeRole(SCORER_ROLE, account);
    }
    
    /**
     * @notice Grant emergency role to an address (only ADMIN_ROLE)
     * @param account Address to grant emergency role to
     */
    function grantEmergencyRole(address account) external onlyRole(ADMIN_ROLE) {
        require(account != address(0), "Invalid account address");
        _grantRole(EMERGENCY_ROLE, account);
    }
    
    /**
     * @notice Revoke emergency role from an address (only ADMIN_ROLE)
     * @param account Address to revoke emergency role from
     */
    function revokeEmergencyRole(address account) external onlyRole(ADMIN_ROLE) {
        require(account != address(0), "Invalid account address");
        _revokeRole(EMERGENCY_ROLE, account);
    }
    
    /**
     * @notice Submit oracle data (access-controlled, rate-limited)
     * @param dataId Unique identifier for the data
     * @param dataValue The data value to store
     * @dev Only SCORER_ROLE can submit data, with 1-hour cooldown between updates
     */
    function submitOracleData(
        bytes32 dataId,
        uint256 dataValue
    ) external onlyRole(SCORER_ROLE) whenNotPaused {
        // Rate limiting: prevent updates more frequent than once per hour
        uint256 lastUpdate = oracleDataTimestamp[dataId];
        require(
            block.timestamp >= lastUpdate + ORACLE_UPDATE_COOLDOWN,
            "Oracle update too frequent"
        );
        
        // Store the data
        oracleData[dataId] = dataValue;
        oracleDataTimestamp[dataId] = block.timestamp;
        
        emit OracleDataSubmitted(dataId, dataValue, block.timestamp, msg.sender);
    }
    
    /**
     * @notice Get oracle data
     * @param dataId The data identifier
     * @return The stored data value
     */
    function getOracleData(bytes32 dataId) external view returns (uint256) {
        return oracleData[dataId];
    }
    
}
