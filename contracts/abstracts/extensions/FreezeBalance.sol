// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @notice not implementing access control.

abstract contract FreezeBalance {
    mapping(address => uint256) private _frozenBalance;

    error BalanceFreezed(uint256 balance, uint256 frozenBalance);

    event Freezedbalance(address indexed account, uint256 value);

    modifier checkFrozenBalance(
        address account,
        uint256 balance,
        uint256 value
    ) {
        uint256 frozenBalance = _frozenBalance[account];
        if (frozenBalance > balance - value) {
            revert BalanceFreezed(balance, frozenBalance);
        }
        _;
    }

    /// @notice clear freeze balance by passing amout '0'.
    function setFrozenBalance(address account, uint256 amount) public {
        _frozenBalance[account] = amount;
        emit Freezedbalance(account, amount);
    }

    function getFrozenBalance(address account) public view returns (uint256) {
        return _frozenBalance[account];
    }
}
