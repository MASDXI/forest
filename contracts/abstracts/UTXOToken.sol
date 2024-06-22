// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

import "../libraries/UTXO.sol";
import "../interfaces/IUTXOERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title UTXO Token Contract
 * @dev This contract extends ERC20 functionality to manage tokens using Unspent Transaction Output (UTXO) model.
 * It provides methods to handle token transactions using UTXO data structures.
 * Implements the IUTXOERC20 interface.
 */
abstract contract UTXOToken is ERC20, IUTXOERC20 {
    using UnspentTransactionOutput for UnspentTransactionOutput.UTXO;

    UnspentTransactionOutput.UTXO private _UTXO;

    /**
     * @dev Constructor to initialize the ERC20 token with a name and symbol.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     */
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    /**
     * @dev Internal function to fetch a transaction details based on the token ID.
     * @param tokenId The identifier of the token transaction.
     * @return A `Transaction` structure containing transaction details.
     */
    function _transaction(
        bytes32 tokenId
    ) internal view returns (UnspentTransactionOutput.Transaction memory) {
        return _UTXO.transaction(tokenId);
    }

    /**
     * @dev Internal function to execute a token transfer using an UTXO-based approach.
     * @param from The sender address.
     * @param to The recipient address.
     * @param tokenId The identifier of the token transaction.
     * @param value The amount of tokens to transfer.
     * @param signature The signature associated with the transaction.
     */
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

    /**
     * @dev Internal function to mint tokens and create a transaction for the minted tokens.
     * @param account The address that will receive the minted tokens.
     * @param value The amount of tokens to mint and transfer.
     */
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

    /**
     * @dev Internal function to burn tokens and handle the corresponding UTXO transaction.
     * @param account The address from which tokens will be burned.
     * @param tokenId The identifier of the token transaction to be burned.
     * @param value The amount of tokens to burn.
     */
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
                UnspentTransactionOutput.TransactionOutput(value, account),
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

    /**
     * @dev Function to transfer tokens (not supported in this contract).
     */
    function transfer(
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        revert ERC20TransferNotSupported();
    }

    /**
     * @inheritdoc IUTXOERC20
     */
    function transfer(
        address to,
        bytes32 tokenId,
        uint256 value,
        bytes memory signature
    ) public virtual override returns (bool) {
        _transfer(msg.sender, to, tokenId, value, signature);
        return true;
    }

    /**
     * @dev Function to transfer tokens from one address to another (not supported in this contract).
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        revert ERC20TransferFromNotSupported();
    }

    /**
     * @inheritdoc IUTXOERC20
     */
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
