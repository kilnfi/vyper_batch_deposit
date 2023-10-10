pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../lib/utils/VyperDeployer.sol";

contract HoleskyDeploy is Script {
    address HOLESKY_DEPOSIT_CONTRACT = 0x4242424242424242424242424242424242424242;

    function run() external {
        address vyperBatchDeposit =
            VyperDeployer.deploy("BatchDeposit", abi.encode(HOLESKY_DEPOSIT_CONTRACT), true);
        console.log("VyperBatchDeposit: ", vyperBatchDeposit);
    }
}
