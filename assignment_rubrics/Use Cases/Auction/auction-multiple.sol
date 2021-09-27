pragma solidity >=0.5.5;

/*
* This class is an example smart contract that is used to conduct auctions.
* It is meant to be an example contract to discuss which properties of
* a smart contract should be verified. It is not necessarily meant to be
* executable.
*
* Participants are stored on the ledger. They can bid for items that are
* being auctioned, and initiate auctions for items they own.
* Any item to be sold or bought within this application has to be recorded in the ledger.
* The contract does not transfer funds or goods directly; rather, it can be seen as
* regulating and recording ownership and payment obligations.
*/

contract MultipleAuctions {
    // Handling mode of the auction
    enum AuctionMode { Open, Closed }    

    // Handling auction information
    struct AuctionInformation {
        bool registered;
        
        AuctionMode mode;
        address payable owner;
        uint closingTime;

        address payable bidder;
        uint bid;
    }

    // State of auctions
    mapping (uint => AuctionInformation) private auctions;

    // Withdrawable balances
    mapping (address => uint) withdrawableBalances;


    // Modifier to check mode of auction
    modifier auctionInMode(uint _auction_id, AuctionMode _auctionMode) {
        require (auctions[_auction_id].registered);
        require (auctions[_auction_id].mode == _auctionMode);
        _;
    }

    modifier byOwner(uint _auction_id) {
        require (msg.sender == auctions[_auction_id].owner);
        _;
    }

    modifier notByOwner(uint _auction_id) {
        require (msg.sender != auctions[_auction_id].owner);
        _;
    }


    constructor (address payable _owner) 
        public
    {
    }

    function registerAuction(uint _auction_id, uint _closingTime) 
        public
    {
        require(!auctions[_auction_id].registered);
        require (_closingTime > now);
        
        // Check that this does not have to be storage
        AuctionInformation memory auction;
        
        auction.owner = msg.sender;
        auction.registered = true;
        auction.bid = 0;
        auction.bidder = msg.sender;
        auction.mode = AuctionMode.Open;
        auction.closingTime = _closingTime;
        
        auctions[_auction_id] = auction;
    }
    

    
    function makeBid(uint _auction_id, uint _bid)
        public
        payable
        auctionInMode(_auction_id, AuctionMode.Open) 
        notByOwner(_auction_id)
    {
        require (_bid > auctions[_auction_id].bid);
        require (msg.value >= _bid);
        require (now <= auctions[_auction_id].closingTime);
        
        // Update withdrawable balances
        withdrawableBalances[auctions[_auction_id].bidder] += auctions[_auction_id].bid;
        
        // Remember the new bid
        auctions[_auction_id].bid = _bid;
        auctions[_auction_id].bidder = msg.sender;
    }    
    
    function closeAuction(uint _auction_id) 
        public
    {
        require (
            msg.sender == auctions[_auction_id].owner || 
            msg.sender == auctions[_auction_id].bidder
        );
        require (now > auctions[_auction_id].closingTime);
        
        auctions[_auction_id].mode = AuctionMode.Closed;
        withdrawableBalances[auctions[_auction_id].owner] += auctions[_auction_id].bid;
    }

    function withdraw(uint _amount) 
        public
    {
        require (withdrawableBalances[msg.sender] >= _amount);
        withdrawableBalances[msg.sender] -= _amount;
        msg.sender.transfer(_amount);
    }
}
