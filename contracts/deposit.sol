// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

contract Deposit{


mapping(address => uint) public balances;



//Create deposit into a sort of fake token.
function receiveDeposit(uint256 amountIn) public payable  returns (bool){
    // Add some "Tokens to the senders address
    balances[msg.sender] = amountIn;
    //balances[msg.sender] -= amountIn;
    return true;
}
//Get balance of an address
function getDepositBalance(address _to) public view returns(uint){
    return balances[_to];
}


// The problematic function
function returnDeposit(uint256 amountOut) external returns (bool) {
    // Going to delibrately create a reentracy bug here
    
    // There are all sorts of issues about overflow and what if its exactly zero
    // This is just to illustrate its not meant to be perfect
    // really scares me putting an If with an exact value also no check on what will happen if the Type is wrong, but this just to illustrate how it works.
    if (balances[msg.sender] == 0) revert("Balance is zero");
        // First thing to get right is not to use transfer but to use call which sends the entire GAS stipend
        // If you change the next line to use send it limits the GAS sent to 2300 which would prevent the hack
        // please dont assume that using send is the answer, GAS values and Limits can change, its the entire pattern that is at fault

    msg.sender.call.value(amountOut)("");

    
    //update balances too late
    // I am not using safe math so its wrapping around and instead of getting zero its getting a massive number, so instaed of 
    //balances[msg.sender] -= amountOut;
    //I will use 
    balances[msg.sender] = 0;
   
   return true;
    
}
// Helper function to check address of this contract
function getAddress() public view returns (address ){
        return address(this);
    }
    
    //Its this function that allows the hacker to repeat the hack
    //(s)he creates two contracts, and sends the "Tokens" from Address A to Address B
    // Address A attacks the Deposit contract first the fallback function of A calls transfer 258 Tokens first
    // then it calls withDraw, this will resolve with Contract A's balance being set to 0, but before it does this
    // it calls transfer and transfers the 258 tokens to Contracts B address
    // then contract B which now has 258 extra Tokens, attacks and calls withDraw this triggers its fallback 
    // which calls withdraw 
    // before its balance can be set to zero it transfers it back to Contract A's address 
    // The switching between the two attack contracts is what drains the Deposit address.

//Helpful transfer function
    function transfer(address to, uint256 amount) public returns (bool) {
        //decrease msg.sender balance
    balances[msg.sender] -= amount;
    // Increase the to balance
    balances[to] += amount;
    return true;

    }


receive() external payable {
    // Nothing to do
  }
}

