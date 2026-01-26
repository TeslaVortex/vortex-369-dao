// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Article66Proposal} from "../src/Article66Proposal.sol";
import {TreasuryVault} from "../src/TreasuryVault.sol";
import {VortexDAO} from "../src/VortexDAO.sol";

contract Article66ProposalTest is Test {
    Article66Proposal proposalContract;
    TreasuryVault vault;
    VortexDAO vortexDAO;
    address owner = address(0x123);
    address recipient = address(0x456);

    function setUp() public {
        vortexDAO = new VortexDAO();
        vault = new TreasuryVault(address(this), address(vortexDAO)); // temp owner
        proposalContract = new Article66Proposal(address(vortexDAO), payable(address(vault)));
        vault.transferOwnership(address(proposalContract));
    }

    function testPropose() public {
        string memory desc = "Fund the 369 project with 66 ETH for abundance";
        proposalContract.propose(desc, 1 ether, recipient);
        (address proposer, string memory description, uint256 amount, address rec, uint256 score, uint256 queuedTime, bool executed) = proposalContract.proposals(0);
        assertEq(proposer, address(this));
        assertEq(amount, 1 ether);
        assertEq(rec, recipient);
        assertEq(executed, false);
        assert(score > 0);
        assertGt(queuedTime, 0); // Since score >66
    }

    function testExecuteHighScore() public {
        vm.deal(address(vault), 2 ether);
        string memory desc = "369 project funding for 66 abundance";
        proposalContract.propose(desc, 1 ether, recipient);
        // Advance time past the 9-hour delay
        vm.warp(block.timestamp + 9 hours + 1);
        proposalContract.executeQueued(0);
        (,,,,,, bool executed) = proposalContract.proposals(0);
        assert(executed);
        assertEq(address(vault).balance, 1 ether);
    }

    function testExecuteLowScore() public {
        vm.deal(address(vault), 2 ether);
        string memory desc = "Normal project";
        proposalContract.propose(desc, 1 ether, recipient);
        // Score <=66, so not queued
        vm.expectRevert("Proposal not queued for execution");
        proposalContract.executeQueued(0);
    }
}
