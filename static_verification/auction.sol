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
* The contract transfers funds or goods directly!
*/

contract OneAuction {

    // Handling mode of the auction
    enum AuctionMode { NeverStarted, Open, Closed }    

    // Handling auction information
    AuctionMode mode;
    address payable owner;
    uint closingTime;

    address payable bidder;
    uint bid;

    /*@ invariant
      @   address(this) != owner,
      @   address(this) != bidder;
      @*/

    /* Recall:
     * net(addr) := (funds sent from addr to this) - (funds sent from this to addr)
     */
    /*@ invariant
      @   bid == net(bidder) + net(owner),
      @   (\forall address a;
      @                (a != owner && a != bidder && a != address(this))
      @            ==> net(a) == 0),
      @   net(owner) <= 0,
      @   mode == Open ==> net(owner) == 0;
      @*/
    
    // Modifier to check mode of auction
    modifier inMode(AuctionMode _auctionMode) {
        require (mode == _auctionMode);
        _;
    }

    modifier by(address _caller) {
        require (msg.sender == _caller);
        _;
    }

    modifier notBy(address _caller) {
        require (msg.sender != _caller);
        _;
    }

    constructor (address payable _owner) 
        public
    {
        mode = AuctionMode.NeverStarted;
        owner = _owner;
    }
    
    function openAuction(uint _closingTime) 
        public
        inMode(AuctionMode.NeverStarted)
        by(owner)
    {
        require (_closingTime > now);

        mode = AuctionMode.Open;
        closingTime = _closingTime;

        bid = 0;
        bidder = owner;
    }

    // note that we here allow the bidder to overbid herself
    /*@ succeeds_only_if
      @   mode == AuctionMode.Open,
      @   msg.sender != owner,
      @   msg.value > bid,
      @   now <= closingTime;
      @ after_success
      @   bid > \old(bid),
      @   net(bidder) == msg.value,
      @   \old(bidder) != msg.sender ==> net(\old(bidder)) == 0;
      @*/
    function makeBid()
        public
        payable
        inMode(AuctionMode.Open) 
        notBy(owner)
    {
        require (msg.value > bid);
        require (now <= closingTime);

        // Remember the old bid
        uint oldBid = bid;
        address oldBidder = bidder;
        // Set the new bid
        bid = msg.value;
        bidder = msg.sender;
        
        // Transfer the old bid to the old bidder
        oldBidder.transfer(oldBid);
    }    
    
    /*@ succeeds_only_if
      @   msg.sender == owner || msg.sender == bidder,
      @   now > closingTime;
      @ after_success
      @   net(owner) == -net(bidder);
      @*/
    function closeAuction() 
        public
        inMode(AuctionMode.Open)
    {
        require (
            msg.sender == owner || 
            msg.sender == bidder
        );
        require (now > closingTime);
        
        mode = AuctionMode.Closed;
        // Transfer the bid to the owner
        uint tmp = bid;
        bid = 0;        
        owner.transfer(tmp);
    }

}
