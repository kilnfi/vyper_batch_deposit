// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "utils/VyperDeployer.sol";

import "../src/interface/IBatchDeposit.sol";
import "./mock/DepositContractMock.sol";
import "./mock/DepositContractTestable.sol";
import "./utils/BytesGenerator.sol";
import "./lib/LibBytes.sol";

contract BatchDepositTest is Test, BytesGenerator {
    /* -------------------------------- constants ------------------------------- */

    DepositContractTestable constant depositContract =
        DepositContractTestable(0x00000000219ab540356cBB839Cbe05303d7705Fa);
    bytes constant pubkey =
        hex"aaa972ba0b2cc9153d13e1f2cd8540f765da3b3e4f7176e703c671e03944ac43409ec30a111568521cdd7c8f1ed0ce9a";
    bytes constant withdrawal_credential = hex"00f53a121f40eb62d64669abe5715fb2afc69b320373ebab1462602c34d8a70c";
    bytes constant signature =
        hex"a9465b8c5c74da9cef443697cccd9df225cc4efc278413ff584207880db1d24e598bd5f389a097269c372af92ad3c14e14f9c4dee5c9bcec6a45acd472aefdff2945c858bd6311546e34140d49fab0b698aefcf0068eaf5099372716c941cd95";
    bytes32 constant deposit_data_root = hex"04414c65b36ca664ceaf7d3effc41f83b0660cadf6fdf92981b46ba33431ba6c";

    /* --------------------------------- storage -------------------------------- */

    address staker;
    address batchDeposit;
    DepositContractTestable depositContractCode = new DepositContractTestable();

    /* ---------------------------------- setUp --------------------------------- */

    function setUp() public {
        staker = address(uint160(uint256(keccak256(abi.encode("staker")))));
        vm.deal(staker, 1_000_000_000 ether);

        vm.etch(address(depositContract), address(depositContractCode).code);
        batchDeposit = VyperDeployer.deploy("BatchDeposit", abi.encode(address(depositContract)), false);
    }

    /* ---------------------------------- tests --------------------------------- */

    function testMaxBatchDeposit() public {
        vm.startPrank(staker);
        uint256 balanceBefore = address(staker).balance;
        performBatchDeposit(64);
        assertEq(depositContract.deposit_count(), 64);
        assertEq(address(staker).balance, balanceBefore - 64 * 32 ether);
        vm.stopPrank();
    }

    function testMaxBigBatchDeposit() public {
        vm.startPrank(staker);
        uint256 balanceBefore = address(staker).balance;
        performBigBatchDeposit(512);
        assertEq(depositContract.deposit_count(), 512);
        assertEq(address(staker).balance, balanceBefore - 512 * 32 ether);
        vm.stopPrank();
    }

    function testMinBatchDeposit() public {
        vm.startPrank(staker);
        uint256 balanceBefore = address(staker).balance;
        performBatchDeposit(1);
        assertEq(depositContract.deposit_count(), 1);
        assertEq(address(staker).balance, balanceBefore - 32 ether);
        vm.stopPrank();
    }

    function testMaxBatchDepositCustom(uint72 amount) public {
        vm.assume(amount > 1 ether && amount < 2048 ether);
        uint256 balanceBefore = address(staker).balance;
        vm.startPrank(staker);
        performBatchDepositCustom(64, amount);
        assertEq(depositContract.deposit_count(), 64);
        assertEq(address(staker).balance, balanceBefore - 64 * uint256(amount));
        vm.stopPrank();
    }

    function testMaxBigBatchDepositCustom(uint72 amount) public {
        vm.assume(amount > 1 ether && amount < 2048 ether);
        uint256 balanceBefore = address(staker).balance;
        vm.startPrank(staker);
        performBigBatchDepositCustom(512, amount);
        assertEq(depositContract.deposit_count(), 512);
        assertEq(address(staker).balance, balanceBefore - 512 * uint256(amount));
        vm.stopPrank();
    }

    function testMinBatchDepositCustom(uint72 amount) public {
        vm.assume(amount > 1 ether);
        uint256 balanceBefore = address(staker).balance;
        vm.startPrank(staker);
        performBatchDepositCustom(1, amount);
        assertEq(depositContract.deposit_count(), 1);
        assertEq(address(staker).balance, balanceBefore - uint256(amount));
        vm.stopPrank();
    }

    function test_batchDeposit_match(uint256 c) public {
        setSalt(bytes32(abi.encodePacked(c)));
        c = bound(c, 1, 64);
        uint256 COUNT = uint256(c);

        console.log("COUNT", COUNT);

        bytes memory pubkeys = genBytes(48 * COUNT);
        bytes memory withdrawal_credentials = genBytes(32 * COUNT);
        bytes memory signatures = genBytes(96 * COUNT);
        bytes32[] memory deposit_data_roots = new bytes32[](COUNT);
        bytes[] memory pubkeysList = new bytes[](COUNT);
        bytes[] memory withdrawalCredentialsList = new bytes[](COUNT);
        bytes[] memory signaturesList = new bytes[](COUNT);
        for (uint256 i = 0; i < COUNT; i++) {
            pubkeysList[i] = LibBytes.slice(pubkeys, i * 48, 48);
            withdrawalCredentialsList[i] = LibBytes.slice(withdrawal_credentials, i * 32, 32);
            signaturesList[i] = LibBytes.slice(signatures, i * 96, 96);
            deposit_data_roots[i] = bytes32(genBytes(32));
        }
        vm.deal(address(this), 32 ether * COUNT);

        vm.pauseGasMetering();
        IBatchDeposit vyperDeposit = IBatchDeposit(batchDeposit);
        vyperDeposit.batchDeposit{value: 32 ether * COUNT}(
            pubkeys, withdrawal_credentials, signatures, deposit_data_roots
        );

        for (uint256 i; i < COUNT; i++) {
            assertEq(depositContract.depositDataRoots(i), deposit_data_roots[i]);
            assertEq(depositContract.depositPubkeys(i), pubkeysList[i]);
            assertEq(depositContract.depositWithdrawalCredentials(i), withdrawalCredentialsList[i]);
            assertEq(depositContract.depositSignatures(i), signaturesList[i]);
        }
        assertEq(address(this).balance, 0);
        assertEq(address(batchDeposit).balance, 0);
    }

    function test_bigBatchDeposit_match(uint256 c) public {
        setSalt(bytes32(abi.encodePacked(c)));
        c = bound(c, 1, 256);
        uint256 COUNT = uint256(c);

        console.log("COUNT", COUNT);

        bytes memory pubkeys = genBytes(48 * COUNT);
        bytes memory withdrawal_credentials = genBytes(32 * COUNT);
        bytes memory signatures = genBytes(96 * COUNT);
        bytes32[] memory deposit_data_roots = new bytes32[](COUNT);
        bytes[] memory pubkeysList = new bytes[](COUNT);
        bytes[] memory withdrawalCredentialsList = new bytes[](COUNT);
        bytes[] memory signaturesList = new bytes[](COUNT);
        for (uint256 i = 0; i < COUNT; i++) {
            pubkeysList[i] = LibBytes.slice(pubkeys, i * 48, 48);
            withdrawalCredentialsList[i] = LibBytes.slice(withdrawal_credentials, i * 32, 32);
            signaturesList[i] = LibBytes.slice(signatures, i * 96, 96);
            deposit_data_roots[i] = bytes32(genBytes(32));
        }
        vm.deal(address(this), 32 ether * COUNT);

        vm.pauseGasMetering();
        IBatchDeposit vyperDeposit = IBatchDeposit(batchDeposit);
        vyperDeposit.bigBatchDeposit{value: 32 ether * COUNT}(
            pubkeys, withdrawal_credentials, signatures, deposit_data_roots
        );

        for (uint256 i; i < COUNT; i++) {
            assertEq(depositContract.depositDataRoots(i), deposit_data_roots[i]);
            assertEq(depositContract.depositPubkeys(i), pubkeysList[i]);
            assertEq(depositContract.depositWithdrawalCredentials(i), withdrawalCredentialsList[i]);
            assertEq(depositContract.depositSignatures(i), signaturesList[i]);
        }
        assertEq(address(this).balance, 0);
        assertEq(address(batchDeposit).balance, 0);
    }

    function test_batchDepositCustom_match(uint256 c, uint72 amount) public {
        setSalt(bytes32(abi.encodePacked(c)));
        c = bound(c, 1, 64);
        uint256 COUNT = uint256(c);

        console.log("COUNT", COUNT);

        bytes memory pubkeys = genBytes(48 * COUNT);
        bytes memory withdrawal_credentials = genBytes(32 * COUNT);
        bytes memory signatures = genBytes(96 * COUNT);
        bytes32[] memory deposit_data_roots = new bytes32[](COUNT);
        bytes[] memory pubkeysList = new bytes[](COUNT);
        bytes[] memory withdrawalCredentialsList = new bytes[](COUNT);
        bytes[] memory signaturesList = new bytes[](COUNT);
        for (uint256 i = 0; i < COUNT; i++) {
            pubkeysList[i] = LibBytes.slice(pubkeys, i * 48, 48);
            withdrawalCredentialsList[i] = LibBytes.slice(withdrawal_credentials, i * 32, 32);
            signaturesList[i] = LibBytes.slice(signatures, i * 96, 96);
            deposit_data_roots[i] = bytes32(genBytes(32));
        }
        vm.deal(address(this), amount * COUNT);

        vm.pauseGasMetering();
        IBatchDeposit vyperDeposit = IBatchDeposit(batchDeposit);
        vyperDeposit.batchDepositCustom{value: amount * COUNT}(
            pubkeys, withdrawal_credentials, signatures, deposit_data_roots, amount
        );

        for (uint256 i; i < COUNT; i++) {
            assertEq(depositContract.depositDataRoots(i), deposit_data_roots[i]);
            assertEq(depositContract.depositPubkeys(i), pubkeysList[i]);
            assertEq(depositContract.depositWithdrawalCredentials(i), withdrawalCredentialsList[i]);
            assertEq(depositContract.depositSignatures(i), signaturesList[i]);
        }
        assertEq(address(this).balance, 0);
        assertEq(address(batchDeposit).balance, 0);
    }

    function test_bigBatchDepositCustom_match(uint256 c, uint72 amount) public {
        setSalt(bytes32(abi.encodePacked(c)));
        c = bound(c, 1, 256);
        uint256 COUNT = uint256(c);

        console.log("COUNT", COUNT);

        bytes memory pubkeys = genBytes(48 * COUNT);
        bytes memory withdrawal_credentials = genBytes(32 * COUNT);
        bytes memory signatures = genBytes(96 * COUNT);
        bytes32[] memory deposit_data_roots = new bytes32[](COUNT);
        bytes[] memory pubkeysList = new bytes[](COUNT);
        bytes[] memory withdrawalCredentialsList = new bytes[](COUNT);
        bytes[] memory signaturesList = new bytes[](COUNT);
        for (uint256 i = 0; i < COUNT; i++) {
            pubkeysList[i] = LibBytes.slice(pubkeys, i * 48, 48);
            withdrawalCredentialsList[i] = LibBytes.slice(withdrawal_credentials, i * 32, 32);
            signaturesList[i] = LibBytes.slice(signatures, i * 96, 96);
            deposit_data_roots[i] = bytes32(genBytes(32));
        }
        vm.deal(address(this), amount * COUNT);

        vm.pauseGasMetering();
        IBatchDeposit vyperDeposit = IBatchDeposit(batchDeposit);
        vyperDeposit.bigBatchDepositCustom{value: amount * COUNT}(
            pubkeys, withdrawal_credentials, signatures, deposit_data_roots, amount
        );

        for (uint256 i; i < COUNT; i++) {
            assertEq(depositContract.depositDataRoots(i), deposit_data_roots[i]);
            assertEq(depositContract.depositPubkeys(i), pubkeysList[i]);
            assertEq(depositContract.depositWithdrawalCredentials(i), withdrawalCredentialsList[i]);
            assertEq(depositContract.depositSignatures(i), signaturesList[i]);
        }
        assertEq(address(this).balance, 0);
        assertEq(address(batchDeposit).balance, 0);
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

        IBatchDeposit(batchDeposit).batchDeposit{value: 32 ether * count}(
            concat_pubkeys, concat_withdrawal_credentials, concat_signatures, deposit_data_root_arr
        );
    }

    function performBigBatchDeposit(uint256 count) public {
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

        IBatchDeposit(batchDeposit).bigBatchDeposit{value: 32 ether * count}(
            concat_pubkeys, concat_withdrawal_credentials, concat_signatures, deposit_data_root_arr
        );
    }

    function performBatchDepositCustom(uint256 count, uint256 amount) public {
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

        IBatchDeposit(batchDeposit).batchDepositCustom{value: amount * count}(
            concat_pubkeys, concat_withdrawal_credentials, concat_signatures, deposit_data_root_arr, amount
        );
    }

    function performBigBatchDepositCustom(uint256 count, uint256 amount) public {
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

        IBatchDeposit(batchDeposit).bigBatchDepositCustom{value: amount * count}(
            concat_pubkeys, concat_withdrawal_credentials, concat_signatures, deposit_data_root_arr, amount
        );
    }
}
