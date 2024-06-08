// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

///@title Forest Model.
///@author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)

library Forest {
    struct Node {
        bytes32 root;
        bytes32 parent;
        bool status;
        // store left leaf.
        Transaction[] transactions;
    }

    struct Transaction {
        uint256 value;
        bytes32 extraData;
    }

    struct Tree {
        mapping(address => uint256) size;
        mapping(address => uint256) nonces;
        mapping(address => mapping(bytes32 => Node)) tree;
    }

    error NodeInactive();
    error NodeZeroValue();
    error NodeNotExist();
    error NodeExist();

    function _nodeExist(
        Tree storage self,
        address account,
        bytes32 id
    ) private view returns (bool) {
        return self.tree[account][id].transactions.length > 0;
    }

    function node(
        Tree storage self,
        address account,
        bytes32 id
    ) internal view returns (Node memory) {
        return self.tree[account][id];
    }

    function nodeRoot(
        Tree storage self,
        address account,
        bytes32 id
    ) internal view returns (bytes32) {
        return self.tree[account][id].root;
    }

    function nodeStatus(
        Tree storage self,
        address account,
        bytes32 id
    ) internal view returns (bool) {
        return self.tree[account][id].status;
    }

    function transactionExtraData(
        Tree storage self,
        address account,
        bytes32 id,
        uint256 index
    ) internal view returns (bytes32) {
        return self.tree[account][id].transactions[index].extraData;
    }

    function transactionValue(
        Tree storage self,
        address account,
        bytes32 id,
        uint256 index
    ) internal view returns (uint256) {
        return self.tree[account][id].transactions[index].value;
    }

    function createTransaction(
        Tree storage self,
        Node memory node,
        address account,
        bytes32 id
    ) internal {
        if (_nodeExist(self, account, id)) {
            revert NodeExist();
        }
        self.tree[account][id] = node;
    }

    function spendTransaction(
        Tree storage self,
        Transaction memory transaction,
        address account,
        bytes32 id
    ) internal {
        if (!_nodeExist(self, account, id)) {
            revert NodeNotExist();
        }
        self.tree[account][id].transactions.push(transaction);
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
