const {expect} = require("chai");
let nft, main;
let USER1, USER2, USER3, USER4, USER5;
describe("Main", function () {
    beforeEach(async () => {
        const [owner, user1, user2, user3, user4, user5] = await ethers.getSigners();
        USER1 = user1;
        USER2 = user2;
        USER3 = user3;
        USER4 = user4;
        USER5 = user5;
        const MockNFT = await ethers.getContractFactory("MockNFT");
        nft = await MockNFT.deploy();

        const Main = await ethers.getContractFactory("Main");
        main = await Main.deploy();
    });

    describe("Test", async () => {
        it("main", async function () {

            await nft.mint();
            await nft.connect(USER1).mint();
            await nft.connect(USER2).mint();
            await nft.connect(USER3).mint();
            await nft.connect(USER4).mint();
            await nft.connect(USER5).mint();

            const index = await nft.index();
            expect(index).to.equal("6");
            await nft.setApprovalForAll(main.address, true);
            await nft.connect(USER1).setApprovalForAll(main.address, true);
            await nft.connect(USER2).setApprovalForAll(main.address, true);
            await nft.connect(USER3).setApprovalForAll(main.address, true);
            await nft.connect(USER4).setApprovalForAll(main.address, true);
            await nft.connect(USER5).setApprovalForAll(main.address, true);

            const _max_per_user = '2';
            const _nft = nft.address;
            const _nft_id = '0';
            const _price = 1e18.toString();
            const _total = 5;
            await main.create_raffle(_max_per_user, _nft, _nft_id, _price, _total);

            const rafle_id = '0';
            await main.connect(USER1).buy(1,rafle_id, {value: _price});
            await main.connect(USER2).buy(1,rafle_id, {value: _price});
            await main.connect(USER3).buy(1,rafle_id, {value: _price});
            await main.connect(USER4).buy(1,rafle_id, {value: _price});
            await main.connect(USER5).buy(1,rafle_id, {value: _price});//
        });
    });
});
