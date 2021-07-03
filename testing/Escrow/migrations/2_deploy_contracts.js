const EscrowContract = artifacts.require('Escrow2');

var account_1 = '0x02135B1f570141a6dEA42f7D3415E04777e57A73';
var account_2 = '0xC821F53D570DE74Ca456559977df5F68dee39C04';
var releaseTime = 0;

module.exports = function (deployer) {
  deployer.deploy(EscrowContract, account_1, account_2, releaseTime);
};
