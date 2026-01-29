// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title IVortexDAO - Interface for VortexDAO Resonance Scoring Contract
interface IVortexDAO {
    function resonanceScore(uint256 amount, uint256 blockNumber) external pure returns (uint256);
}
