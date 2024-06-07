// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUTXOERC20 is IERC20 {

    error ERC20TransferNotSupported();
    error ERC20TransferFromNotSupported();

    function transfer(address to, bytes32 tokenId, uint256 value, bytes memory signature) external returns (bool);
    function transferFrom(address from, address to, bytes32 tokenId, uint256 value, bytes memory signature) external returns (bool);
}