// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "utils/VyperDeployer.sol";

contract TestContract is Test {
    address batchDeposit;

    function setUp() public {
        batchDeposit = VyperDeployer.deploy("BatchDeposit", false);
    }

    function testDeploy() public {
        assertNotEq(batchDeposit, address(0));
    }
}
