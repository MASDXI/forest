// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.8.0;

/// @title
/// @author 

import "../libraries/TrieDB.sol";
import "@openzeppelin/contracts/tokens/ERC20/IERC20.sol";

abstract contract ERC20 is IERC20 {
    using TrieDB for TrieDB.Trie;

    TrieDB.Trie private _trie;

    // TODO following ERC20 interface standard as much as possible.

}