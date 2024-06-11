// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../libraries/Forest.sol";
import "../interfaces/IForestERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract ForestToken is ERC20, IForestERC20 {
    using Forest for Forest.Tree;

    Forest.Tree private _trees;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    function _transaction(
        address account,
        bytes32 tokenId
    ) internal view returns (Forest.Node memory) {
        return _trees.transaction(account, tokenId);
    }

    function _transfer(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value
    ) internal virtual {
        uint256 txvalue = _trees.transactionValue(from, tokenId);
        _trees.spendTransaction(Forest.TransactionInput(tokenId, value), from);
        uint256 change = txvalue - value;
        _trees.createTransaction(
            Forest.TransactionOutput(value, to),
            tokenId, // @TODO root
            tokenId, // @TODO parent
            Forest.calculateTransactionHash(
                from,
                _trees.transactionCount(from)
            ),
            from
        );
        if (change == 0) {
            _trees.consumeTransaction(tokenId, from);
        }
        _update(from, to, value);
    }

    function _mintTransaction(address account, uint256 value) internal {
        _trees.createTransaction(
            Forest.TransactionOutput(value, account),
            bytes32(0),
            bytes32(0),
            Forest.calculateTransactionHash(
                address(0),
                _trees.transactionCount(address(0))
            ),
            address(0)
        );
        _mint(account, value);
    }

    function _burnTransaction(
        address account,
        bytes32 tokenId,
        uint256 value
    ) internal {
        if (value == _trees.transactionValue(account, tokenId)) {
            _trees.consumeTransaction(tokenId, account);
        } else {
            _trees.consumeTransaction(tokenId, account);
            _trees.createTransaction(
                Forest.TransactionOutput(value, address(0)),
                tokenId, // @TODO root
                tokenId, // @TODO parent
                Forest.calculateTransactionHash(
                    account,
                    _trees.transactionCount(account)
                ),
                account
            );
        }
        _burn(account, value);
    }

    // solc-ignore-next-line unused-param
    function transfer(
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        revert ERC20TransferNotSupported();
    }

    function transfer(
        address to,
        bytes32 tokenId,
        uint256 value
    ) public virtual override returns (bool) {
        _transfer(msg.sender, to, tokenId, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value
    ) public virtual override returns (bool) {
        _spendAllowance(from, msg.sender, value);
        _transfer(from, to, tokenId, value);
        return true;
    }

    // solc-ignore-next-line unused-param
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        revert ERC20TransferFromNotSupported();
    }
}
