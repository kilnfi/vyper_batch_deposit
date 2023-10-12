pragma solidity ^0.8.15;

import "./VyperScript.s.sol";

contract HoleskyDeploy is VyperScript {
    address HOLESKY_DEPOSIT_CONTRACT = 0x4242424242424242424242424242424242424242;

    function run() external {
        address vyperBatchDeposit =
            deploy("BatchDeposit", abi.encode(HOLESKY_DEPOSIT_CONTRACT), true);
        console.log("VyperBatchDeposit: ", vyperBatchDeposit);
    }
}
