// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title VortexTimelock
 * @notice Timelock controller for delayed execution of critical VortexDAO operations
 * @dev 24-hour delay for all administrative actions to prevent rushed decisions
 */
contract VortexTimelock is TimelockController {
    constructor(
        uint256 minDelay,  // 24 hours in seconds
        address[] memory proposers,
        address[] memory executors,
        address admin
    ) TimelockController(minDelay, proposers, executors, admin) {}
}
