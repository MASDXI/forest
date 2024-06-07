// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @notice not implementing access control.

abstract contract SuspendToken {
    mapping(bytes32 => bool) private _suspendsToken;

    error TokenSuspended();
    error TokenNotSuspended();

    event SuspendedToken(bytes32 indexed tokenId, bool indexed auth);

    modifier checkSuspendedToken(bytes32 tokenId) {
        if (_suspendsToken[tokenId]) {
            revert TokenSuspended();
        }
        _;
    }

    function _updateSuspendToken(bytes32 tokenId, bool auth) private {
        _suspendsToken[tokenId] = auth;
    }

    function suspendToken(bytes32 tokenId) public {
        if (_suspendsToken[tokenId]) {
            revert TokenSuspended();
        }
        _updateSuspendToken(tokenId, true);

        emit SuspendedToken(tokenId, true);
    }

    function unsuspendToken(bytes32 tokenId) public {
        if (!_suspendsToken[tokenId]) {
            revert TokenNotSuspended();
        }
        _updateSuspendToken(tokenId, false);

        emit SuspendedToken(tokenId, false);
    }

    function isTokenSuspend(bytes32 tokenId) public view returns (bool) {
        return _suspendsToken[tokenId];
    }
}
