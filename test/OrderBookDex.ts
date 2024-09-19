import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("OrderBookDex", () => {
  async function deployOrderBookDex() {
    const [account1, account2, otherAccount] = await ethers.getSigners();

    const TokenA = await ethers.getContractFactory("TestERC20");
    const TokenB = await ethers.getContractFactory("TestERC20");
    const orderBookDex = await ethers.getContractFactory("OrderBookDex");

    const tokenA = await TokenA.deploy(account1.address);
    const tokenB = await TokenB.deploy(account2.address);
    const dex = await orderBookDex.deploy();

    const tokenAAddress = await tokenA.getAddress();
    const tokenBAddress = await tokenB.getAddress();
    const dexAddress = await dex.getAddress();

    return {
      tokenA,
      tokenB,
      dex,
      tokenAAddress,
      tokenBAddress,
      dexAddress,
      account1,
      account2,
      otherAccount,
    };
  }

  describe("DEX", () => {
    it("should deploy", async () => {
      const { dex, tokenAAddress, tokenBAddress } = await loadFixture(
        deployOrderBookDex
      );

      expect(await dex.getOrderCount(tokenAAddress)).to.equal(0);
      expect(await dex.getOrderCount(tokenBAddress)).to.equal(0);
    });

    it("should create an order", async () => {
      const {
        dex,
        tokenAAddress,
        tokenBAddress,
        account1,
        dexAddress,
        tokenA,
      } = await loadFixture(deployOrderBookDex);

      const offeredAmount = ethers.parseUnits("100");
      const requestedAmount = ethers.parseUnits("200");

      await tokenA.approve(dexAddress, offeredAmount);

      await dex.createOrder(
        account1.address,
        tokenAAddress,
        tokenBAddress,
        offeredAmount,
        requestedAmount
      );

      const orderCount = await dex.getOrderCount(tokenAAddress);
      const orderId = orderCount.toString();

      const order = await dex.getOrder(orderId, tokenAAddress);

      expect(orderCount).to.equal(1);
      expect(order[0]).to.equal(
        orderCount,
        "orderId should be equal to orderCount"
      );
      expect(order[1]).to.equal(
        offeredAmount,
        "offered amount should be equal"
      );
      expect(order[2]).to.equal(
        requestedAmount,
        "requested amount should be equal"
      );
      expect(order[3]).to.equal(
        account1.address,
        "recipient address should be account 1 address"
      );
      expect(order[4]).to.equal(
        account1.address,
        "creator address should be account 1 address"
      );
      expect(order[5]).to.equal(
        tokenAAddress,
        "token offered should be token A address"
      );
      expect(order[6]).to.equal(
        tokenBAddress,
        "token requested should be token B address"
      );
      expect(order[7]).to.equal(false, "isFilled should be false");
      expect(order[8]).to.equal(true, "isActive should be true");
    });

    it("should fill an order", async () => {
      const {
        dex,
        tokenAAddress,
        tokenBAddress,
        account1,
        account2,
        dexAddress,
        tokenA,
        tokenB,
      } = await loadFixture(deployOrderBookDex);

      const offeredAmount = ethers.parseUnits("100");
      const requestedAmount = ethers.parseUnits("200");

      await tokenA.approve(dexAddress, offeredAmount);

      await dex.createOrder(
        account1.address,
        tokenAAddress,
        tokenBAddress,
        offeredAmount,
        requestedAmount
      );

      const orderId = 1;

      await tokenB.connect(account2).approve(dexAddress, requestedAmount);

      await dex.connect(account2).fillOrder(orderId, tokenAAddress);

      const order = await dex.getOrder(orderId, tokenAAddress);

      expect(order[7]).to.equal(true, "isFilled should be true");
      expect(order[8]).to.equal(false, "isActive should be false");
    });
  });
});
