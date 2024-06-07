// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../libraries/UTXO.sol";
import "../interfaces/IUTXOERC20.sol";

abstract contract UTXOToken is IUTXOERC20 {
    using UnspentTransactionOutput for UnspentTransactionOutput.UTXO;

    mapping(address => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256))
        private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    UnspentTransactionOutput.UTXO private _UTXO;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // @TODO update _balances function

    function _mint(address to, uint256 value) internal virtual {
        // @TODO increase balance
        _UTXO.createTransaction(
            UnspentTransactionOutput.TransactionOutput(value, to),
            bytes32(0),
            UnspentTransactionOutput.calculateTransactionHash(
                address(0),
                _UTXO.transactionCount(address(0))
            ),
            address(0)
        );
        emit Transfer(address(0), to, value);
    }

    function _burn(
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    ) internal virtual {
        // @TODO decrese balance.
        if (value == _UTXO.transactionValue(tokenId)) {
            //     _UTXO.consumeTransaction(txInput, to, value);
        } else {
            // _UTXO.spendTransaction(txInput, to, value);
            _UTXO.createTransaction(
                UnspentTransactionOutput.TransactionOutput(value, address(0)),
                tokenId,
                UnspentTransactionOutput.calculateTransactionHash(
                    to,
                    _UTXO.transactionCount(to)
                ),
                to
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
        // _approve(owner, spender, value);
        emit Approval(owner, spender, value);
        return true;
    }

    function transfer(
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        revert ERC20TransferNotSupported();
    }

    function transfer(
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    ) public virtual override returns (bool) {
        address from = msg.sender;
        // @TODO
        // _transfer(from, to, tokenId, value);
        emit Transfer(from, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        revert ERC20TransferFromNotSupported();
    }

    function transferFrom(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    ) public virtual override returns (bool) {
        // @TODO
        // _transfer(from, to, tokenId, value);
        emit Transfer(from, to, value);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
}
