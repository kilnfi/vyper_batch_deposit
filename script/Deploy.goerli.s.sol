pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../lib/utils/VyperDeployer.sol";

contract GoerliDeploy is Script {
    address GOERLI_DEPOSIT_CONTRACT = 0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b;

    function run() external {
        address vyperBatchDeposit =
            VyperDeployer.deploy("BatchDeposit", abi.encode(GOERLI_DEPOSIT_CONTRACT), true);
        console.log("VyperBatchDeposit: ", vyperBatchDeposit);
    }
}
