// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title IPellionShield - Interface for PellionShield Privacy Contract
interface IPellionShield {
    function verifySecret(uint256 _proof) external pure returns (bool);
}
