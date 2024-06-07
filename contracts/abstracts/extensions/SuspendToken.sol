// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @notice not implementing access control.

abstract contract SuspendToken {
    mapping(uint256 => bool) private _suspendsToken;

    function _updateSuspendToken(uint256 tokenId, bool auth) private {
        _suspendsToken[tokenId] = auth;
    }

    function suspendToken(uint256 tokenId) public {
        require(!_suspendsToken[tokenId]);
        _updateSuspendToken(tokenId, true);
        // emit
    }

    function unsuspendToken(uint256 tokenId) public {
        require(_suspendsToken[tokenId]);
        _updateSuspendToken(tokenId, false);
        // emit
    }

    function isTokenSuspend(uint256 tokenId) public view returns (bool) {
        return _suspendsToken[tokenId];
    }
}