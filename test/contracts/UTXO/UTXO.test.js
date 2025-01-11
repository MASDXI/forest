const {time, loadFixture} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const {network} = require("hardhat");
const {anyValue} = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const {expect} = require("chai");
const {encodeBytes32String, ZeroAddress, solidityPackedKeccak256, getBytes, isBytesLike, ZeroHash} = require("ethers");

describe("UTXO", function () {
  const amount = 1000n;
  const freezeAmount = 100n;
  const overloadTransferMethod = "transfer(address,bytes32,uint256,bytes)";
  const overloadTransferFromMethod = "transferFrom(address,address,bytes32,uint256,bytes)";

  async function deployTokenFixture() {
    const [owner, alice, bob, charlie, otherAccount] = await ethers.getSigners();
    const contract = await ethers.getContractFactory("MockUtxo");
    const token = await contract.deploy("United States dollar", "USD");
    return {token, owner, alice, bob, charlie, otherAccount};
  }

  describe("Scenarios", function () {
    it("transfer Alice to Bob", async function () {
      const {token, alice, bob} = await loadFixture(deployTokenFixture);
      const aliceAddress = alice.address;
      const bobAddress = bob.address;
      let tx = await token.mint(aliceAddress, amount);
      tx = await tx.wait();
      const tokenId = tx.logs[0].args[0];
      const hashed = solidityPackedKeccak256(["bytes32"], [tokenId]);
      const signature = await alice.signMessage(getBytes(hashed));
      expect(await token.balanceOf(aliceAddress)).to.equal(amount);
      await token.connect(alice)[overloadTransferMethod](bobAddress, tokenId, amount, signature);
      expect(await token.balanceOf(aliceAddress)).to.equal(0);
      expect(await token.balanceOf(bobAddress)).to.equal(amount);
    });
      
    it("transferFrom Alice to Bob", async function () {
      const {token, owner, alice, bob} = await loadFixture(deployTokenFixture);
      const spenderAddress = owner.address;
      const aliceAddress = alice.address;
      const bobAddress = bob.address;
      let tx = await token.mint(aliceAddress, amount);
      tx = await tx.wait();
      const tokenId = tx.logs[0].args[0];
      const hashed = solidityPackedKeccak256(["bytes32"], [tokenId]);
      const signature = await alice.signMessage(getBytes(hashed));
      await token.connect(alice).approve(spenderAddress, amount);
      expect(await token.balanceOf(aliceAddress)).to.equal(amount);
      await token.connect(owner)[overloadTransferFromMethod](aliceAddress, bobAddress, tokenId, amount, signature);
      expect(await token.balanceOf(aliceAddress)).to.equal(0);
      expect(await token.balanceOf(bobAddress)).to.equal(amount);
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
  });

  // describe("Restrict", function () {
  //   it("Should restrict transfer the funds to the other account by frozen tokenId", async function () {
  //     const {token, owner, otherAccount} = await loadFixture(deployTokenFixture);
  //     const address = await owner.getAddress();
  //     const otherAddress = await otherAccount.getAddress();
  //     let tx = await token.mint(address, 1000n);
  //     tx = await tx.wait();
  //     let tokenId = tx.logs[0].args[0];
  //     let hashed = solidityPackedKeccak256(["bytes32"], [tokenId]);
  //     let signature = await owner.signMessage(getBytes(hashed));
  //     tx = await token["transfer(address,bytes32,uint256,bytes)"](otherAddress, tokenId, 100n, signature);
  //     tx = await tx.wait();
  //     tokenId = tx.logs[1].args[0];
  //     hashed = solidityPackedKeccak256(["bytes32"], [tokenId]);
  //     signature = await otherAccount.signMessage(getBytes(hashed));
  //     expect(await token.balanceOf(otherAddress)).to.equal(100n);
  //     await token.freezeToken(tokenId);
  //     await expect(
  //       token.connect(otherAccount)["transfer(address,bytes32,uint256,bytes)"](address, tokenId, 10n, signature),
  //     ).to.be.revertedWithCustomError(token, "TokenFrozen");
  //   });
  // });
});
