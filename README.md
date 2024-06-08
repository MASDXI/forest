---
title: Smart Contract Implementation for Enhanced Traceability in Central Bank Digital Currency Systems
description: An implementation of advanced data structure over token smart contract.
author: Sirawit Techavanitch (sirawit_tec@live4.utcc.ac.th)
status: Draft
---

<h1 align="center">
<img src="./docs/assets/Horizontal-Reforestation-through-replanting-in-mixed-forest.png" width="450"/>
</h1>

# Smart Contract Implementation for Enhanced Traceability in Central Bank Digital Currency Systems

## Abstract

// TODO  
keyword: Anti Money Laundering, Blockchain, Counter Financial Terrorism, Central Bank Digital Currencies, Smart Contract

## Introduction

In the present-day Central Bank Digital Currencies concept aims to utilize the advantage point of Blockchain Technology or Distributed Ledger Technology that provides immutable, transparency, and security and the smart contract that plays a key feature in creating programmable money.

However, technology itself provides an advantage and eliminates the problem ideally but it does not seem to be practical to be done in real world and not in an efficient way to responsible for the financial crime or incidents that occur in the open network of economic.

//Opinion: AI and Deep learning recognize and analysis the pattern but it's would be nice if the data structure also provide efficient and fast to response to the incident.

//Opinion: Merkle Tree not suitable for the payment due to it's need to maintain the root hash and generate proof every time.

## Methodology

// TODO
Introduce implementation call `Forest`

## Related Works

// TODO

##

## Conclusion and Evaluation

| Features                                                  | ERC20 | UTXO | eUTXO | Forest |
| --------------------------------------------------------- | ----- | ---- | ----- | ------ |
| suspends the sender.                                      | ✓     | ✓    | ✓     | ✓      |
| suspends the recipient.                                   | ✓     | ✓    | ✓     | ✓      |
| freeze certain amount token.                              | ✗     | ✓    | ✓     | ✓      |
| suspends specifics tokenId.                               | ✗     | ✓    | ✓     | ✓      |
| suspends specifics tokenId that relevant to the incident. | ✗     | ✗    | ✓     | ✓      |
| keep tracking child.                                      | ✗     | ✗    | ✗     | ✓      |

- For `ERC20` provide events and keep tracking each `Transfer` ,  
  but the problem is the `ERC20` model can't separate `clean money` from `dirty money`,  
  due to the`ERC20` not have `tokenId` to keep tracking each token when it's move.
- For `UTXO` and `eUTXO` facing challenge to combine multiple `UnspentTransaction` and spent as one,  
  in case user want to spend value that greater that selected `UnspentTransaction`.  
  possible solution prepare and batching as an array.
- For `Forest` use unbalance tree as a data structure

## Reference
