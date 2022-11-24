require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config({path: '.env'});

task("getAllNnft", "")
    .setAction(async (taskArgs) => {
        const Main = await ethers.getContractFactory("Main")
        const main = Main.attach("0xe2fcb7d8cfec06af22f7173db77d3eb2504302f2");
        const getAllNnft = await main.getAllNnft();
        console.log('getAllNnft', getAllNnft);
    });
task("properties", "")
    .setAction(async (taskArgs) => {
        const Main = await ethers.getContractFactory("Main")
        const main = Main.attach("0xe2fcb7d8cfec06af22f7173db77d3eb2504302f2");
        const getAllNnft = await main.getAllNnft();
        for (let i in getAllNnft) {
            const nftAddr = getAllNnft[i];
            const NFT = await main.properties(nftAddr);
            console.log(nftAddr, NFT);
        }
    });

module.exports = {
    solidity: {
        compilers: [
            {
                version: '0.8.17',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    },
                },
            },
        ],
    },
    networks: {
        hardhat: {
            blockGasLimit: 12_450_000,
            hardfork: "london"
        },
        localhost: {
            url: 'http://localhost:8545',
        },
        cro: {
            url: 'https://cronosrpc-1.xstaking.sg',
            accounts: [`${process.env.PRIVATE_KEY}`]
        },
    },
};
