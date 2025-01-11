const {time, loadFixture} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const {anyValue} = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const {expect} = require("chai");
const {encodeBytes32String, ZeroAddress, solidityPackedKeccak256, getBytes} = require("ethers");

describe("Forest", function () {
  const transferMethod = "transfer(address,bytes32,uint256)";

  async function deployTokenFixture() {
    const [owner, otherAccount] = await ethers.getSigners();
    const contract = await ethers.getContractFactory("MockForest");
    const token = await contract.deploy("United States dollar", "USD");
    return {token, owner, otherAccount};
  }

  describe("Transfers", function () {
    it("Freeze Alice Account and transfer", async function () {
      //  TODO
    });

    it("Freeze Alice Account and transferFrom", async function () {
      //  TODO
    });

    it("Freeze Alice Balance and transfer", async function () {
      //  TODO
    });

    it("Freeze Alice Balance and transferFrom", async function () {
      //  TODO
    });

    it("Freeze Alice Token and transfer", async function () {
      //  TODO
    });

    it("Freeze Alice Token and transferFrom", async function () {
      //  TODO
    });

    it("Freeze at root and transfer", async function () {
      //  TODO
    });

    it("Freeze at root and transferFrom", async function () {
      //  TODO
    });

    it("Freeze at level and transfer", async function () {
      //  TODO
    });

    it("Freeze at level and transferFrom", async function () {
      //  TODO
    });
  });
});
