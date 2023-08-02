// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IBatchDeposit {
    function batchDeposit(
        bytes calldata pubkeys,
        bytes calldata withdrawal_credentialss,
        bytes calldata signatures,
        bytes32[] calldata deposit_data_roots
    ) external payable;

    function bigBatchDeposit(
        bytes calldata pubkeys,
        bytes calldata withdrawal_credentialss,
        bytes calldata signatures,
        bytes32[] calldata deposit_data_roots
    ) external payable;

    function batchDepositCustom(
        bytes calldata pubkeys,
        bytes calldata withdrawal_credentialss,
        bytes calldata signatures,
        bytes32[] calldata deposit_data_roots,
        uint256 amount
    ) external payable;

    function bigBatchDepositCustom(
        bytes calldata pubkeys,
        bytes calldata withdrawal_credentialss,
        bytes calldata signatures,
        bytes32[] calldata deposit_data_roots,
        uint256 amount
    ) external payable;
}
