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

    function addMoney() byOwner notBroken public payable {
        balance += msg.value;
        if (state == PiggyBankState.Unused) {
            state = PiggyBankState.InUse;
            timeOfFirstDeposit = now;
        }
    }

    function breakPiggyBank() byOwner inUse public {
        require (now >= timeOfFirstDeposit + 365 days);

        state = PiggyBankState.Broken;
        owner.transfer(balance);
    }

}
