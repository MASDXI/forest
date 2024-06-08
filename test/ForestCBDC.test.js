const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const {
  encodeBytes32String,
  ZeroAddress,
  solidityPackedKeccak256,
  getBytes,
} = require("ethers");

describe("eUTXO CBDC", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployTokenFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const contract = await ethers.getContractFactory("MockForestCBDC");
    const token = await contract.deploy("United States dollar", "USD");

    return { token, owner, otherAccount };
  }

  describe("Transfers", function () {
    it("Should transfer the funds to the owner", async function () {
      // TODO
    });
  });
});
