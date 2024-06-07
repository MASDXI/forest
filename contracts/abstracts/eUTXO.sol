// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../libraries/eUTXO.sol";
import "../interfaces/IUTXOERC20.sol";

abstract contract eUTXO is IUTXOERC20 {
    using ExtendedUnspentTransactionOutput for ExtendedUnspentTransactionOutput.eUTXO;

    // @TODO ERC20 storage.
    // name
    // symbol
    // decimal
    // allowances
    mapping(address => uint256) private _balances;
    // totalSupply

    ExtendedUnspentTransactionOutput.eUTXO private _eUTXO;

    constructor(string memory name_, string memory symbol_) {}

    function _mint(address to, uint256 value) internal virtual {
        // @TODO increase balance
        _eUTXO.createTransaction(
            ExtendedUnspentTransactionOutput.TransactionOutput(value, to),
            ExtendedUnspentTransactionOutput.calculateTransactionHash(
                address(0),
                _eUTXO.nonces[address(0)]
            ),
            address(0),
            bytes32(0)
        );
        emit Transfer(address(0), to, value);
    }

    function _mint(address to, uint256 value, bytes32 data) internal virtual {
        // @TODO increase balance
        _eUTXO.createTransaction(
            ExtendedUnspentTransactionOutput.TransactionOutput(value, to),
            ExtendedUnspentTransactionOutput.calculateTransactionHash(
                address(0),
                _eUTXO.nonces[address(0)]
            ),
            address(0),
            data
        );
        unchecked {
            _balances[to] += value;
        }
        emit Transfer(address(0), to, value);
    }

    function _burn(
        address to,
        bytes32 tokenId,
        uint256 value
    ) internal virtual {
        // @TODO decrese balance.
        if (value == _eUTXO.transactionValue(to, tokenId)) {
            //     decrease balance
            //     _eUTXO.consumeTransaction(txInput, to, value);
        } else {
            //     _eUTXO.spendTransaction(txInput, to, value);
            bytes32 newTokenId = bytes32(0);
            _eUTXO.createTransaction(
                ExtendedUnspentTransactionOutput.TransactionOutput(
                    value,
                    address(to)
                ),
                newTokenId,
                msg.sender,
                _eUTXO.transactionExtraData(to, tokenId)
            );
        }
        unchecked {
            _balances[to] -= value;
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
        // _transfer(tokenId, to, value);
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
