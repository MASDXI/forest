---
title: Smart Contract Implementation for Enhanced Traceability in Central Bank Digital Currency Systems
description: An implementation of advanced data structure over token smart contract.
author: Sirawit Techavanitch (sirawit_tec@utcc.ac.th)
status: Draft
---

<h1 align="center">
<img src="./docs/assets/Horizontal-Reforestation-through-replanting-in-mixed-forest.png" width="450"/>
</h1>

# Smart Contract Implementation for Enhanced Traceability in Central Bank Digital Currency Systems

## Abstract

// TODO  
**Keyword: Anti-Money Laundering, Blockchain, Counter Financial Terrorism, Central Bank Digital Currencies, Smart Contract**

## Introduction

In the present-day Central Bank Digital Currency concept aims to utilize the advantage point of Blockchain Technology or Distributed Ledger Technology that provides immutable, transparency, and security and adopts the smart contract which plays a key feature in creating programmable money. However, technology itself gives an advantage and eliminates the problem ideally of compliance with the regulator and AML/CFT standard, but it does not seem to be practical to be done in the real world and not in an efficient way to be responsible for the financial crime or incidents that occur in the open network of economic.

## Related Works

// Opinion: AI and Deep learning recognize and analysis the pattern but it's would be nice if the data structure also provide more efficient and fast to response to the incident.

- `ERC20` fungible token intent to be currencies like but the data structure is account-based model is hard to separate money when it's mix on total balance.
- `ERC721` not suitable due to metadata are not store onchain it's can be modified to support but it's not intent to be exchangeable.
- `ERC1155` metadata problem same as `ERC721`, however `ERC1155` can utilize tokenId as root it's can frozen the balance for each account but it end up with you can separate the money when it's store in the balance.
- `ERC3643` have characteristic same as `ERC20`
- `ERC1400` have characteristic base on from `ERC20`
- `Merkle Tree` not suitable for the payment due to it's need to maintain the root hash and generate proof every time.
- `UTXO` maintain amount of money or group of money in each individual transaction but it's not sum balance total balance.  
  // transaction reference from input transaction. B2G -> revise this
- `eUTXO` extended version of `UTXO`, purpose of `eUTXO` is to adding/carrying additional data as extraData or payload in the transaction.

## Methodology

// TODO
Introduce implementation call `Forest` used the way to modified the state to keep tracking subtree avoid to creating transaction output for change back the to spender like in `UTXO`.

## Conclusion and Evaluation

| Features                                | ERC20 | UTXO | eUTXO | Forest |
| --------------------------------------- | ----- | ---- | ----- | ------ |
| freeze the sender account.              | ✓     | ✓    | ✓     | ✓      |
| freeze the recipient account.           | ✓     | ✓    | ✓     | ✓      |
| freeze certain amount token.            | ✗     | ✓    | ✓     | ✓      |
| freeze specifics tokenId.               | ✗     | ✓    | ✓     | ✓      |
| freeze token that relevant to the root. | ✗     | ✗    | ✓     | ✓      |
| keep tracking child/subtree.            | ✗     | ✗    | ✗     | ✓      |

- For `ERC20` provide events and keep tracking each `Transfer` ,  
  but the problem is the `ERC20` model can't separate `clean money` from `dirty money`,  
  due to the`ERC20` not have `tokenId` to keep tracking each token when it's move.
- For `UTXO` and `eUTXO` facing challenge to combine multiple `UnspentTransaction` and spent as one,  
  in case user want to spend value that greater that selected `UnspentTransaction`.  
  possible solution prepare and batching as an array.
- For `Forest` use unbalance tree as a data structure.

# For Further Work

Currently `Forest` not 100% compatible with existing `ERC20` standard.

## Glossary of Terms

**AML** Anti-Money Laundering  
**B2G** Back to Genesis  
**CBDC** Central Bank Digital Currency  
**CFT** Counter Financial Terrorism  
**C2C** Customer to Customer
**DLT** Distributed Ledger Technology  
**eUTXO** Extended Transaction Output  
**KYC** Know Your Customer  
**UTXO** Unspent Transaction Output

## Reference
