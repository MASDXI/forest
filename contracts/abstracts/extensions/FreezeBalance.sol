// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @notice not implementing access control.

abstract contract FreezeBalance {
    mapping(address => uint256) private _frozenBalance;

    error BalanceOverflow();
    error BalanceFrozen(uint256 balance, uint256 frozenBalance);

    event FrozenBalance(address indexed account, uint256 value);

    modifier checkFrozenBalance(
        address account,
        uint256 balance,
        uint256 value
    ) {
        if (balance < value) {
            revert BalanceOverflow();
        }
        uint256 frozenBalance = _frozenBalance[account];
        if (frozenBalance > balance - value) {
            revert BalanceFrozen(balance, frozenBalance);
        }
        _;
    }

    /// @notice clear freeze balance by passing amout '0'.
    function setFreezeBalance(address account, uint256 amount) public {
        _frozenBalance[account] = amount;
        emit FrozenBalance(account, amount);
    }

    function getFrozenBalance(address account) public view returns (uint256) {
        return _frozenBalance[account];
    }
}
