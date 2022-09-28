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
    enum STATUS {ACTIVE, FINISHED, CANCELLED, EXPIRED}
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
        uint endtime;

    }

    address FEE_RECIPIENT1;
    constructor() {
        FEE_RECIPIENT1 = msg.sender;
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
        uint category;
    }

    mapping(address => NFT) public properties;
    address[] public all_contracts;

    function add_nft(address nft, uint fee, address royalties_recipient, uint royalties,
        uint listing_fee, address listing_fee_recipient, STATUS status,
        string memory name, string memory twitter, string memory tg, uint category) external onlyOwner {
        require(properties[nft].fee == 0, "already exists");
        all_contracts.push(nft);
        _nft(nft, fee, royalties_recipient, royalties,
            listing_fee, listing_fee_recipient, status,
            name, twitter, tg, category);
    }

    function edit_nft(address nft, uint fee, address royalties_recipient, uint royalties,
        uint listing_fee, address listing_fee_recipient, STATUS status,
        string memory name, string memory twitter, string memory tg, uint category) external onlyOwner {
        _nft(nft, fee, royalties_recipient, royalties,
            listing_fee, listing_fee_recipient, status,
            name, twitter, tg, category);
    }

    function _nft(address nft, uint fee, address royalties_recipient, uint royalties,
        uint listing_fee, address listing_fee_recipient, STATUS status,
        string memory name, string memory twitter, string memory tg, uint category) internal {
        properties[nft].fee = fee;
        properties[nft].status = status;
        properties[nft].royalties_recipient = royalties_recipient;
        properties[nft].royalties = royalties;
        properties[nft].listing_fee = listing_fee;
        properties[nft].listing_fee_recipient = listing_fee_recipient;
        properties[nft].name = name;
        properties[nft].twitter = twitter;
        properties[nft].tg = tg;
        properties[nft].category = category;

        collect_fee_from_expired();
        // process expired
    }

    function setFeeRecipient(address treasure) public onlyOwner {
        FEE_RECIPIENT1 = treasure;
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
        return all_contracts;
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

    function getRafflesByNftAndStatus(address nft, STATUS s) public view returns (Raffle[] memory){
        uint total;
        for (uint i = 0; i < raffles.length; i++) {
            if( raffles[i].nft != nft )
                continue;
            if (raffles[i].status != s)
                continue;
            total++;
        }
        Raffle[] memory r = new Raffle[](total);
        uint j;
        for (uint i = 0; i < raffles.length; i++) {
            if( raffles[i].nft != nft )
                continue;
            if (raffles[i].status != s)
                continue;
            r[j++] = raffles[i];
        }
        return r;
    }

    function getRafflesByCategory(uint category, STATUS s) public view returns (Raffle[] memory){
        uint total;
        for (uint i = 0; i < raffles.length; i++) {
            address nft = raffles[i].nft;
            if( properties[nft].category != category )
                continue;
            if (raffles[i].status != s)
                continue;
            total++;
        }
        Raffle[] memory r = new Raffle[](total);
        uint j;
        for (uint i = 0; i < raffles.length; i++) {
            address nft = raffles[i].nft;
            if( properties[nft].category != category )
                continue;
            if (raffles[i].status != s)
                continue;
            r[j++] = raffles[i];
        }
        return r;
    }

    event Create_Raffle(uint _max_per_user, address _nft, uint _nft_id, uint _price, uint _total, uint index, uint endtime);

    function create_raffle(uint _max_per_user, address _nft, uint _nft_id, uint _price, uint _total, uint _endtime) public payable {
        require(_max_per_user > 0, "E1");
        require(_price > 10000, "E2");
        require(_total > 2, "E3");
        require(_nft != address(0), "E4");
        require(properties[_nft].status != STATUS.ACTIVE, "E5");
        require(properties[_nft].listing_fee == 0 || properties[_nft].listing_fee == msg.value, "E6");
        require(_endtime >= 1 hours && _endtime <= 90 days, "E7");

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
        endtime : block.timestamp + _endtime});

        raffles.push(raffle);

        IERC721 token = IERC721(raffle.nft);

        require(
            token.ownerOf(raffle.nft_id) == msg.sender,
            "NFT is not owned by caller"
        );
        token.safeTransferFrom(msg.sender, address(this), raffle.nft_id);
        emit Create_Raffle(_max_per_user, _nft, _nft_id, _price, _total, raffles.length - 1, _endtime);

        collect_fee_from_expired();
        // process expired

    }

    event Buy(uint amount, uint raffle_id, uint value, uint users, uint total, uint ticket);
    event Refund(address user, uint value, uint paid, uint total);

    function buy(uint amount, uint raffle_id) payable public {
        Raffle storage raffle = raffles[raffle_id];
        require(raffle.status == STATUS.ACTIVE, "!ACTIVE");
        require(msg.value >= raffle.price * amount, "Price incorrect");

        uint paid = 0;
        for (uint i = 0; i < amount; i ++) {
            raffle.users.push(msg.sender);
            raffle.users_length ++;
            paid += raffle.price;
            emit Buy(amount, raffle_id, msg.value, raffle.users.length, raffle.total, i);
            //console.log('users=%s total=%s', raffle.users.length, raffle.total);
            if (raffle.users.length >= raffle.total) {
                _trigger(raffle_id);
                break;
            }
        }

        raffle.amount += paid;

        if (msg.value - paid > 0) {
            // refund user
            (bool success, bytes memory data) = msg.sender.call{value : msg.value - paid}("");
            require(success, "error refunding user.");
            emit Refund(msg.sender, msg.value, paid, msg.value - paid);
        }

        collect_fee_from_expired();
        // process expired

    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function _trigger(uint raffle_id) internal {
        //console.log('trigger!');
        Raffle storage raffle = raffles[raffle_id];
        (uint _previousBlockNumber, bytes32 _previousBlockHash) = moreRand();
        uint total = raffle.users.length;
        uint256 _mod = total - 1;
        uint256 _randomNumber;
        bytes32 _structHash = keccak256(abi.encode(msg.sender, block.difficulty, gasleft(),
            block.timestamp, _previousBlockNumber, _previousBlockHash, ++rnd_index));
        _randomNumber = uint256(_structHash);
        assembly {_randomNumber := mod(_randomNumber, _mod)}
        raffle.winner = raffle.users[_randomNumber];
        raffle.status = STATUS.FINISHED;
        //console.log('raffle.winner=%s _randomNumber=%s', raffle.winner, _randomNumber);
        IERC721(raffle.nft).safeTransferFrom(address(this), raffle.winner, raffle.nft_id);
        payments(raffle_id, _randomNumber);
        collect_fee(raffle_id);
    }

    event Trigger(uint raffle_id, uint amount, uint fee, uint royalties, address winner, uint number);

    function payments(uint raffle_id, uint _randomNumber) internal {
        Raffle storage raffle = raffles[raffle_id];
        uint total = raffle.amount;
        uint amount = 0;
        uint fee = 0;
        uint royalties = 0;
        if (properties[raffle.nft].fee > 0) {
            fee = (total * properties[raffle.nft].fee) / 100;
            amount = total - fee;
            if (properties[raffle.nft].royalties > 0) {
                royalties = (fee * properties[raffle.nft].royalties) / 100;
                fee -= royalties;
                (bool success, bytes memory data) = properties[raffle.nft].royalties_recipient.call{value : royalties}("");
                require(success, "error paying royalties");
            }

            (bool success, bytes memory data) = FEE_RECIPIENT1.call{value : fee}("");
            require(success, "error paying fee");
        }
        (bool success, bytes memory data) = raffle.seller.call{value : amount}("");
        require(success, "error paying seller");
        emit Trigger(raffle_id, amount, fee, royalties, raffle.winner, _randomNumber);
    }

    // owner can cancel the raffle any time and refund everyone

    function setCancelFee(address newFee) public onlyOwner {
        cancelFee = newFee;
    }
    uint public cancelFee = 10 ether;
    function cancel(uint raffle_id) public payable {

        if( cancelFee > 0 ){
            (bool success1, bytes memory data1) = FEE_RECIPIENT1.call{value : msg.value}("");
            require(success1, "error paying cancel fee");
        }

        Raffle storage raffle = raffles[raffle_id];
        require(raffle.seller == msg.sender, "not owner");
        _revert(raffle_id);
    }


    event Revert(uint raffle_id);

    function _revert(uint raffle_id) internal {
        Raffle storage raffle = raffles[raffle_id];
        require(raffle.status == STATUS.ACTIVE, "!ACTIVE");
        for (uint i = 0; i < raffle.users.length; i ++) {
            //console.log('i=%s total=%s', i, raffle.total);
            (bool success, bytes memory data) = raffle.users[i].call{value : raffle.price}("");
            require(success, "error refunding user");
        }
        //
        IERC721(raffle.nft).safeTransferFrom(address(this), msg.sender, raffle.nft_id);
        raffle.status = STATUS.EXPIRED;
        collect_fee(raffle_id);
        emit Revert(raffle_id);
    }

    uint public _collectFee = 10;

    function setCallerFee(uint _fee) public onlyOwner {
        _collectFee = _fee;
    }

    event collectFee(address user, uint listing_fee, uint fee, uint caller_fee, uint collectFee);

    function collect_fee(uint raffle_id) internal {
        Raffle storage raffle = raffles[raffle_id];
        NFT storage nft = properties[raffle.nft];
        uint fee = nft.listing_fee;
        if (fee > 0) {
            uint caller_fee = (fee * _collectFee) / 100;
            fee -= caller_fee;
            (bool success1, bytes memory data1) = nft.listing_fee_recipient.call{value : fee}("");
            require(success1, "error paying listing fee");
            (bool success2, bytes memory data2) = msg.sender.call{value : caller_fee}("");
            require(success2, "error paying sender");
            emit collectFee(msg.sender, nft.listing_fee, fee, caller_fee, _collectFee);
        }
    }

    function collect_fee_from_expired() public {
        for (uint raffle_id = 0; raffle_id < raffles.length; raffle_id++) {
            Raffle storage raffle = raffles[raffle_id];
            if (raffle.status != STATUS.ACTIVE)
                continue;
            if (block.timestamp < raffle.endtime)
                continue;
            _revert(raffle_id);
        }
    }

    // how much is fee available to collect?
    function amount_fee_from_expired() public view returns (uint) {
        uint total;
        for (uint raffle_id = 0; raffle_id < raffles.length; raffle_id++) {
            Raffle storage raffle = raffles[raffle_id];
            if (raffle.status != STATUS.ACTIVE)
                continue;
            if (block.timestamp < raffle.endtime)
                continue;
            NFT storage nft = properties[raffle.nft];
            total += (nft.listing_fee * _collectFee) / 100;
        }
        return total;
    }
}
