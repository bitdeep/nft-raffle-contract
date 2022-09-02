const { expect } = require("chai");
let nft;
describe("Main", function () {
  beforeEach(async () => {
    const [owner, user] = await ethers.getSigners();

    const MockNFT = await ethers.getContractFactory("MockNFT");
    nft = await MockNFT.deploy();
  });

  describe("Test", async () => {
    it("mint", async function () {
      await nft.mint();
      const index = await nft.index();
      expect(index).to.equal("1");
    });

  });

});
