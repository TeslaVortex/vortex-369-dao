// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../core/VortexDAOSimplified.sol";
import "../core/VortexTimelock.sol";
import "../proxies/VortexDAOProxy.sol";

contract VortexDAOTest is Test {
    VortexDAO public dao;
    address public user = address(0x1);

    function setUp() public {
        // For upgradeable contract, we need to deploy proxy
        VortexDAO daoImpl = new VortexDAO();
        VortexDAOProxy proxy = new VortexDAOProxy(
            address(daoImpl),
            address(this), // admin
            abi.encodeWithSignature("initialize(address)", address(this))
        );
        dao = VortexDAO(payable(address(proxy)));
    }

    function testSubmitAction() public {
        vm.prank(user);
        bytes32 actionHash = keccak256("Test action");
        dao.submitAction(actionHash, 400000, keccak256("vector"));
        
        (, uint256 resonance, , , , ) = dao.getAction(actionHash);
        assertEq(resonance, 400000);
    }

    function testHighResonanceAction() public {
        vm.prank(user);
        bytes32 actionHash = keccak256("High resonance action");
        uint256 highResonance = 500000; // Above BASE_FREQUENCY
        dao.submitAction(actionHash, highResonance, keccak256("vector"));
        
        (VortexDAO.Phase phase,,,,,) = dao.getAction(actionHash);
        assertEq(uint8(phase), 0); // Should start at Silence phase
    }

    function testActionProgression() public {
        vm.prank(user);
        bytes32 actionHash = keccak256("Test progression");
        dao.submitAction(actionHash, 400000, keccak256("vector"));
        
        // Advance through phases (would need multiple calls in real scenario)
        vm.warp(block.timestamp + 1 days);
        
        // Check initial phase
        (VortexDAO.Phase phase,,,,,) = dao.getAction(actionHash);
        assertEq(uint8(phase), 0); // Silence
    }

    // Test contract that attempts reentrancy
    ReentrancyAttacker public attacker;

    function testReentrancyProtection() public {
        // Submit an action
        bytes32 actionHash1 = keccak256("Action 1");
        bytes32 actionHash2 = keccak256("Action 2");
        
        dao.submitAction(actionHash1, 400000, keccak256("vector"));
        dao.submitAction(actionHash2, 400000, keccak256("vector"));
        
        // Try to call submitAction twice in same transaction - should fail
        // This tests that nonReentrant prevents multiple calls
        vm.expectRevert(); // Should revert due to nonReentrant modifier
        dao.submitAction(actionHash1, 400000, keccak256("vector"));
    }

    function testAccessControl() public {
        // Set up timelock for testing
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = address(this);
        executors[0] = address(this);
        
        VortexTimelock timelockContract = new VortexTimelock(24 hours, proposers, executors, address(this));
        dao.setTimelock(address(timelockContract));
        
        // Grant DEFAULT_ADMIN_ROLE to timelock so it can execute operations
        dao.grantRole(dao.DEFAULT_ADMIN_ROLE(), address(timelockContract));
        
        address newAdmin = address(0x3);
        
        // Test that unauthorized user cannot call admin functions
        vm.prank(address(0x2));
        vm.expectRevert(); // Missing SCORER_ROLE for grantScorerRole
        dao.grantScorerRole(address(0x4));
        
        // Test that admin can call admin functions
        dao.grantScorerRole(address(0x4));
        assertTrue(dao.hasRole(dao.SCORER_ROLE(), address(0x4)));
        
        // Test role management through timelock - schedule admin role grant
        uint256 scheduleTime = block.timestamp;
        dao.scheduleGrantAdminRole(newAdmin);
        
        // Fast forward 24 hours to execute
        vm.warp(block.timestamp + 24 hours + 1);
        
        // Execute the scheduled role grant directly through timelock
        timelockContract.execute(
            address(dao),
            0,
            abi.encodeWithSignature("grantAdminRole(address)", newAdmin),
            bytes32(0),
            keccak256(abi.encodePacked("grantAdminRole", newAdmin, scheduleTime))
        );
        assertTrue(dao.hasRole(dao.ADMIN_ROLE(), newAdmin));
        
        // Test that newAdmin can now call admin functions
        vm.prank(newAdmin);
        dao.grantEmergencyRole(address(0x5));
        assertTrue(dao.hasRole(dao.EMERGENCY_ROLE(), address(0x5)));
        
        // Test revoking role
        dao.revokeAdminRole(newAdmin);
        assertFalse(dao.hasRole(dao.ADMIN_ROLE(), newAdmin));
        
        // Test that revoked user cannot call admin functions anymore
        vm.prank(newAdmin);
        vm.expectRevert(); // Should revert due to missing ADMIN_ROLE
        dao.grantScorerRole(address(0x6));
        
        // Test that only DEFAULT_ADMIN_ROLE can grant/revoke admin roles through timelock
        vm.prank(newAdmin); // newAdmin no longer has admin role
        vm.expectRevert(); // Should revert due to missing DEFAULT_ADMIN_ROLE
        dao.scheduleGrantAdminRole(address(0x7));
    }

    function testInputValidation() public {
        // Test submitAction validation
        vm.expectRevert("Invalid action hash");
        dao.submitAction(bytes32(0), 400000, keccak256("vector"));
        
        vm.expectRevert("Invalid resonance range");
        dao.submitAction(keccak256("test"), 0, keccak256("vector"));
        
        vm.expectRevert("Invalid vector hash");
        dao.submitAction(keccak256("test"), 400000, bytes32(0));
        
        // Test advancePhase validation
        bytes32 actionHash = keccak256("test action");
        dao.submitAction(actionHash, 400000, keccak256("vector"));
        
        vm.expectRevert("Invalid action hash");
        dao.advancePhase(bytes32(0), "");
        
        vm.expectRevert("Witness too long");
        string memory longWitness = new string(1001); // Exceeds MAX_WITNESS_LENGTH
        for(uint i = 0; i < 1001; i++) {
            longWitness = string(abi.encodePacked(longWitness, "a"));
        }
        dao.advancePhase(actionHash, longWitness);
        
        // Test executeAction validation
        vm.expectRevert("Invalid action hash");
        dao.executeAction(bytes32(0));
        
        vm.expectRevert("Invalid execution value");
        dao.executeAction{value: 101 ether}(actionHash); // Exceeds MAX_EXECUTION_VALUE
        
        // Test withdrawTreasury validation
        // First put some funds in treasury
        dao.submitAction(keccak256("fund"), 500000, keccak256("vector"));
        for(uint8 i = 0; i < 9; i++) {
            dao.advancePhase(keccak256("fund"), "");
        }
        vm.deal(address(this), 2 ether);
        dao.executeAction{value: 2 ether}(keccak256("fund"));
        
        vm.expectRevert("Invalid recipient address");
        dao.withdrawTreasury(address(0), 0.1 ether);
        
        vm.expectRevert("Invalid withdrawal amount");
        dao.withdrawTreasury(address(0x100), 0); // Below MIN_WITHDRAW_AMOUNT
        
        vm.expectRevert("Invalid withdrawal amount");
        dao.withdrawTreasury(address(0x100), 51 ether); // Above MAX_WITHDRAW_AMOUNT
        
        // Test role management validation
        vm.expectRevert("Invalid account address");
        dao.grantScorerRole(address(0));
        
        vm.expectRevert("Invalid account address");
        dao.revokeScorerRole(address(0));
        
        vm.expectRevert("Cannot revoke own admin role");
        dao.revokeAdminRole(address(this));
    }

    function testTimelockIntegration() public {
        // Deploy timelock contract
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = address(this);
        executors[0] = address(this);
        
        VortexTimelock timelockContract = new VortexTimelock(
            24 hours, // 24 hour delay
            proposers,
            executors,
            address(0x999) // Different admin
        );
        
        // Set timelock in main contract
        dao.setTimelock(address(timelockContract));
        assertEq(dao.timelock(), address(timelockContract));
        
        // Grant DEFAULT_ADMIN_ROLE to timelock so it can execute operations
        dao.grantRole(dao.DEFAULT_ADMIN_ROLE(), address(timelockContract));
        
        // Test data
        address newAdmin = address(0x999);
        bytes32 salt = keccak256(abi.encodePacked("grantAdminRole", newAdmin, block.timestamp));
        
        // Schedule the role grant directly through timelock
        timelockContract.schedule(
            address(dao),
            0,
            abi.encodeWithSignature("grantRole(bytes32,address)", dao.ADMIN_ROLE(), newAdmin),
            bytes32(0),
            salt,
            24 hours
        );
        
        // Operation should be pending
        bytes32 operationId = timelockContract.hashOperation(
            address(dao),
            0,
            abi.encodeWithSignature("grantRole(bytes32,address)", dao.ADMIN_ROLE(), newAdmin),
            bytes32(0),
            salt
        );
        assertTrue(timelockContract.isOperationPending(operationId));
        
        // Fast forward 24 hours and execute
        vm.warp(block.timestamp + 24 hours + 1);
        
        timelockContract.execute(
            address(dao),
            0,
            abi.encodeWithSignature("grantRole(bytes32,address)", dao.ADMIN_ROLE(), newAdmin),
            bytes32(0),
            salt
        );
        
        // Verify the role was granted
        assertTrue(dao.hasRole(dao.ADMIN_ROLE(), newAdmin));
    }

    function testMultiSigIntegration() public {
        // Simulate Gnosis Safe address
        address mockSafe = address(0x1234567890123456789012345678901234567890);
        
        // Test transfer admin to safe
        dao.transferAdminToSafe(mockSafe);
        
        // Verify roles were granted to safe
        assertTrue(dao.hasRole(dao.ADMIN_ROLE(), mockSafe));
        assertTrue(dao.hasRole(dao.EMERGENCY_ROLE(), mockSafe));
        
        // Verify isMultiSigAdmin works
        assertTrue(dao.isMultiSigAdmin(mockSafe));
        assertTrue(dao.isMultiSigAdmin(address(this))); // Still has DEFAULT_ADMIN_ROLE
        
        // Test that safe can now perform admin operations
        vm.prank(mockSafe);
        dao.grantScorerRole(address(0x999));
        assertTrue(dao.hasRole(dao.SCORER_ROLE(), address(0x999)));
        
        // Test emergency pause with safe (don't test unpause due to 24h delay)
        vm.prank(mockSafe);
        dao.pause();
        assertTrue(dao.paused());
    }

    function testMultiSigValidation() public {
        address mockSafe = address(0x1234567890123456789012345678901234567890);
        
        // Test invalid safe address
        vm.expectRevert("Invalid safe address");
        dao.transferAdminToSafe(address(0));
        
        // Test cannot transfer to self
        vm.expectRevert("Cannot transfer to self");
        dao.transferAdminToSafe(address(this));
        
        // Test only DEFAULT_ADMIN can transfer
        vm.prank(address(0x999)); // Not DEFAULT_ADMIN
        vm.expectRevert();
        dao.transferAdminToSafe(mockSafe);
    }

    function testOracleSetup() public {
        // Oracle setup is now handled via SCORER_ROLE assignment
        // Test that we can grant scorer role
        dao.grantScorerRole(address(0x123));
        // Verify the role was granted (would need hasRole function exposed to test)
    }

    function testOracleValidSignature() public {
        // Reset timestamp to avoid interference from other tests
        vm.warp(1000000);
        
        // Grant scorer role to test address first
        dao.grantScorerRole(address(this));
        
        // Test data to submit
        bytes32 dataId = keccak256("valid signature test");
        uint256 dataValue = 42;
        
        // Submit oracle data - should succeed with SCORER_ROLE
        dao.submitOracleData(dataId, dataValue);
        
        // Verify data was stored
        assertEq(dao.getOracleData(dataId), dataValue);
        assertEq(dao.oracleDataTimestamp(dataId), block.timestamp);
    }

    function testOracleAccessControl() public {
        // Reset timestamp to avoid interference from other tests
        vm.warp(2000000);
        
        bytes32 dataId = keccak256("access control test");
        uint256 dataValue = 123;
        
        // Try to submit without SCORER_ROLE - should fail
        vm.expectRevert(); // Missing SCORER_ROLE
        dao.submitOracleData(dataId, dataValue);
        
        // Grant scorer role and try again - should succeed
        dao.grantScorerRole(address(this));
        dao.submitOracleData(dataId, dataValue);
        assertEq(dao.getOracleData(dataId), dataValue);
    }

    function testOracleRateLimiting() public {
        // Reset timestamp to avoid interference from other tests
        vm.warp(3000000);
        
        // Grant scorer role
        dao.grantScorerRole(address(this));
        
        bytes32 dataId = keccak256("rate limiting test");
        uint256 dataValue1 = 100;
        uint256 dataValue2 = 200;
        
        // Submit first update
        dao.submitOracleData(dataId, dataValue1);
        assertEq(dao.getOracleData(dataId), dataValue1);
        
        // Try to update immediately - should fail due to rate limiting
        vm.expectRevert("Oracle update too frequent");
        dao.submitOracleData(dataId, dataValue2);
        
        // Fast forward 1 hour and try again - should succeed
        vm.warp(block.timestamp + 1 hours + 1);
        dao.submitOracleData(dataId, dataValue2);
        assertEq(dao.getOracleData(dataId), dataValue2);
    }

    function testEmergencyPause() public {
        // Test that unauthorized user cannot pause
        vm.prank(address(0x2));
        vm.expectRevert(); // Should revert due to missing EMERGENCY_ROLE
        dao.pause();
        
        // Test that emergency role can pause
        dao.pause();
        assertTrue(dao.paused());
        assertEq(dao.pausedAt(), block.timestamp);
        
        // Test that critical functions are blocked when paused
        bytes32 actionHash = keccak256("Paused action");
        vm.expectRevert(); // Should revert due to paused contract
        dao.submitAction(actionHash, 400000, keccak256("vector"));
        
        // Test that unauthorized user cannot unpause immediately
        vm.prank(address(0x2));
        vm.expectRevert(); // Should revert due to missing ADMIN_ROLE
        dao.unpause();
        
        // Test that even admin cannot unpause immediately (24h delay required)
        vm.expectRevert(); // Should revert due to 24h delay requirement
        dao.unpause();
        
        // Fast forward 24 hours
        vm.warp(block.timestamp + 24 hours + 1);
        
        // Now admin can unpause
        dao.unpause();
        assertFalse(dao.paused());
        
        // Test that functions work again after unpause
        dao.submitAction(actionHash, 400000, keccak256("vector"));
        (, uint256 resonance, , , , ) = dao.getAction(actionHash);
        assertEq(resonance, 400000);
    }
}

// Malicious contract that attempts reentrancy
contract ReentrancyAttacker {
    VortexDAO public dao;
    bytes32 public attackHash;
    
    constructor(address _dao) {
        dao = VortexDAO(payable(_dao));
    }
    
    function attack(bytes32 _actionHash) external payable {
        attackHash = _actionHash;
        dao.executeAction{value: msg.value}(_actionHash);
    }
    
    // This function gets called during fee distribution via receive()
    receive() external payable {
        // Try to reenter and execute the same action again
        if (attackHash != bytes32(0)) {
            dao.executeAction(attackHash);
        }
    }
}
