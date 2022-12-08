const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AucEngine", function () {
  let owner, seller, buyer, auct;

  beforeEach(async function () {
    [owner, seller, buyer] = await ethers.getSigners();

    const AucEngine = await ethers.getContractFactory("AucEngine", owner);
    auct = await AucEngine.deploy();
    await auct.deployed();
  });

  it("sets owner", async function () {
    const currentOwner = await auct.owner();
    expect(currentOwner).to.eq(owner.address);
  });

  async function getTimestamp(bn) {
    return (await ethers.provider.getBlock(bn)).timestamp;
  }

  describe("create auction", function () {
    it("create auction correctly", async function () {
      const tx = await auct.createAuction(
        ethers.utils.parseEther("0.0001"),
        3,
        "nft",
        60
      );

      const cAuction = await auct.auctions(0);

      expect(cAuction.item).to.eq("nft");

      expect(cAuction.startingPrice).to.eq(ethers.utils.parseEther("0.0001"));

      expect(cAuction.discountRate).to.eq(3);

      console.log(tx);
      const ts = await getTimestamp(tx.blockNumber);

      expect(cAuction.endsAt).to.eq(ts + 60);
    });
  });

  function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  describe("buy", function () {
    it("buying", async function () {
      await auct
        .connect(seller)
        .createAuction(ethers.utils.parseEther("0.0001"), 3, "nft", 60);

      this.timeout(5000); // 5s
      await delay(1000);

      const buyTx = await auct
        .connect(buyer)
        .buy(0, { value: ethers.utils.parseEther("0.0001") });

      const cAuction = await auct.auctions(0);
      const finalPrice = cAuction.finalPrice;
      await expect(() => buyTx).to.changeEtherBalance(
        seller,
        (finalPrice - Math.floor((finalPrice * 10) / 100)));
    });
  });
});
