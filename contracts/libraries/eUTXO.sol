// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

///@title Extended Unspent Transaction Output Model.
///@author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

library ExtendedUnspentTransactionOutput {
    struct Transaction {
        bytes32 input;
        uint256 value;
        bytes32 extraData;
        address owner;
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
        mapping(address => uint256) nonces;
        mapping(bytes32 => Transaction) transactions;
    }

    event TransactionCreated(bytes32 indexed id, address indexed creator);
    event TransactionConsumed(bytes32 indexed id);
    event TransactionSpent(bytes32 indexed id, address indexed spender);

    error TransactionAlreadySpent();
    error TransactionExist();
    error TransactionNotExist();
    error TransactionUnauthorized();
    error TransactionZeroValue();

    function _transactionExist(
        eUTXO storage self,
        address account,
        bytes32 id
    ) private view returns (bool) {
        return self.transactions[id].value > 0;
    }

    function calculateTransactionHash(
        address creator,
        uint256 nonce
    ) internal view returns (bytes32) {
        uint256 chainId = block.chainid;
        return keccak256(abi.encode(chainId, creator, nonce));
    }

    function createTransaction(
        eUTXO storage self,
        TransactionOutput memory txOutput,
        bytes32 input,
        bytes32 id,
        address creator,
        bytes32 data
    ) internal {
        if (txOutput.value == 0) {
            revert TransactionZeroValue();
        }
        if (_transactionExist(self, txOutput.account, id)) {
            revert TransactionExist();
        }
        self.transactions[id] = Transaction(
            input,
            txOutput.value,
            data,
            txOutput.account,
            false
        );
        unchecked {
            self.nonces[creator]++;
            self.size[txOutput.account]++;
        }
        emit TransactionCreated(id, creator);
    }

    function spendTransaction(
        eUTXO storage self,
        TransactionInput memory txInput,
        address account
    ) internal {
        if (!_transactionExist(self, account, txInput.outpoint)) {
            revert TransactionNotExist();
        }
        if (!transactionSpent(self, account, txInput.outpoint)) {
            revert TransactionAlreadySpent();
        }
        if (ECDSA.recover(txInput.outpoint, txInput.signature) == address(0)) {
            revert TransactionUnauthorized();
        }
        self.transactions[txInput.outpoint].spent = true;
        unchecked {
            self.size[account]--;
        }
        emit TransactionSpent(txInput.outpoint, account);
    }

    function consumeTransaction(
        eUTXO storage self,
        TransactionInput memory txInput,
        address account,
        bytes32 id
    ) internal {
        if (!_transactionExist(self, account, txInput.outpoint)) {
            revert TransactionNotExist();
        }
        delete self.transactions[id];
        unchecked {
            self.size[account]--;
        }
        emit TransactionConsumed(id);
    }

    function transaction(
        eUTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (Transaction memory) {
        return self.transactions[id];
    }

    function transactionValue(
        eUTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (uint256) {
        return self.transactions[id].value;
    }

    function transactionInput(
        eUTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (bytes32) {
        return self.transactions[id].input;
    }

    function transactionExtraData(
        eUTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (bytes32) {
        return self.transactions[id].extraData;
    }

    function transactionSpent(
        eUTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (bool) {
        return self.transactions[id].spent;
    }

    function transactionOwner(
        eUTXO storage self,
        address account,
        bytes32 id
    ) internal view returns (address) {
        return self.transactions[id].owner;
    }

    function size(
        eUTXO storage self,
        address account
    ) internal view returns (uint256) {
        return self.size[account];
    }

    function nonce(
        eUTXO storage self,
        address account
    ) internal view returns (uint256) {
        return self.nonces[account];
    }
}
