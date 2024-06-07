// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../libraries/UTXO.sol";
import "../interfaces/IUTXOERC20.sol";

abstract contract UTXO is IUTXOERC20 {
    using UnspentTransactionOutput for UnspentTransactionOutput.UTXO;

    // @TODO ERC20 storage.
    // name
    // symbol
    // decimal
    // allowances
    mapping(address => uint256) private _balances;
    // totalSupply

    UnspentTransactionOutput.UTXO private _UTXO;

    constructor(string memory name_, string memory symbol_) {}

    function _mint(address to, uint256 value) internal virtual {
        // @TODO increase balance
        bytes32 tokenId = bytes32(0);
        _UTXO.createTransaction(
            UnspentTransactionOutput.TransactionOutput(value, to),
            tokenId,
            address(0)
        );
        emit Transfer(address(0), to, value);
    }

    function _burn(
        address to,
        uint256 tokenId,
        uint256 value
    ) internal virtual {
        // @TODO decrese balance.
        if (value == _UTXO.transactionValue(to, bytes32(tokenId))) {
            //     decrease balance
            //     _UTXO.consumeTransaction(txInput, to, value);
        } else {
            // _UTXO.spendTransaction(txInput, to, value);
            bytes32 newTokenId = bytes32(0);
            _UTXO.createTransaction(
                UnspentTransactionOutput.TransactionOutput(value, address(0)),
                newTokenId,
                msg.sender
            );
        }
        emit Transfer(to, address(0), value);
    }

    function approve(
        address spender,
        uint256 value
    ) public virtual override returns (bool) {
        address owner = msg.sender;
        // @TODO
        // approve(spender, tokenId, value);
        emit Approval(owner, spender, value);
        return true;
    }

    function transfer(
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        address from = msg.sender;
        // @TODO
        // transfer(tokenId, to, value);
        emit Transfer(from, to, value);
        return true;
    }

    function transfer(
        address to,
        uint256 tokenId,
        uint256 value
    ) public virtual override returns (bool) {
        address from = msg.sender;
        // @TODO
        emit Transfer(from, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        // @TODO
        // transfer(tokenId, to, value);
        emit Transfer(from, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 value
    ) public virtual override returns (bool) {
        // @TODO
        emit Transfer(from, to, value);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        // @TODO
        // return ;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
}
