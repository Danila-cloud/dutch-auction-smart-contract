const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AucEngine", function () {
  let owner, seller, buyer, auct;

  beforeEach(async function () {
    [owner, seller, buyer] = await ethers.getSigners();

    const AucEngine = await ethers.getContractFactory("AucEngine", owner);
    auct = await AucEngine.deploy();
    await auct.deploy();
  });
});
