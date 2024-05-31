// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

///@title Trie Model.
///@author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)

library Trie {
    struct Node {
        bytes32 root;
        bool status;
        Transaction[] transactions;
    }

    struct Transaction {
        uint256 value;
        bytes32 extraData;
    }

    struct Trie {
        mapping(address => uint256) size;
        mapping(address => mapping(bytes32 => Node)) nodes;
    }

    error NodeInactive();
    error NodeZeroValue();
    error NodeNotExist();
    error NodeExist();

    function _nodeExist(
        Trie storage self,
        address account,
        bytes32 id
    ) private view returns (bool) {
        return self.nodes[account][id].transactions.length > 0;
    }

    function node(
        Trie storage self,
        address account,
        bytes32 id
    ) internal view returns (Node memory) {
        return self.nodes[account][id];
    }

    function nodeRoot(
        Trie storage self,
        address account,
        bytes32 id
    ) internal view returns (bytes32) {
        return self.nodes[account][id].root;
    }

    function nodeStatus(
        Trie storage self,
        address account,
        bytes32 id
    ) internal view returns (bool) {
        return self.nodes[account][id].status;
    }

    function transactionExtraData(
        Trie storage self,
        address account,
        bytes32 id,
        uint256 index
    ) internal view returns (bytes32) {
        return self.nodes[account][id].transactions[index].extraData;
    }

    function transactionValue(
        Trie storage self,
        address account,
        bytes32 id,
        uint256 index
    ) internal view returns (uint256) {
        return self.nodes[account][id].transactions[index].value;
    }

    function createTransaction(
        Trie storage self,
        Node calldata node,
        address account,
        bytes32 id
    ) internal {
        if (_nodeExist(self, account, id)) {
            revert NodeExist();
        }
        self.nodes[account][id] = node;
    }

    function spendTransaction(
        Trie storage self,
        Transaction calldata transaction,
        address account,
        bytes32 id
    ) internal {
        if (!_nodeExist(self, account, id)) {
            revert NodeNotExist();
        }
        self.nodes[account][id].transactions.push(transaction);
    }

    function size(
        Trie storage self,
        address account
    ) internal view returns (uint256) {
        return self.size[account];
    }
}
