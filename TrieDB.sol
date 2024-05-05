// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

contract TrieDB {
    // @todo specification
    // - MUST be abstract contract/class for easy implement with existing tools.
    // - MUST be extenable feature freeze, expiration, or memotag for flexibilities.
    // - MUST be support backward compatibilities with ERC20 standard interface.
    // - SHOULD be execute with reasonable/affordable gas used.

    // as-in can done with existing code
    // for research paper need to adding blacklist feature, freeze suspicious
    // to-be
    // specify freeze money lenght
    // a
    // |-----|
    // |     |
    // a1   a2
    //      |-----|
    //      |    a3 (freeze)
    //      |
    //      |----------------------------|
    //      a2 (non freeze)             a4 (non freeze)

    enum TRIE_STATUS {
        INACTIVE,
        ACTIVE
    }

    struct TrieNode {
        bytes32 origin;
        TRIE_STATUS status;
        Transaction[] txChange;
    }

    struct Transaction {
        uint256 amount;
        bytes32 extraData;
    }

    mapping(bytes32 => TrieNode) public _trie;
    mapping(address => uint256) public _trieCount;

    function _hash(address account, uint256 Id) public pure returns (bytes32) {
        return bytes32(abi.encode(keccak256(abi.encode(account, Id))));
    }

    function _modifyTrie(
        address account,
        uint256 amount,
        bytes32 origin,
        bytes32 data
    ) internal {
        // require validation input
        bytes32 TrieHash = _hash(account, _trieCount[account]);
        TrieNode storage trie = _trie[TrieHash];

        if (trie.status == TRIE_STATUS.INACTIVE) {
            trie.origin = origin;
            trie.status = TRIE_STATUS.ACTIVE;
            _trieCount[account]++;
            _createOrUpdateTransaction(trie, data, amount);
        } else {
            Transaction storage lastTransaction = trie.txChange[
                trie.txChange.length - 1
            ];
            _createOrUpdateTransaction(
                trie,
                data,
                lastTransaction.amount - amount
            );
        }
    }

    function _createOrUpdateTransaction(
        TrieNode storage trie,
        bytes32 data,
        uint256 newAmount
    ) internal {
        if (newAmount != 0) {
            trie.txChange.push(Transaction(newAmount, data));
        } else {
            trie.txChange.push(Transaction(newAmount, data));
            trie.status = TRIE_STATUS.INACTIVE;
        }
    }

    function _create(
        address account,
        uint256 amount,
        bytes32 origin,
        bytes32 data
    ) public {
        _modifyTrie(account, amount, origin, data);
    }

    function transfer(address account, uint256 amount) public {
        bytes32 trieHash = _hash(msg.sender, _trieCount[msg.sender] - 1);
        TrieNode storage currentTrie = _trie[trieHash];

        // Ensure the current trie is in an active state and has enough balance
        require(
            currentTrie.status == TRIE_STATUS.ACTIVE,
            "Current trie is not active"
        );
        require(
            currentTrie.txChange.length > 0 &&
                currentTrie.txChange[currentTrie.txChange.length - 1].amount >=
                amount,
            "Insufficient balance"
        );

        // Calculate the remaining amount needed
        uint256 remainingAmount = amount;

        // Loop through tries until the remaining amount is satisfied
        // @TODO research implementing to loop through only active trie
        for (
            uint256 i = 0;
            i < _trieCount[msg.sender] && remainingAmount > 0;
            i++
        ) {
            // Load struct trie from storage
            TrieNode storage trie = _trie[_hash(msg.sender, i)];

            // Ensure the trie is in an active state before proceeding
            require(trie.status == TRIE_STATUS.ACTIVE, "Trie is not active");

            Transaction memory lastTransaction = trie.txChange.length > 0
                ? trie.txChange[trie.txChange.length - 1]
                : Transaction(0, "");
            // Check if the trie has enough balance
            if (lastTransaction.amount >= remainingAmount) {
                // If yes, modify the trie and exit the loop
                _modifyTrie(account, remainingAmount, trie.origin, "");
                _createOrUpdateTransaction(
                    trie,
                    "",
                    lastTransaction.amount - remainingAmount
                );
                remainingAmount = 0;
            } else {
                // If no, deduct the remaining balance from the trie and continue to the next trie
                _modifyTrie(account, lastTransaction.amount, trie.origin, "");
                _createOrUpdateTransaction(trie, "", 0);
                remainingAmount -= lastTransaction.amount;
            }
        }
    }

    function _spend(
        address account,
        uint256 amount,
        uint256 id,
        bytes32 data
    ) public {
        bytes32 TrieHashOrigin = _hash(msg.sender, id);
        TrieNode storage originTrie = _trie[TrieHashOrigin];
        Transaction storage lastTransaction = originTrie.txChange[
            originTrie.txChange.length - 1
        ];

        _modifyTrie(account, amount, originTrie.origin, "");
        _createOrUpdateTransaction(
            _trie[_hash(msg.sender, id)],
            data,
            lastTransaction.amount - amount
        );
    }

    function getTrie(
        bytes32 TrieId
    ) public view returns (TrieNode memory, Transaction memory) {
        TrieNode storage trieCache = _trie[TrieId];
        return (trieCache, trieCache.txChange[trieCache.txChange.length - 1]);
    }

    function getTx(bytes32 TrieId) public view returns (Transaction[] memory) {
        TrieNode storage trieCache = _trie[TrieId];
        return trieCache.txChange;
    }
}
