// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract BasicBalance{
    //Hold owner address for verification
    address public owner;
    //Hold balance
    uint256 public balance;

    constructor(){
        //Set the owner when the contract has deployed
        owner = msg.sender;
    }
    
    receive() payable external{
        //Receive eth
        balance += msg.value;
    }

    modifier ownerOnly{
        //If the sender is not the owner revert the transaction
        require(msg.sender == owner, "Only owner can perform this operation!");
        _;
    }

    function transferBalance(uint amount, address payable destination) external ownerOnly{
        //Check for balance
        require(amount <= balance, "Insufficient balance!");
        //Transfer amount to the destination address
        destination.transfer(amount);
        //Decrease the balance
        balance -= amount;
    }
}