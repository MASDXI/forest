// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../abstracts/extensions/FreezeBalance.sol";
import "../abstracts/extensions/Suspend.sol";

contract MockERC20CBDC is ERC20, FreezeBalance, Suspend {
    mapping(address => bool) private _suspends;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    modifier checkSuspender(address from, address to) {
        if (isSuspend(from) || isSuspend(to)) {
            revert AddressSuspended();
        }
        _;
    }

    function transfer(
        address to,
        uint256 value
    )
        public
        override
        checkFrozenBalance(msg.sender, balanceOf(msg.sender), value)
        checkSuspender(msg.sender, to)
        returns (bool)
    {
        return super.transfer(to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        override
        checkFrozenBalance(msg.sender, balanceOf(msg.sender), value)
        checkSuspender(msg.sender, to)
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

    function mint(address account, uint256 value) public {
        _mint(account, value);
    }
}
