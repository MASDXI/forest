// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../libraries/eUTXO.sol";
import "../interfaces/IUTXOERC20.sol";

abstract contract eUTXO is IUTXOERC20 {
    using ExtendedUnspentTransactionOutput for ExtendedUnspentTransactionOutput.eUTXO;

    mapping(address => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    ExtendedUnspentTransactionOutput.eUTXO private _eUTXO;

    constructor(string memory name_, string memory symbol_) {}

    // @TODO update _balances function

    function _mint(address to, uint256 value) internal virtual {
        // @TODO increase balance
        _eUTXO.createTransaction(
            ExtendedUnspentTransactionOutput.TransactionOutput(value, to),
            bytes32(0),
            ExtendedUnspentTransactionOutput.calculateTransactionHash(
                address(0),
                _eUTXO.nonce(address(0))
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
            bytes32(0),
            ExtendedUnspentTransactionOutput.calculateTransactionHash(
                address(0),
                _eUTXO.nonce(address(0))
            ),
            address(0),
            data
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
        if (value == _eUTXO.transactionValue(to, tokenId)) {
            //     decrease balance
            //     _eUTXO.consumeTransaction(txInput, to, value);
        } else {
            //     _eUTXO.spendTransaction(txInput, to, value);
            _eUTXO.createTransaction(
                ExtendedUnspentTransactionOutput.TransactionOutput(
                    value,
                    address(to)
                ),
                tokenId,
                ExtendedUnspentTransactionOutput.calculateTransactionHash(
                    to,
                    _eUTXO.nonce(to)
                ),
                to,
                _eUTXO.transactionExtraData(to, tokenId)
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

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
}
