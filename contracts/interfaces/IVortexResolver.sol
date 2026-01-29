// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title IVortexResolver - Interface for VortexResolver Contract
interface IVortexResolver {
    function resolveAction(bytes32 actionHash, uint8 phase) external view returns (bool executable);
    function getWitnessRecord(bytes32 actionHash) external view returns (string memory base9Record);
}
