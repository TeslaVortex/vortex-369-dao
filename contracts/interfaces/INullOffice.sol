// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title INullOffice - Interface for NullOffice Burn Contract
interface INullOffice {
    event Burned(address indexed from, uint256 amount, uint256 totalBurned);

    function totalBurned() external view returns (uint256);
    function burnCount() external view returns (uint256);
    function balance() external view returns (uint256);
    function is369Pattern(uint256 amount) external pure returns (bool);
    function digitalRoot(uint256 n) external pure returns (uint256);
}
