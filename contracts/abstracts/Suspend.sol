// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

abstract contract Suspend {
    mapping(address => bool) private _suspends;

    function _updateSuspend(address account, bool auth) private {
        _suspends[account] = auth;
    }

    function suspend(address account) public {
        require(!_suspends[account]);
        _updateSuspend(account, true);
        // emit
    }

    function unsuspend(address account) public {
        require(_suspends[account]);
        _updateSuspend(account, false);
        // emit
    }

    function isSuspend(address account) public view returns (bool) {
        return _suspends[account];
    }
}