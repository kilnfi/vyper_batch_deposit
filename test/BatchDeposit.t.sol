// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "utils/VyperDeployer.sol";

import "../src/interface/IBatchDeposit.sol";
import "./mock/DepositContractMock.sol";

contract BatchDepositTest is Test {
    /* -------------------------------- constants ------------------------------- */

    address constant depositContractAddr = 0x00000000219ab540356cBB839Cbe05303d7705Fa;
    bytes constant pubkey = hex"aaa972ba0b2cc9153d13e1f2cd8540f765da3b3e4f7176e703c671e03944ac43409ec30a111568521cdd7c8f1ed0ce9a";
    bytes constant withdrawal_credential = hex"00f53a121f40eb62d64669abe5715fb2afc69b320373ebab1462602c34d8a70c";
    bytes constant signature =
        hex"a9465b8c5c74da9cef443697cccd9df225cc4efc278413ff584207880db1d24e598bd5f389a097269c372af92ad3c14e14f9c4dee5c9bcec6a45acd472aefdff2945c858bd6311546e34140d49fab0b698aefcf0068eaf5099372716c941cd95";
    bytes32 constant deposit_data_root = hex"04414c65b36ca664ceaf7d3effc41f83b0660cadf6fdf92981b46ba33431ba6c";

    /* --------------------------------- storage -------------------------------- */

    address staker;
    address batchDeposit;
    DepositContract depositContract = new DepositContract(); 

    /* ---------------------------------- setUp --------------------------------- */

    function setUp() public {
        staker = address(uint160(uint256(keccak256(abi.encode("staker")))));
        vm.deal(staker, 1_000_000_000 ether);

        vm.etch(depositContractAddr, address(depositContract).code);

        VyperDeployer vyperDeployer = new VyperDeployer();
        batchDeposit = vyperDeployer.deploy("BatchDeposit", abi.encode(depositContractAddr), false);
    }

    /* ---------------------------------- tests --------------------------------- */

    function testDeploy() public {
        assertNotEq(batchDeposit, address(0));
    }

    function testMaxBatchDeposit() public {
        vm.startPrank(staker);
        performBatchDeposit(800);
        vm.stopPrank();
    }

    /* ---------------------------------- utils --------------------------------- */

    function performBatchDeposit(uint256 count) public {
        bytes memory concat_pubkeys = new bytes(0);
        bytes memory concat_withdrawal_credentials = new bytes(0);
        bytes memory concat_signatures = new bytes(0);
        bytes32[] memory deposit_data_root_arr = new bytes32[](count);
        
        for (uint256 i = 0; i < count; i++) {
            concat_pubkeys = bytes.concat(concat_pubkeys, pubkey);
            concat_withdrawal_credentials = bytes.concat(concat_withdrawal_credentials, withdrawal_credential);
            concat_signatures = bytes.concat(concat_signatures, signature);
            deposit_data_root_arr[i] = deposit_data_root;
        }

        IBatchDeposit(batchDeposit).batchDeposit(
            concat_pubkeys,
            concat_withdrawal_credentials,
            concat_signatures,
            deposit_data_root_arr
        );
    }
}
