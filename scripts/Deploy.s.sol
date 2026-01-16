// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/VortexDAO.sol";
import "../contracts/VortexResolver.sol";

/**
 * @title DeployVortex
 * @notice One-click deployment for Vortex-369 DAO
 * 
 * Usage:
 *   forge script scripts/Deploy.s.sol --rpc-url base --private-key $KEY --broadcast
 */
contract DeployVortex is Script {
    
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
        
        // Configure DAO
        dao.setResolver(address(resolver));
        
        // Grant relayer role
        address relayer = vm.envOr("RELAYER_ADDRESS", msg.sender);
        dao.grantRole(dao.RELAYER_ROLE(), relayer);
        
        vm.stopBroadcast();
        
        // Log deployment
        console.log("=== Vortex-369 DAO Deployed ===");
        console.log("VortexDAO:", address(dao));
        console.log("VortexResolver:", address(resolver));
        console.log("Generator:", generator);
        console.log("Relayer:", relayer);
        console.log("");
        console.log("3 . 6 . 9");
        console.log("The Vortex is open.");
    }
}

/**
 * @title VerifyDeployment
 * @notice Verify deployed contracts
 */
contract VerifyDeployment is Script {
    function run() external view {
        address daoAddress = vm.envAddress("VORTEX_DAO");
        VortexDAO dao = VortexDAO(payable(daoAddress));
        
        // Verify configuration
        require(dao.BASE_FREQUENCY() == 432, "Invalid frequency");
        require(bytes(dao.name()).length > 0, "Name not set");
        
        // Get stats
        (uint256 yield, uint256 liquidations, uint256 burned, uint256 cycle) = dao.getStats();
        
        console.log("=== Vortex-369 Status ===");
        console.log("Total Yield:", yield);
        console.log("Total Liquidations:", liquidations);
        console.log("Total Burned:", burned);
        console.log("Current Cycle:", cycle);
    }
}

/**
 * @title JoinDAO
 * @notice Join the DAO by burning 9% of deposit to Null
 */
contract JoinDAO is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address daoAddress = vm.envAddress("VORTEX_DAO");
        
        VortexDAO dao = VortexDAO(payable(daoAddress));
        
        vm.startBroadcast(privateKey);
        
        // Minimum 0.0369 ETH to join
        dao.joinAsMember{value: 0.0369 ether}();
        
        vm.stopBroadcast();
        
        console.log("Welcome to the Vortex.");
        console.log("9% of your contribution has been burned to Null.");
    }
}
