//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

//import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Main is Ownable, IERC721Receiver {
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC721;
    uint rnd_index;
    enum STATUS {ACTIVE, FINISHED, CANCELLED}
    struct Raffle {
        uint id;
        STATUS status;
        uint max_per_user; // max raffle by user
        uint total; // raffle size
        address nft;
        uint nft_id;
        address winner;
        address[] users;
        uint users_length;
        address seller;
        uint price;
        uint amount;
        uint timestamp_soldout;

    }

    address FEE_RECIPIENT1;
    address FEE_RECIPIENT2;
    address FEE_RECIPIENT3;
    constructor() {
        FEE_RECIPIENT1 = msg.sender;
        FEE_RECIPIENT2 = msg.sender;
        FEE_RECIPIENT3 = msg.sender;
    }
    struct NFT {
        STATUS status;
        uint fee;
        uint royalties;
        address royalties_recipient;
        uint listing_fee;
        address listing_fee_recipient;
        string name;
        string twitter;
        string tg;
    }
    mapping(address => NFT) public nfts;
    address[] public all_nft;
    function manage_nft(address nft, uint fee, address royalties_recipient, uint royalties,
        uint listing_fee, address listing_fee_recipient, STATUS status,
        string memory name, string memory twitter, string memory tg) external onlyOwner{
        all_nft.push(nft);
        nfts[nft].fee = fee;
        nfts[nft].status = status;
        nfts[nft].royalties_recipient = royalties_recipient;
        nfts[nft].royalties = royalties;
        nfts[nft].listing_fee = listing_fee;
        nfts[nft].listing_fee_recipient = listing_fee_recipient;
        nfts[nft].name = name;
        nfts[nft].twitter = twitter;
        nfts[nft].tg = tg;
    }

    function setFeeRecipient(address a, address b, address c) public onlyOwner {
        FEE_RECIPIENT1 = a;
        FEE_RECIPIENT2 = b;
        FEE_RECIPIENT3 = c;
    }

    function moreRand() public view returns (uint, bytes32) {
        uint _previousBlockNumber;
        bytes32 _previousBlockHash;
        _previousBlockNumber = uint(block.number - 1);
        _previousBlockHash = bytes32(blockhash(_previousBlockNumber));
        return (_previousBlockNumber, _previousBlockHash);
    }


    Raffle[] public raffles;

    function getAllNnft() public view returns (address[] memory){
        return all_nft;
    }
    function getUsersByRaffleId(uint id) public view returns (address[] memory){
        return raffles[id].users;
    }

    function getActiveRaffles() public view returns (Raffle[] memory){
        return getRafflesByStatus(STATUS.ACTIVE);
    }

    function getFinishedRaffles() public view returns (Raffle[] memory){
        return getRafflesByStatus(STATUS.FINISHED);
    }

    function getCancelledRaffles() public view returns (Raffle[] memory){
        return getRafflesByStatus(STATUS.CANCELLED);
    }

    function getRafflesByStatus(STATUS s) public view returns (Raffle[] memory){
        uint total;
        for (uint i = 0; i < raffles.length; i++) {
            if (raffles[i].status != s)
                continue;
            total++;
        }
        Raffle[] memory r = new Raffle[](total);
        uint j;
        for (uint i = 0; i < raffles.length; i++) {
            if (raffles[i].status != s)
                continue;
            r[j++] = raffles[i];
        }
        return r;
    }

    event Create_Raffle(uint _max_per_user, address _nft, uint _nft_id, uint _price, uint _total, uint index);

    function create_raffle(uint _max_per_user, address _nft, uint _nft_id, uint _price, uint _total) public payable {
        require(_max_per_user > 0, "E1");
        require(_price > 10000, "E2");
        require(_total > 2, "E3");
        require(_nft != address(0), "E4");
        require(nfts[_nft].status != STATUS.ACTIVE, "E5");
        require( nfts[_nft].listing_fee==0 || nfts[_nft].listing_fee == msg.value, "E6");

        if( nfts[_nft].listing_fee > 0){
            nfts[_nft].listing_fee_recipient.call{value: msg.value}("");
        }

        address[] memory _users = new address[](0);
        Raffle memory raffle = Raffle({
        id : raffles.length,
        status : STATUS.ACTIVE,
        max_per_user : _max_per_user,
        total : _total,
        nft : _nft,
        nft_id : _nft_id,
        winner : address(0),
        users : _users,
        users_length : 0,
        seller : msg.sender,
        price : _price,
        amount : 0,
        timestamp_soldout : 0});

        raffles.push(raffle);

        IERC721 token = IERC721(raffle.nft);

        require(
            token.ownerOf(raffle.nft_id) == msg.sender,
            "NFT is not owned by caller"
        );
        token.safeTransferFrom(msg.sender, address(this), raffle.nft_id);
        emit Create_Raffle(_max_per_user, _nft, _nft_id, _price, _total, raffles.length - 1);
    }

    event Buy(uint amount, uint raffle_id, uint value, uint users, uint total);

    function buy(uint amount, uint raffle_id) payable public {
        Raffle storage raffle = raffles[raffle_id];
        require(raffle.status == STATUS.ACTIVE, "!ACTIVE");
        require(msg.value == raffle.price * amount, "Price incorrect");
        raffle.amount += msg.value;
        emit Buy(amount, raffle_id, msg.value, raffle.users.length, raffle.total);
        for (uint i = 0; i < amount; i ++) {
            raffle.users.push(msg.sender);
            raffle.users_length ++;
            //console.log('users=%s total=%s', raffle.users.length, raffle.total);
            if (raffle.users.length >= raffle.total) {
                _trigger(raffle_id);
                break;
            }
        }
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    event Trigger(uint raffle_id, uint amount, uint fee, uint royalties, address winner, uint number);

    function _trigger(uint raffle_id) internal {
        //console.log('trigger!');
        Raffle storage raffle = raffles[raffle_id];
        (uint _previousBlockNumber, bytes32 _previousBlockHash) = moreRand();
        uint total = raffle.users.length;
        uint256 _mod = total - 1;
        uint256 _randomNumber;
        bytes32 _structHash = keccak256(abi.encode(msg.sender, block.difficulty, gasleft(),
            block.timestamp, _previousBlockNumber, _previousBlockHash, ++rnd_index ));
        _randomNumber = uint256(_structHash);
        assembly {_randomNumber := mod(_randomNumber, _mod)}
        raffle.winner = raffle.users[_randomNumber];
        raffle.status = STATUS.FINISHED;
        raffle.timestamp_soldout = block.timestamp;
        //console.log('raffle.winner=%s _randomNumber=%s', raffle.winner, _randomNumber);
        IERC721(raffle.nft).safeTransferFrom(address(this), raffle.winner, raffle.nft_id);
        payments(raffle_id, _randomNumber);
    }

    function payments(uint raffle_id, uint _randomNumber) internal {
        Raffle storage raffle = raffles[raffle_id];
        uint total = raffle.amount;
        uint amount = 0;
        uint fee = 0;
        uint royalties = 0;
        if (nfts[raffle.nft].fee > 0) {
            fee = (total*nfts[raffle.nft].fee)/100;
            amount = total-fee;
            if (nfts[raffle.nft].royalties > 0) {
                royalties = (fee*nfts[raffle.nft].royalties)/100;
                fee -= royalties;
                nfts[raffle.nft].royalties_recipient.call{value : royalties}("");
            }

            FEE_RECIPIENT1.call{value : fee}("");
        }
        raffle.seller.call{value : amount}("");
        emit Trigger(raffle_id, amount, fee, royalties, raffle.winner, _randomNumber);
    }


    function cancel(uint raffle_id) public {
        Raffle storage raffle = raffles[raffle_id];
        require(raffle.status == STATUS.ACTIVE, "!ACTIVE");
        require(raffle.seller == msg.sender, "not owner");
        for (uint i = 0; i < raffle.users.length; i ++) {
            //console.log('i=%s total=%s', i, raffle.total);
            address user = raffle.users[i];
            user.call{value : raffle.price}("");
        }
        //
        IERC721(raffle.nft).safeTransferFrom(address(this), msg.sender, raffle.nft_id);
        raffle.status = STATUS.CANCELLED;
    }
}
