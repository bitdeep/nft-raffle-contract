//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;
//import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
contract Main is Ownable, IERC721Receiver  {
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC721;
    address FEE_RECIPIENT1;
    address FEE_RECIPIENT2;
    address FEE_RECIPIENT3;
    constructor() {
        FEE_RECIPIENT1 = msg.sender;
        FEE_RECIPIENT2 = msg.sender;
        FEE_RECIPIENT3 = msg.sender;
    }
    function setFeeRecipient(address a,address b,address c) public onlyOwner {
        FEE_RECIPIENT1 = a;
        FEE_RECIPIENT2 = b;
        FEE_RECIPIENT3 = c;
    }

    function _trigger() internal {
        /*
        (uint _previousBlockNumber, bytes32 _previousBlockHash) = moreRand();
        uint total = ticketsByLottery[lottery].length;
        uint256 _mod = total - 1;
        uint256 _randomNumber;
        bytes32 _structHash = keccak256(abi.encode(msg.sender, block.difficulty, gasleft(),
            block.timestamp, _previousBlockNumber, _previousBlockHash));
        _randomNumber = uint256(_structHash);
        assembly {_randomNumber := mod(_randomNumber, _mod)}
        */
    }

    function moreRand() public view returns (uint, bytes32) {
        uint _previousBlockNumber;
        bytes32 _previousBlockHash;
        _previousBlockNumber = uint(block.number - 1);
        _previousBlockHash = bytes32(blockhash(_previousBlockNumber));
        return (_previousBlockNumber, _previousBlockHash);
    }

    enum STATUS {ACTIVE, FINISHED}
    struct Raffle {
        STATUS status;
        uint max_per_user; // max raffle by user
        uint total; // raffle size
        address nft;
        uint nft_id;
        address winner;
        address[] users;
        address seller;
    }
    Raffle[] public raffles;
    function create_raffle(uint _max_per_user, address _nft, uint _nft_id) public {
        require(_max_per_user > 0, "E1");
        require(_nft != address(0), "E2");
        address[] memory _users = new address[](0);
        Raffle memory raffle = Raffle({
            status: STATUS.ACTIVE,
            max_per_user: _max_per_user,
            total: 0,
            nft: _nft,
            nft_id: _nft_id,
            winner: address(0),
            users: _users,
            seller: msg.sender });
        raffles.push(raffle);
        IERC721 token = IERC721(raffle.nft);
        require(
            token.ownerOf(raffle.nft_id) == msg.sender,
            "NFT is not owned by caller"
        );
        token.safeTransferFrom(msg.sender, address(this), raffle.nft_id);
    }
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
