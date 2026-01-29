// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title IArticle66Proposal - Interface for Article66Proposal Contract
interface IArticle66Proposal {
    struct Proposal {
        address proposer;
        string description;
        uint256 amount;
        address recipient;
        uint256 score;
        uint256 queuedTime;
        bool executed;
    }

    event ProposalCreated(uint256 id, address proposer, string description, uint256 amount, address recipient, uint256 score);
    event ProposalExecuted(uint256 id);

    function propose(string memory desc, uint256 amount, address recipient) external;
    function calculateScore(string memory desc, uint256 amount, uint256 blockNum) external view returns (uint256);
    function executeQueued(uint256 id) external;
    function proposals(uint256) external view returns (address, string memory, uint256, address, uint256, uint256, bool);
    function nextId() external view returns (uint256);
}
