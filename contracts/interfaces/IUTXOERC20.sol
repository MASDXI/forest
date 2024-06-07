// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUTXOERC20 is IERC20 {
    function transfer(address to, uint256 tokenId, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 tokenId, uint256 value) external returns (bool);
}