// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

// import "./Ownable.sol";

contract mSquare {
    address payable public owner;
    
    uint8 totalMembers = 3;
    uint8 currMemberCount = 0;
    uint8 currentMonth=0;
    uint256 chitFundDuration = 3;
    uint256 individualDepositAmount = 0.0001 ether;
    address public currentWinner;
    address[] addressList;
    
   
    struct person {
        bool isMember;
        uint8 loanGrantedMonth;
        uint256 lastDepositedTime;
    }

    struct stats {
        uint16 currPeriod;
        uint256 totalDeposits;
        uint256 lendingAmount;
    }
    
   stats trxnStats;

    mapping(address => person) public members;
    
    constructor() payable {
        owner = payable(msg.sender);
        currentMonth++;
    }

    modifier canDeposit() {
        require(members[msg.sender].isMember == true,"Sorry, Only members can deposit");
        require(msg.value == .0001 ether,"Deposited amount should be .0001 ether");
        //require(currMemberCount <= totalMembers);
        _;
    }

    modifier canWithDraw() {
        require(members[msg.sender].isMember == true);
        require(currMemberCount == totalMembers);
        require(members[msg.sender].loanGrantedMonth==currentMonth,"You are not the Winner");
        _;
    }
    
    function generateRandom() view private returns(address) {
       uint i=0;
       uint num;
       uint count;
       address[] memory NonwinnerList=new address[](currMemberCount);
       
      count=0;
      while(i < currMemberCount) {
           if (members[addressList[i]].loanGrantedMonth == 0) {
                NonwinnerList[count]=addressList[i];
                count++;
           }
           i++;
     }
     num=uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)))%(count);
     return NonwinnerList[num];
    }
    
    function selectWinner() public{
        
        address winner=generateRandom();
        members[winner].loanGrantedMonth=currentMonth;
        console.log(winner);
        currentWinner=winner;
    }
    
    function addMember(address _address) public {
       require(currMemberCount != 3, "Threshold reached");
       require(members[_address].isMember==false,"Member already exists");
       members[_address] = person(true,0, block.timestamp);
       currMemberCount++;
       addressList.push(_address);
    }
    
    function getBalance() public view returns(uint256) {
    console.log("balance: %s", address(this).balance);
    return address(this).balance;
    }
    
    function deposit() public payable canDeposit{
    }
    
    function withDraw() public canWithDraw {
        
        uint256 amount = address(this).balance;
        console.log("before amount: %s", amount);
        (bool success, ) = payable(msg.sender).call{value: .0003 ether}("");
        require(success, "Failed to withdraw Ether from owner");
        amount = address(this).balance;
        console.log("after amount: %s", amount);
        currentMonth++;

    }
}
