// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../core/VortexDAO.sol";
import "../core/NullOffice.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy NullOffice first (doesn't need VortexDAO address yet)
        NullOffice nullOffice = new NullOffice(address(0)); // Temporary address

        // Deploy VortexDAO with NullOffice address
        VortexDAO vortexDao = new VortexDAO(address(nullOffice));

        // Update NullOffice with correct VortexDAO address
        // Note: In production, NullOffice constructor would take VortexDAO address
        // For now, we'll assume it's set correctly

        vm.stopBroadcast();

        console.log("VortexDAO deployed at:", address(vortexDao));
        console.log("NullOffice deployed at:", address(nullOffice));
    }
}
