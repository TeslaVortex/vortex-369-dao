// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title ITreasuryVault - Interface for TreasuryVault Contract
interface ITreasuryVault {
    function deposit() external payable;
    function distribute(address recipient, uint256 amount, uint256 resonanceScore) external;
    function withdraw(uint256 amount, uint256 resonanceScore) external;
    function getGoldPrice() external view returns (int256);
}
