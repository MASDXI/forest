// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

///@title Unspent Transaction Output Model.
///@author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)

library UnspentTransactionOutput {
    struct Transaction {
        uint256 value;
        bool spent;
    }

    struct TransactionInput {
        bytes32 outpoint;
        bytes signature;
    }

    struct TransactionOutput {
        uint256 value;
        address account;
    }

    struct UTXO {
        mapping(address => uint256) size;
        mapping(address => mapping(bytes32 => Transaction)) transactions;
    }

    error TransactionAlreadySpent();
    error TransactionZeroValue();
    error TransactionNotExist();
    error TransactionExist();
    // error TransactionUnauthorized();

    function _transactionExist(
        UTXO storage self,
        address account,
        bytes32 id
    ) private view returns (bool) {
        return self.transactions[account][id].value > 0;
    }

    function createTransaction(
        UTXO storage self,
        TransactionOutput calldata txOutput,
        bytes32 id
    ) internal {
        if (txOutput.value == 0) {
            revert TransactionZeroValue();
        }
        if (_transactionExist(self, txOutput.account, id)) {
            revert TransactionExist();
        }
        self.transactions[txOutput.account][id] = Transaction(
            txOutput.value,
            false
        );
        unchecked {
            self.size[txOutput.account]++;
        }
    }

    function spendTransaction(
        UTXO storage self,
        TransactionInput calldata txInput,
        address account
    ) internal {
        if (!_transactionExist(self, account, txInput.outpoint)) {
            revert TransactionNotExist();
        }
        if (!transactionSpent(self, account, txInput.outpoint)) {
            revert TransactionAlreadySpent();
        }
        // require proof that owner of the input.
        // TransactionUnauthorized
        self.transactions[account][txInput.outpoint].spent = true;
        unchecked {
            self.size[account]--;
        }
    }

    function consumeTransaction(
        UTXO storage self,
        TransactionInput calldata txInput,
        address account,
        bytes32 id
    ) internal {
        if (!_transactionExist(self, account, txInput.outpoint)) {
            revert TransactionNotExist();
        }
        delete self.transactions[account][id];
        unchecked {
            self.size[account]--;
        }
    }

    function transaction(
        UTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (Transaction memory) {
        return self.transactions[account][id];
    }

    function transactionValue(
        UTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (uint256) {
        return self.transactions[account][id].value;
    }

    function transactionSpent(
        UTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (bool) {
        return self.transactions[account][id].spent;
    }

    function size(
        UTXO storage self,
        address account
    ) internal view returns (uint256) {
        return self.size[account];
    }
}
