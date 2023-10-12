pragma solidity ^0.8.15;

import "./VyperScript.s.sol";

contract MainnetDeploy is VyperScript {
    address MAINNET_DEPOSIT_CONTRACT = 0x00000000219ab540356cBB839Cbe05303d7705Fa;

    function run() external {
        address vyperBatchDeposit =
            deploy("BatchDeposit", abi.encode(MAINNET_DEPOSIT_CONTRACT), true);
        console.log("VyperBatchDeposit: ", vyperBatchDeposit);
    }
}
