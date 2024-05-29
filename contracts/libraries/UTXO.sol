// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

///@title Unspent Transaction Output Model.
///@author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)

library ExtendedUnspentTransactionOutput {
    bytes32 constant RESERVE_ROOT = bytes32(0);

    struct Transaction {
        uint256 value;
        bool spent;
        bytes extraData;
    }

    struct TransactionInput {
        bytes32 outpoint;
        bytes signature;
    }

    struct TransactionOutput {
        uint256 value;
        address account;
    }

    struct eUTXO {
        mapping(address => uint256) size;
        mapping(address => mapping(bytes32 => Transaction)) transactions;
    }

    function _transactionExist(
        eUTXO storage utxo,
        address account,
        bytes32 id
    ) private view returns (bool) {
        return utxo.transactions[account][id].value > 0;
    }

    function _createTransaction(
        eUTXO storage utxo,
        TransactionOutput calldata txOutput,
        bytes32 id,
        bytes calldata data
    ) private {
        require(txOutput.value > 0, "zero val");
        utxo.transactions[txOutput.account][id] = Transaction(
            txOutput.value,
            false,
            data
        );
        utxo.size[txOutput.account]++;
    }

    function _spendTransaction(
        eUTXO storage utxo,
        TransactionInput calldata txInput,
        address account
    ) private {
        require(
            _transactionExist(utxo, account, txInput.outpoint),
            "tx not exist"
        );
        // require proof that owner of the input.
        utxo.transactions[account][txInput.outpoint].spent = true;
        utxo.size[account]--;
    }

    function _consumeTransaction(
        eUTXO storage utxo,
        address account,
        bytes32 id
    ) private {
        delete utxo.transactions[account][id];
        utxo.size[account]--;
    }

    function transaction(
        eUTXO storage utxo,
        address account,
        bytes32 id
    ) internal view returns (Transaction memory) {
        return utxo.transactions[account][id];
    }

    function transactionExtraData(
        eUTXO storage utxo,
        address account,
        bytes32 id
    ) internal view returns (bytes memory) {
        return utxo.transactions[account][id].extraData;
    }

    function transactionSpent(
        eUTXO storage utxo,
        address account,
        bytes32 id
    ) internal view returns (bool) {
        return utxo.transactions[account][id].spent;
    }

    function size(
        eUTXO storage utxo,
        address account
    ) internal view returns (uint256) {
        return utxo.size[account];
    }
}
