pragma solidity >=0.5.5;

contract PiggyBank1 {
    enum PiggyBankState { Unused, InUse, Broken }

    address payable public owner;
    PiggyBankState public state;
    uint public timeOfFirstDeposit;
    uint public balance;

    constructor (address payable _owner) public {
        owner = _owner;
        state = PiggyBankState.Unused;
        balance = 0;
    }

    modifier byOwner {
        require (msg.sender == owner);
        _;
    }

    modifier notBroken {
        require (state != PiggyBankState.Broken);
        _;
    }

    modifier inUse {
        require (state == PiggyBankState.InUse);
        _;
    }

    /*@ succeeds_only_if
      @   state != PiggyBankState.Broken,
      @   msg.sender == owner,
      @   msg.value > 0;
      @ after_success
      @   balance > \old(balance),
      @   state == PiggyBankState.InUse;
      @*/
    function addMoney() byOwner notBroken public payable {
        balance += msg.value;
        if (state == PiggyBankState.Unused) {
            state = PiggyBankState.InUse;
            timeOfFirstDeposit = now;
        }
    }

    /*@ succeeds_only_if
      @   msg.sender == owner,
      @   state == PiggyBankState.InUse,      
      @   now >= timeOfFirstDeposit + 365 days;
      @ after_success
      @   state == PiggyBankState.Broken,
      @   net(owner) == -net(balance);
      @*/
    function breakPiggyBank() byOwner inUse public {
        require (now >= timeOfFirstDeposit + 365 days);

        state = PiggyBankState.Broken;
        owner.transfer(balance);
    }

}
