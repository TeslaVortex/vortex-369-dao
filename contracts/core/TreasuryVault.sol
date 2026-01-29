// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./VortexDAO.sol";
import "chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract TreasuryVault is Ownable {
    VortexDAO public vortexDAO;
    AggregatorV3Interface public goldAggregator;

    constructor(address initialOwner, address _vortexDAO, address _goldAggregator) Ownable(initialOwner) {
        vortexDAO = VortexDAO(_vortexDAO);
        goldAggregator = AggregatorV3Interface(_goldAggregator);
    }

    receive() external payable {}

    function deposit() external payable {}

    function distribute(address recipient, uint256 amount, uint256 resonanceScore) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        require(resonanceScore > 66, "Resonance score must be >66");
        payable(recipient).transfer(amount);
    }

    function withdraw(uint256 amount, uint256 resonanceScore) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        require(resonanceScore > 66, "Resonance score must be >66");
        payable(owner()).transfer(amount);
    }

    // Hook for scoring, but for now, pass the score

function getGoldPrice() public view returns (int256) {
    (,int256 price,,,) = goldAggregator.latestRoundData();
    return price;
}
}
