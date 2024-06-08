// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../abstracts/eUTXOToken.sol";
import "../abstracts/extensions/FreezeBalance.sol";
import "../abstracts/extensions/Suspend.sol";
import "../abstracts/extensions/SuspendToken.sol";

contract MockeUtxoCBDC is eUTXOToken, FreezeBalance, Suspend, SuspendToken {
    mapping(address => bool) private _suspends;

    constructor(
        string memory name_,
        string memory symbol_
    ) eUTXOToken(name_, symbol_) {}

    modifier checkSuspender(address from, address to) {
        if (isSuspend(from) || isSuspend(to)) {
            revert AddressSuspended();
        }
        _;
    }

    modifier checkSuspendedRoot(bytes32 tokenId) {
        if (isTokenSuspend(_transaction(tokenId).extraData)) {
            revert TokenSuspended();
        }
        _;
    }

    function _transfer(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    )
        internal
        virtual
        override
        checkFrozenBalance(msg.sender, balanceOf(msg.sender), value)
        checkSuspender(msg.sender, to)
        checkSuspendedRoot(tokenId)
        checkSuspendedToken(tokenId)
    {
        super._transfer(from, to, tokenId, value, signature);
    }

    function mint(address account, uint256 value, bytes32 extraData) public {
        _minteUTXO(account, value, extraData);
    }
}
