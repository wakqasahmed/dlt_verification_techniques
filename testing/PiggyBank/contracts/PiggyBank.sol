// SPDX-License-Identifier: MIT
pragma solidity >=0.5.5;

contract PiggyBank1 {
    enum PiggyBankState { Unused, InUse, Broken }

    address payable public owner;
    PiggyBankState public state;
    uint public timeOfFirstDeposit;
    uint public balance;
    uint public delayUntilBreak;

    constructor (address payable _owner) public {
        owner = _owner;
        state = PiggyBankState.Unused;
        balance = 0;
    }

    function setOwnerAccount(address payable _ownerAcc) public {
        owner = _ownerAcc;
    }

    function setDelayUntilBreak(uint _delayUntilBreak) public {
        delayUntilBreak = _delayUntilBreak;
    }

    modifier byOwner {
        require (msg.sender == owner, "sender should be the owner");
        _;
    }

    modifier notBroken {
        require (state != PiggyBankState.Broken, "state should not be broken");
        _;
    }

    modifier inUse {
        require (state == PiggyBankState.InUse, "state should be in use");
        _;
    }

    function addMoney() byOwner notBroken public payable {
        require(msg.value > 0, "deposit amount should be greater than zero");
        balance += msg.value;
        if (state == PiggyBankState.Unused) {
            state = PiggyBankState.InUse;
            timeOfFirstDeposit = now;
        }
    }

    function breakPiggyBank() byOwner inUse public {
        require (now >= timeOfFirstDeposit + (delayUntilBreak * 1 days), "one year should past after the first deposit");

        state = PiggyBankState.Broken;
        owner.transfer(balance);

        // balance = 0;
    }

    /// @notice Get balance
    /// @return The balance of the address
    // allows function to run locally/off blockchain
    function balanceOf(address account) public view returns (uint) {
        /* Get the balance of the account of this transaction */
        return address(account).balance;
    }

    function getState() public view returns (PiggyBankState) {
        return state;
    }

}