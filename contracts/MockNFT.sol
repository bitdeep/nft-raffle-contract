//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;
//import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
contract MockNFT is ERC721Enumerable, Ownable {
    string private _baseURIPrefix = "https://localhost/";
    uint public index;
    constructor() ERC721("tNFT", "Test NFT") {

    }
    function mint() public {
        _mint(msg.sender, index++);
    }
    function _baseURI() internal view override returns (string memory) {
        return _baseURIPrefix;
    }
    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseURIPrefix = baseURI;
    }

}
