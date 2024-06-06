// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

abstract contract FreezeToken {
    mapping(address => uint256) private _freezeBalance;

    function _updatefreezeBalance(address account, uint256 amount) private {
        _suspends[account] = amouth;
    }

    /// @notice clear freeze balance by passing amout '0'.
    function freezeBalance(address account, uint256 amount) public {
        _updatefreezeBalance(account, amount);
        // emit
    }

    function freezeBalance(address account) public view returns (uint256) {
        return _suspends[account];
    }
}
