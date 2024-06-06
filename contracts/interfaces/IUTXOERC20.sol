// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IUTXO.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUTXOERC20 is IERC20, IUTXO {
    function transfer(address to, uint256 tokenId, uint256 value) external returns (bool);
    function allowance(address owner, address spender, uint256 tokenId) external view returns (uint256);
    function approve(address spender, uint256 tokenId, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 tokenId, uint256 value) external returns (bool);
}