// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VortexDAO.sol";
import "./TreasuryVault.sol";

contract Article66Proposal {
    VortexDAO public vortexDAO;
    TreasuryVault public treasuryVault;

    uint256 constant DELAY = 9 hours;

    struct Proposal {
        address proposer;
        string description;
        uint256 amount;
        address recipient;
        uint256 score;
        uint256 queuedTime;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public nextId;

    event ProposalCreated(uint256 id, address proposer, string description, uint256 amount, address recipient, uint256 score);
    event ProposalExecuted(uint256 id);

    constructor(address _vortexDAO, address payable _treasuryVault) {
        vortexDAO = VortexDAO(_vortexDAO);
        treasuryVault = TreasuryVault(_treasuryVault);
    }

    function propose(string memory desc, uint256 amount, address recipient) public {
        uint256 score = calculateScore(desc, amount, block.number);
        uint256 queuedTime = score > 66 ? block.timestamp + DELAY : 0;
        proposals[nextId] = Proposal(msg.sender, desc, amount, recipient, score, queuedTime, false);
        emit ProposalCreated(nextId, msg.sender, desc, amount, recipient, score);
        nextId++;
    }

    function calculateScore(string memory desc, uint256 amount, uint256 blockNum) public view returns (uint256) {
        uint256 baseScore = vortexDAO.resonanceScore(amount, blockNum);
        // Boost for keywords
        uint256 boost = 0;
        if (contains(desc, "369")) boost += 50;
        if (contains(desc, "432")) boost += 50;
        if (contains(desc, "66")) boost += 50;
        return baseScore + boost;
    }

    function contains(string memory haystack, string memory needle) internal pure returns (bool) {
        bytes memory h = bytes(haystack);
        bytes memory n = bytes(needle);
        if (n.length > h.length) return false;
        for (uint i = 0; i <= h.length - n.length; i++) {
            bool found = true;
            for (uint j = 0; j < n.length; j++) {
                if (h[i + j] != n[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return true;
        }
        return false;
    }

    function executeQueued(uint256 id) public {
        Proposal storage p = proposals[id];
        require(p.queuedTime > 0, "Proposal not queued for execution");
        require(block.timestamp >= p.queuedTime, "Timelock not expired");
        require(!p.executed, "Already executed");
        treasuryVault.distribute(p.recipient, p.amount, p.score);
        p.executed = true;
        emit ProposalExecuted(id);
    }
}
