// // SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../abstracts/ForestToken.sol";
import "../abstracts/extensions/FreezeAddress.sol";
import "../abstracts/extensions/FreezeBalance.sol";
import "../abstracts/extensions/FreezeToken.sol";

contract MockTireCBDC is
    ForestToken,
    FreezeAddress,
    FreezeBalance,
    FreezeToken
{
    constructor(
        string memory name_,
        string memory symbol_
    ) ForestToken(name_, symbol_) {}

    modifier checkFrozenAddress(address from, address to) {
        if (isFrozen(from) || isFrozen(to)) {
            revert AddressFrozen();
        }
        _;
    }

    modifier checkFrozenRootOrParent(address account, bytes32 tokenId) {
        Forest.Transaction memory transaction = _transaction(account, tokenId);
        if (
            isTokenFrozen(transaction.root) || isTokenFrozen(transaction.parent)
        ) {
            revert TokenFrozen();
        }
        _;
    }

    function _transfer(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value
    )
        internal
        virtual
        override
        checkFrozenBalance(msg.sender, balanceOf(msg.sender), value)
        checkFrozenAddress(msg.sender, to)
        checkFrozenRootOrParent(msg.sender, tokenId)
        checkFrozenToken(tokenId)
    {
        /// @notice ERC20 Transfer also emit.
        super._transfer(from, to, tokenId, value);
        // emit Transfer(from, to, root, parent, value); // @TODO
    }
}
