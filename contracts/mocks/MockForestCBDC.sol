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

    modifier checkSuspendedRoot(bytes32 tokenId) {
        // @TODO change from extraData to root or parent.
        // if (isTokenSuspend(_transaction(tokenId).extraData)) {
        //     revert TokenFrozen();
        // }
        _;
    }

    //     function transfer(
    //         address to,
    //         uint256 value
    //     ) public override checkFrozenAddress(msg.sender, to) returns (bool) {
    //         return super.transfer(to, value);
    //     }

    //     function transferFrom(
    //         address from,
    //         address to,
    //         uint256 value
    //     ) public override checkFrozenAddress(msg.sender, to) returns (bool) {
    //         return super.transferFrom(from, to, value);
    //     }
}
