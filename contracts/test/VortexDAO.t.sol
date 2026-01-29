// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../core/VortexDAOSimplified.sol";
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
}
