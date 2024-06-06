// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract MockTrieCBDC {
    mapping(address => bool) private _suspends;

    modifier checkSuspender(address from, address to) {
        require(!_suspends[from], "");
        require(!_suspends[to], "");
        _;
    }


}