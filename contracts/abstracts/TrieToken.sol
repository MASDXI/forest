// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

// import "../libraries/Trie.sol";
import "../interfaces/ITrieERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// @TODO
abstract contract TrieToken is ERC20, ITrieERC20 {
    // using Trie for Trie.Trie;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    function transfer(
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        address from = msg.sender;
        // @TODO
        _transfer(from, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        // @TODO
        _transfer(from, to, value);
        return true;
    }
}
