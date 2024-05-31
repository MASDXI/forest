// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

///@title Extended Unspent Transaction Output Model.
///@author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)

library ExtendedUnspentTransactionOutput {
    struct Transaction {
        uint256 value;
        bytes32 extraData;
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
        eUTXO storage self,
        address account,
        bytes32 id
    ) private view returns (bool) {
        return self.transactions[account][id].value > 0;
    }

    function createTransaction(
        eUTXO storage self,
        TransactionOutput calldata txOutput,
        bytes32 id,
        bytes32 data
    ) internal {
        if (txOutput.value == 0) {
            revert TransactionZeroValue();
        }
        if (_transactionExist(self, txOutput.account, id)) {
            revert TransactionExist();
        }
        self.transactions[txOutput.account][id] = Transaction(
            txOutput.value,
            data,
            false
        );
        unchecked {
            self.size[txOutput.account]++;
        }
    }

    function spendTransaction(
        eUTXO storage self,
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
        eUTXO storage self,
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
        eUTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (Transaction memory) {
        return self.transactions[account][id];
    }

    function transactionValue(
        eUTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (uint256) {
        return self.transactions[account][id].value;
    }

    function transactionExtraData(
        eUTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (bytes32) {
        return self.transactions[account][id].extraData;
    }

    function transactionSpent(
        eUTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (bool) {
        return self.transactions[account][id].spent;
    }

    function size(
        eUTXO storage self,
        address account
    ) internal view returns (uint256) {
        return self.size[account];
    }
}
