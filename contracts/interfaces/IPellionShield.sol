// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title IPellionShield - Interface for PellionShield Privacy Contract
interface IPellionShield {
    function verifySecret(uint[2] memory _pA, uint[2][2] memory _pB, uint[2] memory _pC, uint[1] memory _pubSignals) external view returns (bool);
}
