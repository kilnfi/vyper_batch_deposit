pragma solidity ^0.8.15;

import "./VyperScript.s.sol";

contract GoerliDeploy is VyperScript {
    address GOERLI_DEPOSIT_CONTRACT = 0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b;

    function run() external {
        address vyperBatchDeposit = deploy("BatchDeposit", abi.encode(GOERLI_DEPOSIT_CONTRACT), true);
        console.log("VyperBatchDeposit: ", vyperBatchDeposit);
    }
}
