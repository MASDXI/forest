// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../libraries/UTXO.sol";
import "../interfaces/IUTXOERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract UTXOToken is ERC20, IUTXOERC20 {
    using UnspentTransactionOutput for UnspentTransactionOutput.UTXO;

    UnspentTransactionOutput.UTXO private _UTXO;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    function _transaction(
        bytes32 tokenId
    ) internal view returns (UnspentTransactionOutput.Transaction memory) {
        return _UTXO.transaction(tokenId);
    }

    function _transfer(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    ) internal virtual {
        uint256 txvalue = _UTXO.transactionValue(tokenId);
        if (txvalue < value) {
            revert UTXOERC20TransferOverTransactionValue(txvalue, value);
        }
        uint256 change = txvalue - value;
        _update(from, to, value);
        _UTXO.spendTransaction(
            UnspentTransactionOutput.TransactionInput(tokenId, signature),
            from
        );
        if (change > 0) {
            _UTXO.createTransaction(
                UnspentTransactionOutput.TransactionOutput(value, to),
                tokenId,
                UnspentTransactionOutput.calculateTransactionHash(
                    from,
                    _UTXO.transactionCount(from)
                ),
                from
            );
        }
    }

    function _mintTransaction(address account, uint256 value) internal {
        _UTXO.createTransaction(
            UnspentTransactionOutput.TransactionOutput(value, account),
            bytes32(0),
            UnspentTransactionOutput.calculateTransactionHash(
                address(0),
                _UTXO.transactionCount(address(0))
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
        if (value == _UTXO.transactionValue(tokenId)) {
            _UTXO.consumeTransaction(tokenId, account);
        } else {
            _UTXO.consumeTransaction(tokenId, account);
            _UTXO.createTransaction(
                UnspentTransactionOutput.TransactionOutput(value, address(0)),
                tokenId,
                UnspentTransactionOutput.calculateTransactionHash(
                    account,
                    _UTXO.transactionCount(account)
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
        uint256 value,
        bytes memory signature
    ) public virtual override returns (bool) {
        _transfer(msg.sender, to, tokenId, value, signature);
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

    function transferFrom(
        address from,
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    ) public virtual override returns (bool) {
        _spendAllowance(from, msg.sender, value);
        _transfer(from, to, tokenId, value, signature);
        return true;
    }
}
