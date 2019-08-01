## Avoiding Common Attacks

Consensys' solidity bootcamp reinforced a lot of the considerations that should be kept in mind when designing smart contracts. 

Specifically for my project, I implemented the following:
1. No outside contracts were called as a safety measure. All logic is handled in a single contract. 
2. Contract does not hold any eth.
3. No "setter" functions allow address as a parameter. 
4. Use of msg.sender, avoiding use of tx.origin, to add addresses to the data structures.
5. Only use popular and battle-tested libraries
6. Payable functions are simple and use modifiers. No loops in payable functions.
7. Safemath library to avoid over/underflow problems


Additionally, I installed truffle-security package and used MythX to run a security analysis of my smart contract.

You can try yourself by installing with the command `npm install truffle-security`

Running `truffle run verify` compiles the code and tests for vulnerabilities. 

1 vulnerability was found in the checkValue() modifier. The error suggested I make all state changes before the transfer call.

I changed 

```javascript
msg.sender.transfer(uint256(msg.value) - uint256(_price));
```

to

```javascript
uint amountToRefund = uint256(msg.value) - uint256(_price);
msg.sender.transfer(amountToRefund);
```

Thus removing that substraction in the transfer call and resolving the vulnerability.
