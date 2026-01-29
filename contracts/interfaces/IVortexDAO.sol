// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title IVortexDAO
/// @notice Interface for Vortex-369 DAO governance
interface IVortexDAO {
    /// @notice Submit a new proposal
    /// @param _text The proposal text
    /// @return proposalId The ID of the created proposal
    function submitProposal(string memory _text) external returns (uint256 proposalId);
    
    /// @notice Get proposal resonance score
    /// @param _proposalId The proposal ID
    /// @return score The resonance score (0-100)
    function getProposalScore(uint256 _proposalId) external view returns (uint8 score);
    
    /// @notice Get current phase of proposal
    /// @param _proposalId The proposal ID
    /// @return phase The current phase (0-9)
    function getCurrentPhase(uint256 _proposalId) external view returns (uint8 phase);
    
    /// @notice Execute a proposal (for high-resonance proposals)
    /// @param _proposalId The proposal ID
    function executeProposal(uint256 _proposalId) external;
    
    /// @notice Check if proposal is executed
    /// @param _proposalId The proposal ID
    /// @return executed True if proposal has been executed
    function isExecuted(uint256 _proposalId) external view returns (bool executed);
}
