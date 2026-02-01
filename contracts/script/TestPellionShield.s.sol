// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../core/PellionShield.sol";

contract TestPellionShield is Script {
    function run() external {
        // Deployed PellionShield address on Base Sepolia
        address pellionShieldAddr = 0xfc9f75d09972E575CEDaB1Ea90e01Fa9bECDafE4;
        PellionShield pellionShield = PellionShield(pellionShieldAddr);

        // Valid proof data for secret=1, public_hash=2 (secret * 2) with non-contributed zkey
        uint[2] memory a = [5163393225025383670080268920665539808754104938250957045286698466161442635880, 16000476956376266156252541216200295710776941813498791976259711742653531367271];
        uint[2][2] memory b = [[16477572863750456913558992459736028549699368690326478537245138929003194808663, 13998352368718431406713943176700863701027936471822727277875215678917978068276], [20354598498721506181974357409218235324820306500855825323841925761626047142164, 18822026742828604247925083657481622654364036231734498599771593415711043053683]];
        uint[2] memory c = [17388343951595092745864388826853434839953157485675042760858020344666679114823, 14524863043304392573388519699157512630678229733255479294408356500135835633336];
        uint[1] memory input = [uint256(2)];

        console.log("Testing PellionShield verifySecret with real ZK proof:");
        console.log("Zero marginal cost: view function, no gas for verification onchain.");
        console.log("Real ZK proof for secret=1, demonstrating full power of Pellion ZK-ready shield.");
        console.log("");

        bool result = pellionShield.verifySecret(a, b, c, input);
        console.log("Proof verification result: %s", result ? "VALID" : "INVALID");

        console.log("");
        console.log("#PellionShield #ZKProofs #ZeroCostVerification LFG!");
    }
}
