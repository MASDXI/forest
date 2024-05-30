// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

///@title Extended Unspent Transaction Output Model.
///@author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)

library ExtendedUnspentTransactionOutput {
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

    error TransactionAlreadySpent();
    error TransactionZeroValue();
    error TransactionNotExist();
    error TransactionExist();
    // error TransactionUnauthorized();

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
        if (txOutput.value == 0) {
            revert TransactionZeroValue();
        }
        if (_transactionExist(utxo, txOutput.account, id)) {
            revert TransactionExist();
        }
        utxo.transactions[txOutput.account][id] = Transaction(
            txOutput.value,
            false,
            data
        );
        unchecked {
            utxo.size[txOutput.account]++;
        }
    }

    function _spendTransaction(
        eUTXO storage utxo,
        TransactionInput calldata txInput,
        address account
    ) private {
        if (!_transactionExist(utxo, account, txInput.outpoint)) {
            revert TransactionNotExist();
        }
        if (!transactionSpent(utxo, account, txInput.outpoint)) {
            revert TransactionAlreadySpent();
        }
        // require proof that owner of the input.
        // TransactionUnauthorized
        utxo.transactions[account][txInput.outpoint].spent = true;
        unchecked {
            utxo.size[account]--;
        }
    }

    function _consumeTransaction(
        eUTXO storage utxo,
        address account,
        bytes32 id
    ) private {
        if (!_transactionExist(utxo, account, txInput.outpoint)) {
            revert TransactionNotExist();
        }
        delete utxo.transactions[account][id];
        unchecked {
            utxo.size[account]--;
        }
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
