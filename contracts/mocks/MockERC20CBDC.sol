// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20CBDC is ERC20 {
    mapping(address => bool) private _suspends;

    modifier checkSuspender(address from, address to) {
        require(!_suspends[from], "");
        require(!_suspends[to], "");
        _;
    }

    function transfer(
        to,
        value
    ) public checkSuspender(msg.sender, to) returns (bool) {
        super.transfer(to, value);
    }
}
