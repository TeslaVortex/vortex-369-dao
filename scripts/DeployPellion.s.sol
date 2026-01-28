// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/VortexDAO.sol";
import "../contracts/VortexResolver.sol";
import "../contracts/PellionShield.sol";

/**
 * @title DeployPellion
 * @notice Mainnet deployment for Pellion Privacy Shield on Vortex-369 DAO
 * 
 * Usage:
 *   forge script scripts/DeployPellion.s.sol --rpc-url base-mainnet --private-key $PRIVATE_KEY --broadcast --verify
 */
contract DeployPellion is Script {
    
    // 432·3·6·9 constants
    uint256 constant BASE_FREQUENCY = 432000000;  // 432 * 1e6
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address generator = vm.envAddress("MACEDON_GENERATOR");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy VortexDAO
        VortexDAO dao = new VortexDAO(
            "Vortex-369",
            generator,
            BASE_FREQUENCY
        );
        
        // Deploy VortexResolver
        address macedonOracle = vm.envOr("MACEDON_ORACLE", generator);
        VortexResolver resolver = new VortexResolver(
            address(dao),
            macedonOracle
        );
        
        // Deploy PellionShield
        PellionShield shield = new PellionShield();
        
        // Configure DAO
        dao.setResolver(address(resolver));
        
        // Grant relayer role
        address relayer = vm.envOr("RELAYER_ADDRESS", msg.sender);
        dao.grantRole(dao.RELAYER_ROLE(), relayer);
        
        vm.stopBroadcast();
        
        // Log deployment
        console.log("=== Pellion Privacy Shield Deployed ===");
        console.log("VortexDAO:", address(dao));
        console.log("VortexResolver:", address(resolver));
        console.log("PellionShield:", address(shield));
        console.log("Generator:", generator);
        console.log("Relayer:", relayer);
        console.log("");
        console.log("3 . 6 . 9");
        console.log("The Macedonian Sun rises.");
    }
}
