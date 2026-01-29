// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

/// @title VortexDAO Proxy
/// @notice Upgradeable proxy for VortexDAO contract
contract VortexDAOProxy is TransparentUpgradeableProxy {
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) TransparentUpgradeableProxy(_logic, admin_, _data) {}
}
