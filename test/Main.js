const {expect} = require("chai");

let nft, nft1, nft2, nft3, main;
let USER1, USER2, USER3, USER4, USER5, DEV;
describe("Main", function () {
    beforeEach(async () => {
        const [owner, user1, user2, user3, user4, user5] = await ethers.getSigners();
        DEV = owner;
        USER1 = user1;
        USER2 = user2;
        USER3 = user3;
        USER4 = user4;
        USER5 = user5;
        const MockNFT = await ethers.getContractFactory("MockNFT");
        nft = await MockNFT.deploy();
        nft1 = await MockNFT.deploy();
        nft2 = await MockNFT.deploy();
        nft3 = await MockNFT.deploy();

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

            const tokenURI = await nft.tokenURI('0');
            console.log('tokenURI', tokenURI);

            await nft.setApprovalForAll(main.address, true);
            const _max_per_user = '2';
            const _nft = nft.address;
            const _nft_id = '0';
            const _price = 20e18.toString();
            const _total = 5;
            let listing_fee = 10e18.toString();
            const royalties_recipient = '0x000000000000000000000000000000000000000a';
            const listing_fee_recipient = '0x000000000000000000000000000000000000000b';
            await main.add_nft(_nft, '10', royalties_recipient, '20', listing_fee, listing_fee_recipient, '0', "zero", "twitter.com/zero", "t.me/zero","1");
            await main.add_nft(nft1.address, '10', royalties_recipient, '20', listing_fee, listing_fee_recipient, '0', "one", "twitter.com/one", "t.me/one","1");
            await main.add_nft(nft2.address, '10', royalties_recipient, '20', listing_fee, listing_fee_recipient, '0', "two", "twitter.com/two", "t.me/two","1");
            await main.add_nft(nft3.address, '10', royalties_recipient, '20', listing_fee, listing_fee_recipient, '0', "three", "twitter.com/three", "t.me/three","1");
            const getAllNnft = await main.getAllNnft();
            console.log('getAllNnft', getAllNnft);
            for( let i in getAllNnft ){
                const nftContractAddress = getAllNnft[i];
                const nft_info = await main.properties(nftContractAddress);
                // console.log(nft_info);
                const status = nft_info.status; // 1
                const fee = nft_info.fee.toString(); // 10
                const royalties = nft_info.royalties.toString(); // 20
                const listing_fee = nft_info.listing_fee.toString()/1e18; // 10 1e18
                const name = nft_info.name; // name
                const twitter = nft_info.twitter; // twitter.com/name
                const tg = nft_info.tg; // t.me/three
                const str = `${name}, status=${status}, ${twitter}, ${tg}, fee: ${fee}%, royalties: ${royalties}%, listing_fee: ${listing_fee} CRO`;
                console.log(str);
            }

            const endtime = '3600';
            await main.create_raffle(_max_per_user, _nft, '0', _price, _total, endtime, {value: listing_fee});

            const raffle_id = '0';
            await main.connect(USER1).buy('1',raffle_id, {value: _price});
            await main.connect(USER1).buy('1',raffle_id, {value: _price});
            await main.connect(USER2).buy('1',raffle_id, {value: _price});
            await main.connect(USER3).buy('1',raffle_id, {value: _price});
            await main.connect(USER4).buy('1',raffle_id, {value: _price});

            const royalties_recipient_balance = (await main.provider.getBalance(royalties_recipient)).toString()/1e18;
            console.log('royalties_recipient_balance', royalties_recipient_balance);

            const listing_fee_recipient_balance = (await main.provider.getBalance(listing_fee_recipient)).toString()/1e18;
            console.log('listing_fee_recipient_balance', listing_fee_recipient_balance);

            const raffle = await main.raffles(raffle_id);
            console.log('winner', raffle.winner);
            console.log('raffle.users', (await main.getUsersByRaffleId(raffle_id)));
            console.log('getRafflesCreatedByUser DEV', (await main.getRafflesCreatedByUser(DEV.address)));
            console.log('getRafflesBoughtByUser USER1', (await main.getRafflesBoughtByUser(USER1.address)));
            console.log('getRafflesBoughtByUser USER2', (await main.getRafflesBoughtByUser(USER2.address)));
            console.log('getRafflesTrades', (await main.getRafflesTrades('0')));

        });
    });
});
