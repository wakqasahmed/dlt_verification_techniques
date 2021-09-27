var PiggyBankContract = artifacts.require('PiggyBank1');
const truffleAssert = require('truffle-assertions');

var contractInstance;
var accounts;
var ownerAccount;

// INIT TEST SUITE
contract('PiggyBank', async (accs) => {
  // FUNCTION WILL RETURN ALL GANACHE ACCOUNTS
  accounts = accs;
  ownerAccount = accounts[0];
  testAccount = accounts[1];
});

const initContract = async () => {
  console.log('Deploying contract and Setting up the accounts');

  contractInstance = await PiggyBankContract.deployed();
  contractInstance.setOwnerAccount(ownerAccount);
  contractInstance.setDelayUntilBreak(0);
};

describe('User Story 1: Revert test for undesired states', async () => {
  before(async function () {
    await initContract();
  });

  it('has owner failed to break the Piggy Bank in Unused State', async function () {
    // TEST THAT FUNCTION REVERTS IF INCORRECT STATE IS DETECTED:
    await truffleAssert.reverts(
      contractInstance.breakPiggyBank({ from: ownerAccount }),
      'state should be in use'
    );
  });

  it('has attempt by someone other than owner to break the Piggy Bank failed', async () => {
    // TEST THAT FUNCTION REVERTS IF INCORRECT SENDER IS DETECTED:

    await truffleAssert.reverts(
      contractInstance.breakPiggyBank({ from: testAccount }),
      'sender should be the owner'
    );
  });

  it('has attempt to deposit zero value failed', async () => {
    // TEST THAT FUNCTION REVERTS IF ZERO VALUE IS DETECTED:

    let _Amount = 0;

    await truffleAssert.reverts(
      contractInstance.addMoney({
        from: ownerAccount,
        value: web3.utils.toWei(_Amount.toString(), 'ether'),
      }),
      'deposit amount should be greater than zero'
    );
  });
});

describe('User Story 2: Positive tests', async () => {
  it('has attempt to place ether by owner in piggy bank called successfully', async () => {
    // TEST THAT FUNCTION EXECUTES SUCCESSFULLY
    let _Amount = 2;

    let contractOldBalance = await contractInstance.balance({
      from: ownerAccount,
    });

    // let ownerOldBalance = await contractInstance.balanceOf(ownerAccount, {
    //   from: ownerAccount,
    // });

    let result = await contractInstance.addMoney({
      from: ownerAccount,
      value: web3.utils.toWei(_Amount.toString(), 'ether'),
    });

    let contractNewBalance = await contractInstance.balance({
      from: ownerAccount,
    });

    // let ownerNewBalance = await contractInstance.balanceOf(ownerAccount, {
    //   from: ownerAccount,
    // });
    // console.log(result);
    // console.log('contractOldBalance: ', contractOldBalance.toString());
    // console.log('contractNewBalance: ', contractNewBalance.toString());
    // console.log('ownerOldBalance: ', ownerOldBalance.toString());
    // console.log('ownerNewBalance: ', ownerNewBalance.toString());

    assert.equal(
      contractNewBalance - contractOldBalance,
      web3.utils.toWei(_Amount.toString(), 'ether')
    );
  });

  it('has attempt to break piggy bank by owner called successfully', async () => {
    let contractOldBalance = await contractInstance.balanceOf(
      contractInstance.address,
      {
        from: ownerAccount,
      }
    );

    let ownerOldBalance = await contractInstance.balanceOf(ownerAccount, {
      from: ownerAccount,
    });

    let oldState = await contractInstance.getState();

    let result = await contractInstance.breakPiggyBank({
      from: ownerAccount,
    });

    let contractNewBalance = await contractInstance.balanceOf(
      contractInstance.address,
      {
        from: ownerAccount,
      }
    );

    let ownerNewBalance = await contractInstance.balanceOf(ownerAccount, {
      from: ownerAccount,
    });

    let newState = await contractInstance.getState();

    //    console.log('Result: ', result);
    // console.log('Old State: ', oldState.toString());
    // console.log('New State: ', newState.toString());
    // console.log('contractOldBalance: ', contractOldBalance.toString());
    // console.log('contractNewBalance: ', contractNewBalance.toString());
    // console.log('ownerOldBalance: ', ownerOldBalance.toString());
    // console.log('ownerNewBalance: ', ownerNewBalance.toString());

    // console.log('contractOldBalance * 1: ', contractOldBalance * 1);
    // console.log(
    //   '(ownerNewBalance - ownerOldBalance) * 1: ',
    //   (ownerNewBalance - ownerOldBalance) * 1
    // );

    assert.equal(oldState.toString(), 1); //InUse
    assert.equal(newState.toString(), 2); //Broken

    assert.equal(contractNewBalance, web3.utils.toWei('0', 'ether'));

    assert.isAtLeast(
      contractOldBalance * 1,
      (ownerNewBalance - ownerOldBalance) * 1
    );

    // assert.equal(
    //   web3.utils.toWei(contractOldBalance.toString(), 'ether'),
    //   web3.utils.toWei((ownerNewBalance - ownerOldBalance).toString(), 'ether')
    // );
  });
});
