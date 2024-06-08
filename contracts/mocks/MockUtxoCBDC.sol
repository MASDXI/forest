// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../abstracts/UTXOToken.sol";
import "../abstracts/extensions/FreezeBalance.sol";
import "../abstracts/extensions/Suspend.sol";
import "../abstracts/extensions/SuspendToken.sol";

contract MockUtxoCBDC is UTXOToken, FreezeBalance, Suspend, SuspendToken {
    mapping(address => bool) private _suspends;

    constructor(
        string memory name_,
        string memory symbol_
    ) UTXOToken(name_, symbol_) {}

    modifier checkSuspender(address from, address to) {
        if (isSuspend(from) || isSuspend(to)) {
            revert AddressSuspended();
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
        checkSuspendedToken(tokenId)
    {
        super._transfer(from, to, tokenId, value, signature);
    }

    function mint(address account, uint256 value) public {
        _mintUTXO(account, value);
    }
}
