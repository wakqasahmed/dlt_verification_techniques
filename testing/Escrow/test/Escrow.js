var EscrowContract = artifacts.require('Escrow2');
const truffleAssert = require('truffle-assertions');

var contractInstance;
var accounts;
// var ownerAccount;
var senderAccount;
var receiverAccount;

// INIT TEST SUITE
contract('Escrow', async (accs) => {
  // FUNCTION WILL RETURN ALL GANACHE ACCOUNTS
  accounts = accs;
  // ownerAccount = accounts[0];
  senderAccount = accounts[1];
  receiverAccount = accounts[2];
  testAccount = accounts[3];
});

contract('Escrow', function (accounts) {
  // FUNCTION WILL RETURN ALL GANACHE ACCOUNTS

  // CONSTRUCTOR TEST
  it('Initialises Contract', function () {
    return EscrowContract.deployed().then(function (instance) {
      contractInstance = instance;

      contractInstance.setSenderAccount(senderAccount);
      contractInstance.setReceiverAccount(receiverAccount);
      contractInstance.setReleaseTime(0);

      return contractInstance;
    });
  });

  describe('User Story 1: Revert test for undesired states', async () => {
    /*
    it('has owner failed to break the Piggy Bank in Unused State', async function () {
      // TEST THAT FUNCTION REVERTS IF INCORRECT STATE IS DETECTED:
      await truffleAssert.reverts(
        contractInstance.breakPiggyBank({ from: ownerAccount }),
        'state should be in use'
      );
    });*/

    it('has attempt to deposit zero value failed', async () => {
      // TEST THAT FUNCTION REVERTS IF ZERO VALUE IS DETECTED:

      let _Amount = 0;

      await truffleAssert.reverts(
        contractInstance.placeInEscrow({
          from: senderAccount,
          value: web3.utils.toWei(_Amount.toString(), 'ether'),
        }),
        'deposit amount should be greater than zero'
      );
    });

    it('has attempt to deposit value by someone other than sender failed', async () => {
      // TEST THAT FUNCTION REVERTS IF UNAUTHORIZED CALLER IS DETECTED:

      let _Amount = 1;

      await truffleAssert.reverts(
        contractInstance.placeInEscrow({
          from: testAccount,
          value: web3.utils.toWei(_Amount.toString(), 'ether'),
        }),
        'address should be registered with appropriate role'
      );
    });

    it('has attempt to deposit value by receiver failed', async () => {
      // TEST THAT FUNCTION REVERTS IF UNAUTHORIZED CALLER IS DETECTED:

      let _Amount = 1;

      await truffleAssert.reverts(
        contractInstance.placeInEscrow({
          from: receiverAccount,
          value: web3.utils.toWei(_Amount.toString(), 'ether'),
        }),
        'address should be registered with appropriate role'
      );
    });

    it('has attempt to deposit value twice by sender failed', async () => {
      // TEST THAT FUNCTION REVERTS IF INAPPROPRIATE STATE IS DETECTED:

      let _Amount = 1;

      await contractInstance.placeInEscrow({
        from: senderAccount,
        value: web3.utils.toWei(_Amount.toString(), 'ether'),
      });

      await truffleAssert.reverts(
        contractInstance.placeInEscrow({
          from: senderAccount,
          value: web3.utils.toWei(_Amount.toString(), 'ether'),
        }),
        'state should be appropriate to execute this function'
      );
    });

    it('has attempt by someone other than receiver to withdraw failed', async () => {
      // TEST THAT FUNCTION REVERTS IF UNAUTHORIZED CALLER IS DETECTED:

      await truffleAssert.reverts(
        contractInstance.withdrawFromEscrow({ from: testAccount }),
        'address should be registered with appropriate role'
      );
    });

    it('has attempt by sender to withdraw failed', async () => {
      // TEST THAT FUNCTION REVERTS IF UNAUTHORIZED CALLER IS DETECTED:

      await truffleAssert.reverts(
        contractInstance.withdrawFromEscrow({ from: senderAccount }),
        'address should be registered with appropriate role'
      );
    });

    it('has attempt by receiver to withdraw failed', async () => {
      // TEST THAT FUNCTION REVERTS IF INAPPROPRIATE STATE IS DETECTED:

      await truffleAssert.reverts(
        contractInstance.withdrawFromEscrow({ from: receiverAccount }),
        'withdrawal should be authorized by receiver and sender both'
      );
    });
  });

  /*
  // PLACE IN ESCROW TEST
  it('Sender Places Ether in Escrow', function () {
    return EscrowContract.deployed()
      .then(function (instance) {
        contractInstance = instance;
        // TEST THAT FUNCTION REVERTS IF INCORRECT STATE IS DETECTED:
        return contractInstance.placeInEscrow(_EscrowAmount, {
          from: _Receiver,
        });
      })
      .then(assert.fail)
      .catch(function (error) {
        assert(
          error.message.indexOf('revert') >= 0,
          'Only Sender Address can call this function.'
        );
      });
  });

  it('Escrow is smaller than zero', function () {
    return EscrowContract.deployed()
      .then(function (instance) {
        contractInstance = instance;
        // TEST THAT FUNCTION REVERTS IF ESCROW IS SMALLER THAN ZERO:
        return contractInstance.placeInEscrow(-10, { from: _Sender });
      })
      .then(assert.fail)
      .catch(function (error) {
        assert(
          error.message.indexOf('revert') >= 0,
          'Escrow must be greater than Zero.'
        );
      });
  });
*/

  describe('User Story 2: Positive tests', async () => {
    it('has attempt to release escrow by sender called successfully', async () => {
      // TEST THAT FUNCTION EXECUTES SUCCESSFULLY

      await contractInstance.releaseEscrow({
        from: senderAccount,
      });
    });

    it('has attempt to release escrow by receiver called successfully', async () => {
      // TEST THAT FUNCTION EXECUTES SUCCESSFULLY

      await contractInstance.releaseEscrow({
        from: receiverAccount,
      });
    });

    it('has attempt to withdraw by receiver called successfully', async () => {
      // TEST THAT FUNCTION EXECUTES SUCCESSFULLY

      await contractInstance.withdrawFromEscrow({
        from: receiverAccount,
      });
    });
  });
});
