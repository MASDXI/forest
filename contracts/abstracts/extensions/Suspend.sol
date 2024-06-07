// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @notice not implementing access control.

abstract contract Suspend {
    mapping(address => bool) private _suspends;

    error AddressSuspended();
    error AddressNotSuspended();

    event Suspended(address indexed account, bool indexed auth);

    function _updateSuspend(address account, bool auth) private {
        _suspends[account] = auth;
    }

    function suspend(address account) public {
        if (_suspends[account]) {
            revert AddressSuspended();
        }
        _updateSuspend(account, true);

        emit Suspended(account, true);
    }

    function unsuspend(address account) public {
        if (!_suspends[account]) {
            revert AddressNotSuspended();
        }
        _updateSuspend(account, false);

        emit Suspended(account, false);
    }

    function isSuspend(address account) public view returns (bool) {
        return _suspends[account];
    }
}
