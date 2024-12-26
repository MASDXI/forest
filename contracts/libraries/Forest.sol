// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Forest Model Library
 * @notice Library containing data structures and functions for managing transactions within a forest-like structure.
 * @author Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)
 */
library Forest {
    /**
     * @dev Structure representing a transaction within the forest.
     */
    struct Transaction {
        bytes32 root; // Root hash of the transaction
        bytes32 parent; // Parent transaction hash
        uint256 value; // Value associated with the transaction
    }

    /*
    Scenario Overview:
    1. Initial Balances:
       - alice: 100 tokens (bank minted 100 tokens)
       - bob: 20 tokens
       - charlie: 0 tokens
    2. Transaction Steps:
       - step 1: alice transfers 25 tokens to bob.
        * hierarchy level: 1 (assume root is '0xabc')
       - step 2: alice transfers 50 tokens to charlie.
        * hierarchy level: 1
       - step 3: charlie transfers 25 tokens to bob.
        * hierarchy level: 2
       - step 4: bob transfers 25 tokens (originally from charlie) back to alice.
        * hierarchy level: 3
    3. Law Enforcement Condition:
       - If a condition enforces that transactions **after hierarchy level 1 of root '0xabc'** 
         SHOULD NOT be processed, then:
        * hierarchy level beyond 1 of '0xabc' MUST revert and fail.
        * this ensures compliance with the enforced condition.
        * Transactions at hierarchy levels 1 and 2 of '0xabc' MUST revert and fail.
        * This means Alice can spend the 25 tokens from Bob in **Step 1** (because it is within hierarchy level 1), but:
            - The **remaining 25 tokens** from **Step 2** (where Alice sends tokens to Charlie) cannot be spent, 
              as it would violate the condition for transactions before level 3.
            - Additionally, **Step 3** (where Charlie transfers 25 tokens to Bob) and 
              **Step 4** (where bob transfers 25 tokens back to alice) 
              will also fail, because these transactions occur at hierarchy levels 2 and 3, 
              respectively, and are subject to the enforcement conditions. 
            - Specifically, the system enforces that no transactions can occur at or before hierarchy level 2 
              if they violate the "before level 3" condition, which would prevent these transactions from being valid.
    */

    /**
     * @dev Structure representing an input for a transaction.
     */
    struct TransactionInput {
        bytes32 outpoint; // Identifier of the transaction output being spent
        uint256 value; // Value of the transaction input
    }

    /**
     * @dev Structure representing an output for a transaction.
     */
    struct TransactionOutput {
        uint256 value; // Value of the transaction output
        address account; // Recipient account of the transaction output
    }

    /**
     * @dev Structure representing a forest contains multiple unbalance-tree of transactions for a specific account.
     */
    struct Forest {
        mapping(address => uint256) size; // Number of transactions for each account
        mapping(address => uint256) nonces; // Nonce (transaction count) for each account
        mapping(address => mapping(bytes32 => Transaction)) trees; // Mapping of account to transaction trees
        mapping(bytes32 => uint256) hierarchy;
    }

    /**
     * @dev Event emitted when a transaction is created within the forest.
     * @param id The identifier of the transaction.
     * @param root The root hash of the transaction.
     * @param creator The address that created the transaction.
     * @param owner The address that owns the transaction.
     */
    event TransactionCreated(bytes32 indexed id, bytes32 indexed root, address indexed creator, address owner);

    /**
     * @dev Event emitted when a transaction is consumed (set to zero value) within the forest.
     * @param id The identifier of the transaction.
     */
    event TransactionConsumed(bytes32 indexed id);

    /**
     * @dev Event emitted when a transaction output is spent.
     * @param id The identifier of the transaction output.
     * @param spender The address that spent the transaction output.
     * @param value The value spent.
     */
    event TransactionSpent(bytes32 indexed id, address indexed spender, uint256 value);

    /**
     * @dev Error thrown when attempting to create an existing transaction.
     */
    error TransactionExist();

    /**
     * @dev Error thrown when attempting to interact with a non-existent transaction.
     */
    error TransactionNotExist();

    /**
     * @dev Error thrown when attempting to spend more value than available in a transaction output.
     * @param value The value of the transaction.
     * @param spend The amount being spent.
     */
    error TransactionInsufficient(uint256 value, uint256 spend);

    /**
     * @dev Error thrown when attempting to create a transaction with zero value.
     */
    error TransactionZeroValue();

    /**
     * @dev Checks if a transaction exists within an account's tree.
     * @param self The reference to the Forest storage.
     * @param account The address of the account owning the transaction.
     * @param id The identifier of the transaction.
     * @return true if the transaction exists, false otherwise.
     */
    function _transactionExist(
        Forest storage self,
        address account,
        bytes32 id
    ) private view returns (bool) {
        return self.trees[account][id].root != bytes32(0);
    }

    /**
     * @dev Calculates the root hash for a transaction within the forest.
     * @return The calculated root hash.
     */
    function calculateTransactionRootHash() internal view returns (bytes32) {
        return
            keccak256(abi.encode(block.chainid, block.number, block.timestamp));
    }

    /**
     * @dev Calculates the hash of a transaction.
     * @param creator The address that created the transaction.
     * @param nonce The nonce (transaction count) for the creator.
     * @return The calculated transaction hash.
     */
    function calculateTransactionHash(address creator, uint256 nonce) internal view returns (bytes32) {
        return keccak256(abi.encode(block.chainid, creator, nonce));
    }

    /**
     * @dev Retrieves a transaction from an account's transaction tree.
     * @param self The reference to the Forest storage.
     * @param account The address of the account owning the transaction.
     * @param id The identifier of the transaction.
     * @return The transaction details.
     */
    function transaction(
        Forest storage self,
        address account,
        bytes32 id
    ) internal view returns (Transaction memory) {
        return self.trees[account][id];
    }

    /**
     * @dev Retrieves the root hash of a transaction from an account's transaction tree.
     * @param self The reference to the Forest storage.
     * @param account The address of the account owning the transaction.
     * @param id The identifier of the transaction.
     * @return The root hash of the transaction.
     */
    function transactionRoot(
        Forest storage self,
        address account,
        bytes32 id
    ) internal view returns (bytes32) {
        return self.trees[account][id].root;
    }

    /**
     * @dev Retrieves the value of a transaction from an account's transaction tree.
     * @param self The reference to the Forest storage.
     * @param account The address of the account owning the transaction.
     * @param id The identifier of the transaction.
     * @return The value associated with the transaction.
     */
    function transactionValue(
        Forest storage self,
        address account,
        bytes32 id
    ) internal view returns (uint256) {
        return self.trees[account][id].value;
    }

    /**
     * @dev Creates a new transaction within an account's transaction tree.
     * @param self The reference to the Forest storage.
     * @param txOutput The transaction output containing value and recipient information.
     * @param root The root hash associated with the transaction.
     * @param parent The parent transaction hash.
     * @param id The identifier of the transaction.
     * @param creator The address that created the transaction.
     */
    function createTransaction(
        Forest storage self,
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
        uint256 hierarchy;
        if (root != bytes32(0x00)) {
            hierarchy = self.hierarchy[root] + 1;
        }
        self.trees[txOutput.account][id] = Transaction(
            root,
            parent,
            txOutput.value
        );
        self.nonces[creator]++;
        self.size[txOutput.account]++;

        emit TransactionCreated(id, root, creator, txOutput.account);
    }

    /**
     * @dev Spends (reduces the value of) a transaction output within an account's transaction tree.
     * @param self The reference to the Forest storage.
     * @param txInput The transaction input specifying the output being spent and its value.
     * @param account The address of the account spending the transaction.
     */
    function spendTransaction(
        Forest storage self,
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

    /**
     * @dev Consumes (sets to zero value) a transaction within an account's transaction tree.
     * @param self The reference to the Forest storage.
     * @param id The identifier of the transaction being consumed.
     * @param account The address of the account owning the transaction.
     */
    function consumeTransaction(
        Forest storage self,
        bytes32 id,
        address account
    ) internal {
        if (!_transactionExist(self, account, id)) {
            revert TransactionNotExist();
        }
        self.trees[account][id].value = 0;
        self.size[account]--;

        emit TransactionConsumed(id);
    }

    /**
     * @dev Retrieves the transaction count (nonce) for a specific account.
     * @param self The reference to the Forest storage.
     * @param account The address of the account.
     * @return The number of transactions (nonce) for the account.
     */
    function transactionCount(
        Forest storage self,
        address account
    ) internal view returns (uint256) {
        return self.nonces[account];
    }

    /**
     * @dev Retrieves the size (number of transactions) for a specific account.
     * @param self The reference to the Forest storage.
     * @param account The address of the account.
     * @return The size (number of transactions) for the account.
     */
    function size(
        Forest storage self,
        address account
    ) internal view returns (uint256) {
        return self.size[account];
    }
}
