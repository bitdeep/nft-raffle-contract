const {expect} = require("chai");
let nft, main;
describe("Main", function () {
    beforeEach(async () => {
        const [owner, user] = await ethers.getSigners();

        const MockNFT = await ethers.getContractFactory("MockNFT");
        nft = await MockNFT.deploy();

        const Main = await ethers.getContractFactory("Main");
        main = await Main.deploy();
    });

    describe("Test", async () => {
        it("main", async function () {
            await nft.mint();
            const index = await nft.index();
            expect(index).to.equal("1");
            await nft.setApprovalForAll(main.address, true);

            const _max_per_user = '2';
            const _nft = nft.address;
            const _nft_id = '0';
            await main.create_raffle(_max_per_user, _nft, _nft_id);
        });


    });

});
