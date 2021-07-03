const PiggyBankContract = artifacts.require('PiggyBank1');

var account_1 = '0x2c764370a97ffd8b16613428cea297c26f4ee170';

module.exports = function (deployer) {
  deployer.deploy(PiggyBankContract, account_1);
};
