pragma solidity >=0.5.5;

/* Simple one shot, time locked and conditional on two-party release escrow smart contract */

contract Escrow2 {

    enum State {AwaitingDeposit, DepositPlaced, Withdrawn}

    address public sender;
    address payable public receiver;

    uint public delayUntilRelease;
    uint public releaseTime;

    uint public amountInEscrow;
    bool public releasedBySender;
    bool public releasedByReceiver;

    State public state;

    modifier by(address _address) {
        require(msg.sender == _address);
        _;
    }

    modifier stateIs(State _state) {
        require(state == _state);
        _;
    }

    constructor (address _sender, address payable _receiver, uint _delayUntilRelease) public {
        // Set parameters of escrow contract
        sender = _sender;
        receiver = _receiver;
        delayUntilRelease = _delayUntilRelease;

        releasedBySender = false;
        releasedByReceiver = false;

        // Set contract state
        state = State.AwaitingDeposit;
    }

    function placeInEscrow() public by(sender) stateIs(State.AwaitingDeposit) payable {
        require (msg.value > 0);

        // Update parameters of escrow contract
        amountInEscrow = msg.value;
        releaseTime = now + delayUntilRelease;

        // Set contract state
        state = State.DepositPlaced;
    }

    function releaseEscrow() public stateIs(State.DepositPlaced) {
        if (msg.sender == sender)   { releasedBySender   = true; }
        if (msg.sender == receiver) { releasedByReceiver = true; }
    }

    function withdrawFromEscrow() public by(receiver) stateIs(State.DepositPlaced) {
        require (now >= releaseTime);
        require (releasedByReceiver && releasedBySender);

        // Set contract state
        state = State.Withdrawn;

        // Send money
        receiver.transfer(amountInEscrow);

        // Set internal parameters of smart contract
        amountInEscrow = 0;

    }
}
