pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../lib/utils/VyperDeployer.sol";

contract MainnetDeploy is Script {
    address MAINNET_DEPOSIT_CONTRACT = 0x00000000219ab540356cBB839Cbe05303d7705Fa;

    function run() external {
        address vyperBatchDeposit =
            VyperDeployer.deploy("BatchDeposit", abi.encode(MAINNET_DEPOSIT_CONTRACT), true);
        console.log("VyperBatchDeposit: ", vyperBatchDeposit);
    }
}
