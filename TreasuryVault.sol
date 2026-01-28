// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TreasuryVault {
    function distribute(address recipient, uint256 amount, uint256 score) public {
        // Stub: if score >66, distribute
        if (score > 66) {
            payable(recipient).transfer(amount);
        }
    }
}
