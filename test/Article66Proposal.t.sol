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
        vault = new TreasuryVault(address(this), address(vortexDAO), address(0)); // temp owner
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

    function testProposeWith369() public {
        string memory desc = "369 432 abundance project";
        proposalContract.propose(desc, 1 ether, recipient);
        (,,,, uint256 score,,) = proposalContract.proposals(0);
        assertGt(score, 66); // Boosted
    }

    function testProposeWith432() public {
        string memory desc = "432 369 harmony project";
        proposalContract.propose(desc, 1 ether, recipient);
        (,,,, uint256 score,,) = proposalContract.proposals(0);
        assertGt(score, 66);
    }

    function testProposeWith66() public {
        string memory desc = "66 wealth project";
        proposalContract.propose(desc, 1 ether, recipient);
        (,,,, uint256 score,,) = proposalContract.proposals(0);
        assertEq(score, 50);
    }

    function testCalculateScoreNoBoost() public {
        string memory desc = "Normal project";
        uint256 score = proposalContract.calculateScore(desc, 369, 1000);
        assertEq(score, 12); // Base score for 369 at block 1000
    }

    function testCalculateScoreWithBoost() public {
        string memory desc = "369 project";
        uint256 score = proposalContract.calculateScore(desc, 369, 1000);
        assertEq(score, 62); // 12 +50
    }

    function testExecuteQueuedBeforeTimelock() public {
        vm.deal(address(vault), 2 ether);
        string memory desc = "369 432 66 project funding";
        proposalContract.propose(desc, 1 ether, recipient);
        vm.expectRevert("Timelock not expired");
        proposalContract.executeQueued(0);
    }

    function testExecuteNotQueued() public {
        vm.expectRevert("Proposal not queued for execution");
        proposalContract.executeQueued(0);
    }

    function testProposeEmptyDesc() public {
        string memory desc = "";
        proposalContract.propose(desc, 1 ether, recipient);
        (,,,, uint256 score,,) = proposalContract.proposals(0);
        assertGe(score, 0);
    }

    function testFuzzPropose(uint256 amount) public {
        vm.assume(amount > 0 && amount < 100 ether);
        string memory desc = "Fuzz test proposal";
        proposalContract.propose(desc, amount, recipient);
        (,,,, uint256 score,,) = proposalContract.proposals(0);
        assertGe(score, 0);
    }
}
