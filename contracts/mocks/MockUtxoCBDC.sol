// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../abstracts/extensions/Suspend.sol";

contract MockUtxoCBDC is Suspend {
    mapping(address => bool) private _suspends;

    modifier checkSuspender(address from, address to) {
        require(!isSuspend(from), "");
        require(!isSuspend(to), "");
        _;
    }


}