require("hardhat-gas-reporter");
require("hardhat-ignore-warnings");
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    }
  },
  gasReporter: {
    enabled: true,
  },
  warnings: {
    "contracts/abstracts/eUTXOToken.sol": {
      "unused-param": "off",
    },
    "contracts/abstracts/ForestToken.sol": {
      "unused-param": "off",
    },
    "contracts/abstracts/UTXOToken.sol": {
      "unused-param": "off",
    },
  },
};
