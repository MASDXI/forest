// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "../abstracts/Suspend.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20CBDC is ERC20, Suspend {
    mapping(address => bool) private _suspends;

    modifier checkSuspender(address from, address to) {
        require(!isSuspend(from);, "");
        require(!isSuspend(to), "");
        _;
    }

    function transfer(
        to,
        value
    ) public checkSuspender(msg.sender, to) returns (bool) {
        super.transfer(to, value);
    }
}
