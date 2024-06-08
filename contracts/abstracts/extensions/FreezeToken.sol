// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @notice not implementing access control.

abstract contract FreezeToken {
    mapping(bytes32 => bool) private _frozenToken;

    error TokenFrozen();
    error TokenNotFrozen();

    event frozenToken(bytes32 indexed tokenId, bool indexed auth);

    modifier checkFrozenToken(bytes32 tokenId) {
        if (_frozenToken[tokenId]) {
            revert TokenFrozen();
        }
        _;
    }

    function _updateSuspendToken(bytes32 tokenId, bool auth) private {
        _frozenToken[tokenId] = auth;
        emit frozenToken(tokenId, auth);
    }

    function freezeToken(bytes32 tokenId) public {
        if (_frozenToken[tokenId]) {
            revert TokenFrozen();
        }
        _updateSuspendToken(tokenId, true);
    }

    function unsfreezeToken(bytes32 tokenId) public {
        if (!_frozenToken[tokenId]) {
            revert TokenNotFrozen();
        }
        _updateSuspendToken(tokenId, false);
    }

    function isTokenSuspend(bytes32 tokenId) public view returns (bool) {
        return _frozenToken[tokenId];
    }
}
