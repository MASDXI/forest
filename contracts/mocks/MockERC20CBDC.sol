// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../abstracts/extensions/Suspend.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20CBDC is ERC20, Suspend {
    mapping(address => bool) private _suspends;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    modifier checkSuspender(address from, address to) {
        require(!isSuspend(from), "");
        require(!isSuspend(to), "");
        _;
    }

    function transfer(
        address to,
        uint256 value
    ) public override checkSuspender(msg.sender, to) returns (bool) {
        return super.transfer(to, value);
    }
}
