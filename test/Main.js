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
            await nft.mint();
            await nft.mint();
            await nft.mint();
            await nft.mint();
            await nft.mint();
            await nft.mint();
            await nft.mint();
            await nft.mint();
            await nft.mint();
            await nft.setApprovalForAll(main.address, true);
            const _max_per_user = '2';
            const _nft = nft.address;
            const _nft_id = '0';
            const _price = 1e18.toString();
            const _total = 5;

            await main.create_raffle(_max_per_user, _nft, '0', _price, _total);
            await main.create_raffle(_max_per_user, _nft, '1', _price, _total);
            await main.create_raffle(_max_per_user, _nft, '2', _price, _total);
            await main.create_raffle(_max_per_user, _nft, '3', _price, _total);
            await main.create_raffle(_max_per_user, _nft, '4', _price, _total);
            await main.create_raffle(_max_per_user, _nft, '5', _price, _total);
            await main.create_raffle(_max_per_user, _nft, '6', _price, _total);
            await main.create_raffle(_max_per_user, _nft, '7', _price, _total);
            await main.create_raffle(_max_per_user, _nft, '8', _price, _total);
            await main.create_raffle(_max_per_user, _nft, '9', _price, _total);

            const raffles = await main.getActiveRaffles();
            console.log(raffles);
            const rafle_id = '0';
            await main.connect(USER1).buy(1,rafle_id, {value: _price});
            await main.connect(USER2).buy(1,rafle_id, {value: _price});
            await main.connect(USER3).buy(1,rafle_id, {value: _price});
            await main.connect(USER4).buy(1,rafle_id, {value: _price});
            await main.connect(USER5).buy(1,rafle_id, {value: _price});//
        });
    });
});
