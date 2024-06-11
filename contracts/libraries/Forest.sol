// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

///@title Forest Model.
///@author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)

library Forest {
    struct Transaction {
        bytes32 root;
        bytes32 parent;
        uint256 value;
    }

    struct TransactionInput {
        bytes32 outpoint;
        uint256 value;
    }

    struct TransactionOutput {
        uint256 value;
        address account;
    }

    struct Tree {
        mapping(address => uint256) size;
        mapping(address => uint256) nonces;
        mapping(address => mapping(bytes32 => Transaction)) trees;
    }

    event TransactionCreated(
        bytes32 indexed id,
        address indexed creator,
        address indexed owner
    );
    event TransactionConsumed(bytes32 indexed id);
    event TransactionSpent(
        bytes32 indexed id,
        address indexed spender,
        uint256 value
    );

    error TransactionZeroValue();
    error TransactionNotExist();
    error TransactionExist();
    error TransactionInsufficient(uint256 value, uint256 spend);

    function _transactionExist(
        Tree storage self,
        address account,
        bytes32 id
    ) private view returns (bool) {
        return self.trees[account][id].value > 0;
    }

    function calculateTransactionHash(
        address creator,
        uint256 nonce
    ) internal view returns (bytes32) {
        uint256 chainId = block.chainid;
        return keccak256(abi.encode(chainId, creator, nonce));
    }

    function transaction(
        Tree storage self,
        address account,
        bytes32 id
    ) internal view returns (Transaction memory) {
        return self.trees[account][id];
    }

    function transactionRoot(
        Tree storage self,
        address account,
        bytes32 id
    ) internal view returns (bytes32) {
        return self.trees[account][id].root;
    }

    function transactionValue(
        Tree storage self,
        address account,
        bytes32 id
    ) internal view returns (uint256) {
        return self.trees[account][id].value;
    }

    function createTransaction(
        Tree storage self,
        TransactionOutput memory txOutput,
        bytes32 root,
        bytes32 parent,
        bytes32 id,
        address creator
    ) internal {
        if (txOutput.value == 0) {
            revert TransactionZeroValue();
        }
        if (_transactionExist(self, txOutput.account, id)) {
            revert TransactionExist();
        }
        self.trees[txOutput.account][id] = Transaction(root, parent, txOutput.value);
        self.nonces[creator]++;
        self.size[txOutput.account]++;

        emit TransactionCreated(id, creator, txOutput.account);
    }

    function spendTransaction(
        Tree storage self,
        TransactionInput memory txInput,
        address account
    ) internal {
        if (!_transactionExist(self, account, txInput.outpoint)) {
            revert TransactionNotExist();
        }
        uint256 value = self.trees[account][txInput.outpoint].value;
        if (value < txInput.value) {
            revert TransactionInsufficient(value, txInput.value);
        }
        self.trees[account][txInput.outpoint].value -= txInput.value;
        self.nonces[account]++;

        emit TransactionSpent(txInput.outpoint, account, txInput.value);
    }

    function consumeTransaction(
        Tree storage self,
        bytes32 id,
        address account
    ) internal {
        if (!_transactionExist(self, account, id)) {
            revert TransactionNotExist();
        }
        self.size[account]--;

        emit TransactionConsumed(id);
    }

    function transactionCount(
        Tree storage self,
        address account
    ) internal view returns (uint256) {
        return self.nonces[account];
    }

    function size(
        Tree storage self,
        address account
    ) internal view returns (uint256) {
        return self.size[account];
    }
}
