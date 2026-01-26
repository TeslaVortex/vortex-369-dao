// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TreasuryVault} from "../src/TreasuryVault.sol";
import {VortexDAO} from "../src/VortexDAO.sol";
import "chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract TreasuryVaultTest is Test {
    TreasuryVault vault;
    VortexDAO vortexDAO;
    address owner = address(0x123);
    address goldAggregator = address(0x1234);

    function setUp() public {
        vortexDAO = new VortexDAO();
        vault = new TreasuryVault(owner, address(vortexDAO), goldAggregator);
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

    function testDepositZero() public {
        vault.deposit{value: 0}();
        assertEq(address(vault).balance, 0);
    }

    function testWithdrawZero() public {
        vm.deal(address(this), 1 ether);
        vault.deposit{value: 1 ether}();
        vm.prank(owner);
        vault.withdraw(0, 100);
        assertEq(address(vault).balance, 1 ether);
    }

    function testWithdrawInsufficientFunds() public {
        vm.prank(owner);
        vm.expectRevert("Insufficient balance");
        vault.withdraw(1 ether, 100);
    }

    function testWithdrawNotOwner() public {
        vm.deal(address(this), 1 ether);
        vault.deposit{value: 1 ether}();
        vm.expectRevert();
        vault.withdraw(0.5 ether, 100);
    }

    function testDepositMultiple() public {
        vm.deal(address(this), 2 ether);
        vault.deposit{value: 1 ether}();
        vault.deposit{value: 1 ether}();
        assertEq(address(vault).balance, 2 ether);
    }

    function testWithdrawMultiple() public {
        vm.deal(address(this), 2 ether);
        vault.deposit{value: 2 ether}();
        vm.prank(owner);
        vault.withdraw(1 ether, 100);
        vm.prank(owner);
        vault.withdraw(0.5 ether, 100);
        assertEq(address(vault).balance, 0.5 ether);
    }

    function testTransferOwnership() public {
        address newOwner = address(0x456);
        vm.prank(owner);
        vault.transferOwnership(newOwner);
        assertEq(vault.owner(), newOwner);
    }

    function testRenounceOwnership() public {
        vm.prank(owner);
        vault.renounceOwnership();
        assertEq(vault.owner(), address(0));
    }

    function testDepositAfterWithdraw() public {
        vm.deal(address(this), 2 ether);
        vault.deposit{value: 1 ether}();
        vm.prank(owner);
        vault.withdraw(0.5 ether, 100);
        vault.deposit{value: 1 ether}();
        assertEq(address(vault).balance, 1.5 ether);
    }

    function testFuzzWithdraw(uint256 amount) public {
        vm.assume(amount > 0 && amount < 10 ether);
        vm.deal(address(this), amount);
        vault.deposit{value: amount}();
        vm.prank(owner);
        vault.withdraw(amount, 100);
        assertEq(address(vault).balance, 0);
    }

    function testGetGoldPrice() public {
        vm.mockCall(goldAggregator, abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector), abi.encode(0, 100000000, 0, 0, 0));
        int256 price = vault.getGoldPrice();
        assertEq(price, 100000000);
    }
}
