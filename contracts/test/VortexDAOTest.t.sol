// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../core/VortexDAO.sol";
import "../core/NullOffice.sol";

contract VortexDAOTest is Test {
    VortexDAO public vortexDao;
    NullOffice public nullOffice;
    address public owner;
    address public user1;
    address public user2;

    uint256 constant MIN_FEE = 0.001 ether;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy contracts in correct order
        address dummy = makeAddr("dummy");
        vortexDao = new VortexDAO(dummy); // Deploy with dummy address first
        nullOffice = new NullOffice(address(vortexDao)); // Deploy with correct VortexDAO address
        vortexDao.setNullOffice(address(nullOffice)); // Update VortexDAO with NullOffice address

        // Fund test accounts
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    function testDeployment() public {
        assertEq(vortexDao.owner(), owner);
        assertEq(address(vortexDao.nullOffice()), address(nullOffice));
        assertEq(vortexDao.proposalCount(), 0);
    }

    function testSubmitHighScoreProposal() public {
        vm.prank(user1);
        uint256 proposalId = vortexDao.submitProposal{value: MIN_FEE}("Create harmony through resonance", 85);

        assertEq(proposalId, 1);
        assertEq(vortexDao.proposalCount(), 1);

        (uint256 id, address proposer, string memory text, uint8 score, , , , ) = vortexDao.getProposal(1);
        assertEq(id, 1);
        assertEq(proposer, user1);
        assertEq(text, "Create harmony through resonance");
        assertEq(score, 85);
    }

    function testSubmitMediumScoreProposal() public {
        vm.prank(user1);
        vortexDao.submitProposal{value: MIN_FEE}("Medium proposal", 50);

        uint8 score;
        VortexDAO.Phase phase;
        (, , , score, phase, , , ) = vortexDao.getProposal(1);
        assertEq(score, 50);
        assertEq(uint256(phase), uint256(VortexDAO.Phase.Proposal)); // Should start in Proposal phase for medium scores
    }

    function testSubmitLowScoreProposal() public {
        vm.prank(user1);
        vortexDao.submitProposal{value: MIN_FEE}("Low proposal", 20);

        (, , , uint8 score, VortexDAO.Phase phase, , , ) = vortexDao.getProposal(1);
        assertEq(score, 20);
        assertEq(uint256(phase), uint256(VortexDAO.Phase.Manifestation)); // Should go to Manifestation for burning
    }

    function testCannotSubmitWithoutFee() public {
        vm.prank(user1);
        vm.expectRevert("Minimum fee required");
        vortexDao.submitProposal("No fee", 80);
    }

    function testAdvancePhase() public {
        vm.prank(user1);
        vortexDao.submitProposal{value: MIN_FEE}("High score proposal", 80);

        // Should be in Silence phase
        VortexDAO.Phase phase;
        uint256 startTime;
        (uint256 id, address proposer, string memory text, uint8 score, VortexDAO.Phase p, uint256 st, bool executed, bool cancelled) = vortexDao.getProposal(1);
        phase = p;
        startTime = st;
        assertEq(uint256(phase), uint256(VortexDAO.Phase.Silence));

        // Try to advance too early - should revert
        vm.expectRevert("Phase not complete");
        vortexDao.advancePhase(1);

        // Warp time to after phase duration
        vm.warp(startTime + 3 days + 1);

        // Now can advance
        vortexDao.advancePhase(1);

        (, , , , p, st, , ) = vortexDao.getProposal(1);
        phase = p;
        assertEq(uint256(phase), uint256(VortexDAO.Phase.Proposal));
    }

    function testExecuteProposal() public {
        vm.prank(user1);
        vortexDao.submitProposal{value: 1 ether}("High score proposal", 80);

        // Fast forward through all phases to Manifestation
        uint256 phaseStart;
        (, , , , , phaseStart, , ) = vortexDao.getProposal(1);

        // Skip to Manifestation phase
        for (uint256 i = 0; i < 9; i++) {
            vm.warp(phaseStart + vortexDao.phaseDurations(i) + 1);
            if (i < 9) {
                vortexDao.advancePhase(1);
                (, , , , , phaseStart, , ) = vortexDao.getProposal(1);
            }
        }

        // Should be in Manifestation phase
        (uint256 id, address proposer, string memory text, uint8 score, VortexDAO.Phase p, uint256 st, bool executed, bool cancelled) = vortexDao.getProposal(1);
        VortexDAO.Phase phase = p;
        assertEq(uint256(phase), uint256(VortexDAO.Phase.Manifestation));

        // Fast forward through Manifestation period
        vm.warp(phaseStart + 9 days + 1);

        // Execute
        uint256 initialBalance = owner.balance;
        vortexDao.executeProposal(1);

        (, , , , , , executed, ) = vortexDao.getProposal(1);
        assertTrue(executed);

        // Check fee distribution (9% to DAO, 91% burned)
        uint256 expectedDaoAmount = (1 ether * 9) / 100;
        assertEq(owner.balance, initialBalance + expectedDaoAmount);
    }

    function testCancelProposal() public {
        vm.prank(user1);
        vortexDao.submitProposal{value: 1 ether}("High score proposal", 80);

        // Advance to Breath phase
        uint256 phaseStart;
        (, , , , , phaseStart, , ) = vortexDao.getProposal(1);

        for (uint256 i = 0; i < 6; i++) {
            vm.warp(phaseStart + vortexDao.phaseDurations(i) + 1);
            vortexDao.advancePhase(1);
            (, , , , , phaseStart, , ) = vortexDao.getProposal(1);
        }

        // Should be in Breath phase
        (uint256 id, address proposer, string memory text, uint8 score, VortexDAO.Phase p, uint256 st, bool executed, bool cancelled) = vortexDao.getProposal(1);
        VortexDAO.Phase phase = p;
        assertEq(uint256(phase), uint256(VortexDAO.Phase.Breath));

        // Cancel
        vm.prank(user1);
        vortexDao.cancelProposal(1);

        (, , , , , , , cancelled) = vortexDao.getProposal(1);
        assertTrue(cancelled);

        // Check refund
        assertEq(user1.balance, 10 ether); // Original balance minus fee paid, plus refund
    }

    function testCanAdvancePhase() public {
        vm.prank(user1);
        vortexDao.submitProposal{value: MIN_FEE}("Test proposal", 80);

        // Initially cannot advance
        assertFalse(vortexDao.canAdvancePhase(1));

        // After phase time
        vm.warp(block.timestamp + 3 days + 1);
        assertTrue(vortexDao.canAdvancePhase(1));
    }
}
