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
            const _price = 20e18.toString();
            const _total = 5;
            let listing_fee = 10e18.toString();
            const royalties_recipient = '0x000000000000000000000000000000000000000a';
            const listing_fee_recipient = '0x000000000000000000000000000000000000000b';
            await main.manage_nft(_nft, '10', royalties_recipient, '2', listing_fee, listing_fee_recipient, '1');
            const nft_info = await main.nfts(_nft);
            await main.create_raffle(_max_per_user, _nft, '0', _price, _total, {value: listing_fee});

            const raffle_id = '0';
            await main.connect(USER1).buy('1',raffle_id, {value: _price});
            await main.connect(USER2).buy('1',raffle_id, {value: _price});
            await main.connect(USER3).buy('1',raffle_id, {value: _price});
            await main.connect(USER4).buy('1',raffle_id, {value: _price});
            await main.connect(USER5).buy('1',raffle_id, {value: _price});

            const royalties_recipient_balance = (await main.provider.getBalance(royalties_recipient)).toString()/1e18;
            console.log('royalties_recipient_balance', royalties_recipient_balance);

            const listing_fee_recipient_balance = (await main.provider.getBalance(listing_fee_recipient)).toString()/1e18;
            console.log('listing_fee_recipient_balance', listing_fee_recipient_balance);

            const raffle = await main.raffles(raffle_id);
            console.log('winner', raffle.winner);
            console.log('raffle.users', (await main.getUsersByRaffleId(raffle_id)));

        });
    });
});
