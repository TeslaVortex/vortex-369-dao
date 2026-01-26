// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VortexDAO {
    function resonanceScore(uint256 amount, uint256 blockNumber) public pure returns (uint256) {
        uint256 score = 0;
        if (amount % 3 == 0) score += 3;
        if (amount % 6 == 0) score += 6;
        if (amount % 9 == 0) score += 9;
        if (blockNumber % 3 == 0) score += 1;
        if (blockNumber % 6 == 0) score += 2;
        if (blockNumber % 9 == 0) score += 3;
        return score;
    }
}
