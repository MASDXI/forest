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

    const contract = await ethers.getContractFactory("MockeUtxoCBDC");
    const token = await contract.deploy("United States dollar", "USD");

    return { token, owner, otherAccount };
  }

  describe("Transfers", function () {
    it("Should transfer the funds to the owner", async function () {
      const { token, owner } = await loadFixture(deployTokenFixture);
      const address = await owner.getAddress();
      await token.mint(address, 1000n, encodeBytes32String("test"));
      expect(await token.balanceOf(address)).to.equal(1000n);
    });

    it("Should transfer the funds to the owner", async function () {
      const { token, owner } = await loadFixture(deployTokenFixture);
      const address = await owner.getAddress();
      await token.mint(address, 1000n, encodeBytes32String("test"));
      expect(await token.balanceOf(address)).to.equal(1000n);
    });

    it("Should transfer the funds to the owner", async function () {
      const { token, owner, otherAccount } = await loadFixture(
        deployTokenFixture
      );
      const address = await owner.getAddress();
      const otherAddress = await otherAccount.getAddress();
      let tx = await token.mint(address, 1000n, encodeBytes32String("test"));
      tx = await tx.wait();
      const tokenId = tx.logs[0].args[0];
      const hashed = solidityPackedKeccak256(["bytes32"], [tokenId]);
      const signature = await owner.signMessage(getBytes(hashed));
      await token["transfer(address,bytes32,uint256,bytes)"](
        otherAddress,
        tokenId,
        1000n,
        signature
      );
      expect(await token.balanceOf(otherAddress)).to.equal(1000n);
    });
  });
});
