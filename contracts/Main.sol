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
        uint endTime;

    }

    address feeRecipient;
    constructor() {
        feeRecipient = msg.sender;
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

    struct RaffleTrade {
        address user;
        uint raffle_id;
        uint index;
        uint price;
        uint timestamp;
    }

    mapping(address => NFT) public properties;
    address[] public all_contracts;
    uint public cancelFee = 10 ether;
    Raffle[] public raffles;
    mapping(address => uint[]) rafflesCreatedByUser;
    mapping(address => RaffleTrade[]) rafflesBoughtByUser;
    mapping(uint => RaffleTrade[]) rafflesTrades;

    event Create_Raffle(uint _max_per_user, address _nft, uint _nft_id, uint _price, uint _total, uint index, uint endTime);

    event Buy(uint amount, uint raffle_id, uint value, uint users, uint total, uint ticket);
    event Refund(address user, uint value, uint paid, uint total);

    event Trigger(uint raffle_id, uint amount, uint fee, uint royalties, address winner, uint number);
    event Revert(uint raffle_id);
    event collectFee(address user, uint listing_fee, uint fee, uint caller_fee, uint collectFee);


    function add_nft(address nft, uint fee, address royalties_recipient, uint royalties,
        uint listing_fee, address listing_fee_recipient, STATUS status,
        string memory name, string memory twitter, string memory tg, uint category) external onlyOwner {
        require(bytes(properties[nft].name).length == 0, "already exists");
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

    }

    function setFeeRecipient(address treasure) public onlyOwner {
        feeRecipient = treasure;
    }

    function moreRand() public view returns (uint, bytes32) {
        uint _previousBlockNumber;
        bytes32 _previousBlockHash;
        _previousBlockNumber = uint(block.number - 1);
        _previousBlockHash = bytes32(blockhash(_previousBlockNumber));
        return (_previousBlockNumber, _previousBlockHash);
    }

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
            if (raffles[i].nft != nft)
                continue;
            if (raffles[i].status != s)
                continue;
            total++;
        }
        Raffle[] memory r = new Raffle[](total);
        uint j;
        for (uint i = 0; i < raffles.length; i++) {
            if (raffles[i].nft != nft)
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
            if (properties[nft].category != category)
                continue;
            if (raffles[i].status != s)
                continue;
            total++;
        }
        Raffle[] memory r = new Raffle[](total);
        uint j;
        for (uint i = 0; i < raffles.length; i++) {
            address nft = raffles[i].nft;
            if (properties[nft].category != category)
                continue;
            if (raffles[i].status != s)
                continue;
            r[j++] = raffles[i];
        }
        return r;
    }

    function create_raffle(uint _max_per_user, address _nftAddr, uint _nft_id, uint _price, uint _total, uint _endTime) public payable {
        require(_max_per_user > 0, "invalid user amount");
        require(_price > 10000, "invalid price");
        require(_total > 2, "invalide slots/total");
        require(_nftAddr != address(0), "invalid nft address");
        require(properties[_nftAddr].status == STATUS.ACTIVE, "not active");
        require(msg.value >= properties[_nftAddr].listing_fee, "invalid listing fee");
        require(_endTime >= 1 hours && _endTime <= 90 days, "invalide end time");

        address[] memory _users = new address[](0);
        Raffle memory raffle = Raffle({
        id : raffles.length,
        status : STATUS.ACTIVE,
        max_per_user : _max_per_user,
        total : _total,
        nft : _nftAddr,
        nft_id : _nft_id,
        winner : address(0),
        users : _users,
        users_length : 0,
        seller : msg.sender,
        price : _price,
        amount : 0,
        endTime : block.timestamp + _endTime});

        raffles.push(raffle);
        rafflesCreatedByUser[msg.sender].push(raffle.id);

        IERC721 token = IERC721(raffle.nft);

        require(
            token.ownerOf(raffle.nft_id) == msg.sender,
            "NFT is not owned by caller"
        );
        token.safeTransferFrom(msg.sender, address(this), raffle.nft_id);
        emit Create_Raffle(_max_per_user, _nftAddr, _nft_id, _price, _total, raffles.length - 1, _endTime);

    }

    function buy(uint amount, uint raffle_id) payable public {
        Raffle storage raffle = raffles[raffle_id];
        require(raffle.status == STATUS.ACTIVE, "Raffle not active");
        require(msg.value >= raffle.price * amount, "Insufficient payment");
        require(raffle.users_length + amount <= raffle.total, "no more free slot to buy");
        require(block.timestamp <= raffle.endTime, "end time to buy expired");
        for (uint i = 0; i < amount; i ++) {
            RaffleTrade memory trade = RaffleTrade({
            user : msg.sender,
            raffle_id : raffle_id,
            index : raffle.users_length,
            price : raffle.price,
            timestamp : block.timestamp
            });

            rafflesBoughtByUser[msg.sender].push(trade);
            rafflesTrades[raffle_id].push(trade);

            raffle.users.push(msg.sender);
            raffle.users_length ++;
            raffle.amount += raffle.price;

            emit Buy(amount, raffle_id, msg.value, raffle.users_length, raffle.total, i);

        }
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    function commit(uint raffle_id) external {
        Raffle storage raffle = raffles[raffle_id];
        require(raffle.seller == msg.sender || owner() == msg.sender, "not owner or admin");
        require(raffle.status == STATUS.ACTIVE, "not active");
        // require(raffle.users.length == raffle.total, "not completed yet");
        require(block.timestamp >= raffle.endTime, "end time not expired yet");
        (uint _previousBlockNumber, bytes32 _previousBlockHash) = moreRand();
        uint256 _mod = raffle.users_length - 1;
        uint256 _randomNumber;
        bytes32 _structHash = keccak256(abi.encode(msg.sender, block.difficulty, gasleft(),
            block.timestamp, _previousBlockNumber, _previousBlockHash, ++rnd_index));
        _randomNumber = uint256(_structHash);
        assembly {_randomNumber := mod(_randomNumber, _mod)}
        raffle.winner = raffle.users[_randomNumber];
        raffle.status = STATUS.FINISHED;
        IERC721(raffle.nft).safeTransferFrom(address(this), raffle.winner, raffle.nft_id);
        _payments(raffle_id, _randomNumber);
        collectListingFee(raffle_id);
    }

    function _payments(uint raffle_id, uint _randomNumber) internal {
        Raffle storage raffle = raffles[raffle_id];
        uint amount = 0;
        uint fee = 0;
        uint royalties = 0;
        if (properties[raffle.nft].fee > 0) {
            fee = (raffle.amount * properties[raffle.nft].fee) / 100;
            amount = raffle.amount - fee;
            if (properties[raffle.nft].royalties > 0) {
                royalties = (fee * properties[raffle.nft].royalties) / 100;
                fee -= royalties;
                (bool success1,) = properties[raffle.nft].royalties_recipient.call{value : royalties}("");
                require(success1, "error paying royalties");
            }

            (bool success2,) = feeRecipient.call{value : fee}("");
            require(success2, "error paying fee");
        }
        (bool success3,) = raffle.seller.call{value : amount}("");
        require(success3, "error paying seller");
        emit Trigger(raffle_id, amount, fee, royalties, raffle.winner, _randomNumber);
    }

    function collectListingFee(uint raffle_id) internal {
        Raffle storage raffle = raffles[raffle_id];
        NFT storage nft = properties[raffle.nft];
        uint fee = nft.listing_fee;
        if (fee > 0) {
            (bool success1,) = nft.listing_fee_recipient.call{value : fee}("");
            require(success1, "error paying listing fee");
        }
    }

    // owner can cancel the raffle any time and refund everyone

    function setCancelFee(uint newFee) public onlyOwner {
        cancelFee = newFee;
    }

    function cancel(uint raffle_id) public payable {

        if (cancelFee > 0) {
            (bool success1,) = feeRecipient.call{value : msg.value}("");
            require(success1, "error paying cancel fee");
        }

        Raffle storage raffle = raffles[raffle_id];
        require(raffle.seller == msg.sender || owner() == msg.sender, "not owner or admin");
        require(raffle.status == STATUS.ACTIVE, "not active");
        for (uint i = 0; i < raffle.users.length; i ++) {
            //console.log('i=%s total=%s', i, raffle.total);
            (bool success,) = raffle.users[i].call{value : raffle.price}("");
            require(success, "error refunding user");
        }
        //
        IERC721(raffle.nft).safeTransferFrom(address(this), raffle.seller, raffle.nft_id);
        raffle.status = STATUS.EXPIRED;
        collectListingFee(raffle_id);
        emit Revert(raffle_id);
    }

    uint public _collectFee = 10;

    function setCallerFee(uint _fee) public onlyOwner {
        _collectFee = _fee;
    }

    function getRafflesCreatedByUser(address user) public view returns (uint[] memory){
        return rafflesCreatedByUser[user];
    }

    function getRafflesBoughtByUser(address user) public view returns (RaffleTrade[] memory){
        return rafflesBoughtByUser[user];
    }

    function getRafflesTrades(uint id) public view returns (RaffleTrade[] memory){
        return rafflesTrades[id];
    }
}
