// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/VortexDAO.sol";
import "../src/TreasuryVault.sol";
import "../src/Article66Proposal.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy VortexDAO
        VortexDAO vortexDAO = new VortexDAO();

        // Deploy TreasuryVault with deployer as temp owner
        TreasuryVault vault = new TreasuryVault(msg.sender, address(vortexDAO));

        // Deploy Article66Proposal
        Article66Proposal proposal = new Article66Proposal(address(vortexDAO), payable(address(vault)));

        // Transfer vault ownership to proposal contract
        vault.transferOwnership(address(proposal));

        vm.stopBroadcast();

        // Log addresses
        console.log("VortexDAO deployed at:", address(vortexDAO));
        console.log("TreasuryVault deployed at:", address(vault));
        console.log("Article66Proposal deployed at:", address(proposal));
    }
}
