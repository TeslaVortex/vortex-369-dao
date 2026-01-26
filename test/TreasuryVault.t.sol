// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TreasuryVault} from "../src/TreasuryVault.sol";
import {VortexDAO} from "../src/VortexDAO.sol";

contract TreasuryVaultTest is Test {
    TreasuryVault vault;
    VortexDAO vortexDAO;
    address owner = address(0x123);

    function setUp() public {
        vortexDAO = new VortexDAO();
        vault = new TreasuryVault(owner, address(vortexDAO));
    }

    function testDeposit() public {
        vm.deal(address(this), 1 ether);
        vault.deposit{value: 1 ether}();
        assertEq(address(vault).balance, 1 ether);
    }

    function testWithdraw() public {
        vm.deal(address(this), 1 ether);
        vault.deposit{value: 1 ether}();
        vm.prank(owner);
        vault.withdraw(0.5 ether, 100);
        assertEq(address(vault).balance, 0.5 ether);
    }

    function testWithdrawLowScore() public {
        vm.deal(address(this), 1 ether);
        vault.deposit{value: 1 ether}();
        vm.prank(owner);
        vm.expectRevert("Resonance score must be >66");
        vault.withdraw(0.5 ether, 50);
    }

    function testFuzzDeposit(uint256 amount) public {
        vm.assume(amount > 0 && amount < 100 ether);
        vm.deal(address(this), amount);
        vault.deposit{value: amount}();
        assertEq(address(vault).balance, amount);
    }
}
