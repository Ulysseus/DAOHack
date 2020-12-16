let Deposit = artifacts.require("deposit")
let AttackA = artifacts.require("attackA")
let AttackB = artifacts.require("attackB")

module.exports = async function (deployer) {

  // this is the pattern for deploying a contract dependent on another contract having been deployed before hand
  //deployer.deploy(Deposit).then(function() {
  //  return deployer.deploy(Attack, Deposit.address);
 // });
   await deployer.deploy(Deposit);
    await deployer.deploy(AttackA,Deposit.address);
    await deployer.deploy(AttackB,Deposit.address);
  };
