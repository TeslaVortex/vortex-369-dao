// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title INullOffice
/// @notice Interface for the burning contract
interface INullOffice {
    /// @notice Burn ETH sent to this contract
    function burn() external payable;
    
    /// @notice Get total amount burned
    /// @return total The total ETH burned
    function totalBurned() external view returns (uint256 total);
}
