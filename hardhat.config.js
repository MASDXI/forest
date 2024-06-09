require("hardhat-gas-reporter");
require('hardhat-ignore-warnings');
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  gasReporter: {
    enabled: true
  },
  warnings: {
    'contracts/abstracts/UTXOToken.sol': {
      'unused-param': 'off'
    },
    'contracts/abstracts/eUTXOToken.sol': {
      'unused-param': 'off'
    }
  }
};
