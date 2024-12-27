// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Forest Model Library
 * @notice Library containing data structures and functions for managing txs within a forest-like structure.
 * @author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)
 */
library Forest {
    struct Tx {
        bytes32 root;
        bytes32 parent;
        uint256 value;
        uint256 level;
    }

    struct Ledger {
        mapping(address => uint256) nonces;
        mapping(bytes32 => uint256) hierarchy;
        mapping(bytes32 => Tx) txs;
    }

    event TransactionCreated(bytes32 indexed root, bytes32 id, address indexed from, address indexed to);
    event TransactionSpent(bytes32 indexed id, uint256 value);

    error TransactionNotExist();
    error TransactionInsufficient(uint256 value, uint256 spend);
    error TransactionZeroValue();

    function contains(Ledger storage self, bytes32 id) private view returns (bool) {
        return self.txs[id].value != uint256(0);
    }

    function calcTxHash(address account, uint256 nonce) internal view returns (bytes32) {
        return keccak256(abi.encode(block.chainid, account, nonce));
    }

    function getTx(Ledger storage self, bytes32 id) internal view returns (Tx memory) {
        return self.txs[id];
    }

    function getTxLevel(Ledger storage self, bytes32 id) internal view returns (uint256) {
        return self.txs[id].level;
    }

    function getTxParent(Ledger storage self, bytes32 id) internal view returns (bytes32) {
        return self.txs[id].parent;
    }

    function getTxRoot(Ledger storage self, bytes32 id) internal view returns (bytes32) {
        return self.txs[id].root;
    }

    function getTxValue(Ledger storage self, bytes32 id) internal view returns (uint256) {
        return self.txs[id].value;
    }

    function getTxCount(Ledger storage self, address account) internal view returns (uint256) {
        return self.nonces[account];
    }

    function getTxHierarchy(Ledger storage self, bytes32 id) internal view returns (uint256) {
        return self.hierarchy[id];
    }

    function createTx(Ledger storage self, Tx memory newTx, address from, address to) internal {
        if (newTx.value == 0) revert TransactionZeroValue();
        bytes32 newId = calcTxHash(from, self.nonces[from]);
        self.txs[newId] = newTx;
        unchecked {
            self.nonces[from]++;
        }

        emit TransactionCreated(newId, newTx.root, from, to);
    }

    function spendTx(Ledger storage self, bytes32 id, address from, address to, uint256 value) internal {
        Tx storage ptr = self.txs[id];
        uint256 val = ptr.value;
        if (val == 0) revert TransactionNotExist();
        if (value > val) revert TransactionInsufficient(val, value);
        ptr.value = val - value;
        bytes32 root = ptr.root;
        unchecked {
            uint256 level = (ptr.level + 1);
            createTx(self, Tx(root, id, value, level), from, to);
            if (level > self.hierarchy[id]) {
                self.hierarchy[root]++;
            }
        }

        emit TransactionSpent(id, value);
    }
}
