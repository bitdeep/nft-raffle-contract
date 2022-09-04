//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;
//import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
contract MockNFT is ERC721Enumerable {
    uint public index;
    constructor() ERC721("MNFT", "Mock NFT") {

    }
    function mint() public {
        _mint(msg.sender, index++);
    }
}
