// // SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../abstracts/ForestToken.sol";
import "../abstracts/extensions/FreezeBalance.sol";
import "../abstracts/extensions/Suspend.sol";
import "../abstracts/extensions/SuspendToken.sol";

contract MockTireCBDC is ForestToken, FreezeBalance, Suspend, SuspendToken {
//     mapping(address => bool) private _suspends;

    constructor(
        string memory name_,
        string memory symbol_
    ) TrieToken(name_, symbol_) {}

//     modifier checkSuspender(address from, address to) {
//         if (isSuspend(from) || isSuspend(to)) {
//             revert AddressSuspended();
//         }
//         _;
//     }

//     function transfer(
//         address to,
//         uint256 value
//     ) public override checkSuspender(msg.sender, to) returns (bool) {
//         return super.transfer(to, value);
//     }

//     function transferFrom(
//         address from,
//         address to,
//         uint256 value
//     ) public override checkSuspender(msg.sender, to) returns (bool) {
//         return super.transferFrom(from, to, value);
//     }
}
