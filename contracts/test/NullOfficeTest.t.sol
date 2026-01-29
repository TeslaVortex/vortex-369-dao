// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../core/NullOffice.sol";

contract NullOfficeTest is Test {
    NullOffice public nullOffice;
    address public vortexDao;
    address public unauthorized;

    function setUp() public {
        vortexDao = makeAddr("vortexDao");
        unauthorized = makeAddr("unauthorized");

        nullOffice = new NullOffice(vortexDao);
    }

    function testDeployment() public {
        assertEq(nullOffice.vortexDao(), vortexDao);
        assertEq(nullOffice.totalBurned(), 0);
        assertTrue(nullOffice.isActive());
    }

    function testBurnFees() public {
        vm.startPrank(vortexDao);
        nullOffice.burnFees{value: 1 ether}();
        vm.stopPrank();

        assertEq(nullOffice.getTotalBurned(), 1 ether);
    }

    function testCannotBurnFromUnauthorized() public {
        vm.startPrank(unauthorized);
        vm.expectRevert("Only VortexDAO can burn fees");
        nullOffice.burnFees{value: 1 ether}();
        vm.stopPrank();
    }

    function testReceiveFunction() public {
        vm.startPrank(vortexDao);
        (bool success,) = address(nullOffice).call{value: 0.5 ether}("");
        vm.stopPrank();

        assertTrue(success);
        assertEq(nullOffice.getTotalBurned(), 0.5 ether);

        // Test that direct sends from unauthorized revert
        vm.startPrank(unauthorized);
        vm.expectRevert("Direct sends not allowed - use burnFees()");
        (bool success2,) = address(nullOffice).call{value: 0.5 ether}("");
        vm.stopPrank();
        assertFalse(success2);
    }

    function testCannotDeployWithZeroAddress() public {
        vm.expectRevert("Invalid VortexDAO address");
        new NullOffice(address(0));
    }
}
