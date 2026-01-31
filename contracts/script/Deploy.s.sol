// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../core/VortexDAOSimplified.sol";
import "../core/NullOffice.sol";
import "../proxies/VortexDAOProxy.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy NullOffice implementation
        NullOffice nullOfficeImpl = new NullOffice();

        // Deploy VortexDAO implementation
        VortexDAO vortexDaoImpl = new VortexDAO();

        // Deploy VortexDAO proxy
        bytes memory vortexDaoInitData = abi.encodeWithSignature("initialize(address)", msg.sender);
        VortexDAOProxy vortexDaoProxy = new VortexDAOProxy(
            address(vortexDaoImpl),
            msg.sender, // admin
            vortexDaoInitData
        );
        VortexDAO vortexDao = VortexDAO(payable(address(vortexDaoProxy)));

        // Deploy NullOffice proxy
        bytes memory nullOfficeInitData = abi.encodeWithSignature("initialize()");
        VortexDAOProxy nullOfficeProxy = new VortexDAOProxy(
            address(nullOfficeImpl),
            msg.sender, // admin
            nullOfficeInitData
        );

        vm.stopBroadcast();

        console.log("VortexDAO Proxy deployed at:", address(vortexDaoProxy));
        console.log("VortexDAO Implementation at:", address(vortexDaoImpl));
        console.log("NullOffice Proxy deployed at:", address(nullOfficeProxy));
        console.log("NullOffice Implementation at:", address(nullOfficeImpl));
    }
}
