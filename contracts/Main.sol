//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

// import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Main is Ownable, IERC721Receiver {
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

    enum STATUS {ACTIVE, FINISHED, CANCELLED}
    struct Raffle {
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
    }

    Raffle[] public raffles;
    function getUsersByRaffleId(uint id) public view returns( address[] memory ){
        return raffles[id].users;
    }
    function getActiveRaffles() public view returns( Raffle[] memory ){
        return getRafflesByStatus(STATUS.ACTIVE);
    }
    function getFinishedRaffles() public view returns( Raffle[] memory ){
        return getRafflesByStatus(STATUS.FINISHED);
    }
    function getCancelledRaffles() public view returns( Raffle[] memory ){
        return getRafflesByStatus(STATUS.CANCELLED);
    }
    function getRafflesByStatus(STATUS s) public view returns( Raffle[] memory ){
        uint total;
        for( uint i = 0 ; i <raffles.length; i++ ){
            if( raffles[i].status != s)
                continue;
            total++;
        }
        Raffle[] memory r = new Raffle[](total);
        uint j;
        for( uint i = 0 ; i <raffles.length; i++ ){
            if( raffles[i].status != s)
                continue;
            r[j++] = raffles[i];
        }
        return r;
    }
    event Create_Raffle(uint _max_per_user, address _nft, uint _nft_id, uint _price, uint _total, uint index);
    function create_raffle(uint _max_per_user, address _nft, uint _nft_id, uint _price, uint _total) public {
        require(_max_per_user > 0, "E1");
        require(_nft != address(0), "E2");
        address[] memory _users = new address[](0);
        Raffle memory raffle = Raffle({
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
        amount : 0});
        raffles.push(raffle);
        IERC721 token = IERC721(raffle.nft);
        require(
            token.ownerOf(raffle.nft_id) == msg.sender,
            "NFT is not owned by caller"
        );
        token.safeTransferFrom(msg.sender, address(this), raffle.nft_id);
        emit Create_Raffle(_max_per_user, _nft,_nft_id, _price,_total, raffles.length-1 );
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

    event Trigger(uint raffle_id, uint amount, uint commission, address winner, uint number);
    function _trigger(uint raffle_id) internal {
        //console.log('trigger!');
        Raffle storage raffle = raffles[raffle_id];
        (uint _previousBlockNumber, bytes32 _previousBlockHash) = moreRand();
        uint total = raffle.users.length;
        uint256 _mod = total - 1;
        uint256 _randomNumber;
        bytes32 _structHash = keccak256(abi.encode(msg.sender, block.difficulty, gasleft(),
            block.timestamp, _previousBlockNumber, _previousBlockHash));
        _randomNumber = uint256(_structHash);
        assembly {_randomNumber := mod(_randomNumber, _mod)}
        raffle.winner = raffle.users[_randomNumber];
        raffle.status = STATUS.FINISHED;
        //console.log('raffle.winner=%s _randomNumber=%s', raffle.winner, _randomNumber);
        IERC721(raffle.nft).safeTransferFrom(address(this), raffle.winner, raffle.nft_id);

        uint amount = raffle.amount;
        uint fee = amount / 10;
        uint commission = fee / 3;
        amount -= fee;
        raffle.seller.call{value : amount}("");
        FEE_RECIPIENT1.call{value : commission}("");
        FEE_RECIPIENT2.call{value : commission}("");
        FEE_RECIPIENT3.call{value : commission}("");
        emit Trigger(raffle_id, amount, commission, raffle.winner, _randomNumber);
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
