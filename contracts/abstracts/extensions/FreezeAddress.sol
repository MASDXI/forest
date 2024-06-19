// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

/// @notice not implementing access control.

abstract contract FreezeAddress {
    mapping(address => bool) private _frozen;

    error AddressFrozen();
    error AddressNotFrozen();

    event FrozeAddress(address indexed account, bool indexed auth);

    function _updateFreezeAddress(address account, bool auth) private {
        _frozen[account] = auth;
        emit FrozeAddress(account, auth);
    }

    function freezeAddress(address account) public {
        if (_frozen[account]) {
            revert AddressFrozen();
        }
        _updateFreezeAddress(account, true);
    }

    function unfreezeAddress(address account) public {
        if (!_frozen[account]) {
            revert AddressNotFrozen();
        }
        _updateFreezeAddress(account, false);
    }

    function isFrozen(address account) public view returns (bool) {
        return _frozen[account];
    }
}
