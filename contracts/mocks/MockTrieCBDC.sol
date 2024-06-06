// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "../abstracts/Suspend.sol";

contract MockTrieCBDC is Suspend {
    mapping(address => bool) private _suspends;

    modifier checkSuspender(address from, address to) {
        require(!isSuspend(from);, "");
        require(!isSuspend(to), "");
        _;
    }


}