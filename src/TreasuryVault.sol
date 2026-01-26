// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./VortexDAO.sol";

contract TreasuryVault is Ownable {
    VortexDAO public vortexDAO;

    constructor(address initialOwner, address _vortexDAO) Ownable(initialOwner) {
        vortexDAO = VortexDAO(_vortexDAO);
    }

    receive() external payable {}

    function deposit() external payable {}

    function withdraw(uint256 amount, uint256 resonanceScore) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        require(resonanceScore > 66, "Resonance score must be >66");
        payable(owner()).transfer(amount);
    }

    // Hook for scoring, but for now, pass the score
}
