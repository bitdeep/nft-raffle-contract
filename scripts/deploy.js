const hre = require("hardhat");
async function main() {
  const Main = await hre.ethers.getContractFactory("Lock");
  const main = await Lock.deploy();
  await main.deployed();
  console.log(`deployed to ${main.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
