// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../libraries/eUTXO.sol";
import "../interfaces/IUTXOERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract eUTXOToken is ERC20, IUTXOERC20 {
    using ExtendedUnspentTransactionOutput for ExtendedUnspentTransactionOutput.eUTXO;

    ExtendedUnspentTransactionOutput.eUTXO private _eUTXO;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    function _transaction(
        bytes32 tokenId
    )
        internal
        view
        returns (ExtendedUnspentTransactionOutput.Transaction memory)
    {
        return _eUTXO.transaction(tokenId);
    }

    function _minteUTXO(address account, uint256 value) internal {
        _minteUTXO(account, value, bytes32(0));
    }

    function _minteUTXO(address account, uint256 value, bytes32 data) internal {
        _eUTXO.createTransaction(
            ExtendedUnspentTransactionOutput.TransactionOutput(value, account),
            bytes32(0),
            ExtendedUnspentTransactionOutput.calculateTransactionHash(
                address(0),
                _eUTXO.transactionCount(address(0))
            ),
            address(0),
            data
        );
        _mint(account, value);
    }

    function _burneUTXO(
        address account,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    ) internal {
        if (value == _eUTXO.transactionValue(tokenId)) {
            _eUTXO.consumeTransaction(tokenId, account);
        } else {
            // _eUTXO.spendTransaction(txInput, to);
            _eUTXO.createTransaction(
                ExtendedUnspentTransactionOutput.TransactionOutput(
                    value,
                    address(account)
                ),
                tokenId,
                ExtendedUnspentTransactionOutput.calculateTransactionHash(
                    account,
                    _eUTXO.transactionCount(account)
                ),
                account,
                _eUTXO.transactionExtraData(tokenId)
            );
        }
        _burn(account, value);
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
        _transfer(from, to, value);
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
        _transfer(from, to, value);
        return true;
    }
}
