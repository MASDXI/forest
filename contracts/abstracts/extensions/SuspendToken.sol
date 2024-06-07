// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @notice not implementing access control.

abstract contract SuspendToken {
    mapping(bytes32 => bool) private _suspendsToken;

    function _updateSuspendToken(bytes32 tokenId, bool auth) private {
        _suspendsToken[tokenId] = auth;
    }

    function suspendToken(bytes32 tokenId) public {
        require(!_suspendsToken[tokenId]);
        _updateSuspendToken(tokenId, true);
        // emit
    }

    function unsuspendToken(bytes32 tokenId) public {
        require(_suspendsToken[tokenId]);
        _updateSuspendToken(tokenId, false);
        // emit
    }

    function isTokenSuspend(bytes32 tokenId) public view returns (bool) {
        return _suspendsToken[tokenId];
    }
}