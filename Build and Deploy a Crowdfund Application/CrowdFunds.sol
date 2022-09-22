// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ManagedApp{
    address private manager;

    constructor(){
        manager = msg.sender;
    }

    modifier managerOnly{
        require(msg.sender == manager, "App manager only!");
        _;
    }

    function setManager(address _newManager) external managerOnly{
        manager = _newManager;
    }
}

contract CrowdFunds is ManagedApp{
    //Structs

    struct Campaign{
        address creator;
        uint goal;
        string subject;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    //Events

    event ECreate(
        uint id,
        address indexed creator,
        uint goal,
        string subject,
        uint32 startAt,
        uint32 endAt
    );

    event ECancel(
        uint id
    );

    event EPledge(
        uint indexed id,
        address indexed pledger,
        uint amount
    );

    event EUnpledge(
        uint indexed id,
        address indexed pledger,
        uint amount
    );

    event EClaim(
        uint id
    );

    event ERefund(
        uint id,
        address indexed caller,
        uint amount
    );

    //State variables

    ERC20 public immutable token;

    uint32 public maxDuration = 90 days;
    uint public totalCampaigns;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledges;

    //Constructor

    constructor(address _token){
        token = ERC20(_token);
    }

    //Manager-only section

    function setDuration(uint16 _days) external managerOnly{
        maxDuration = _days * 1 days;
    }

    //Public section
    
    function create(uint _goal, string calldata _subject, uint32 _startAt, uint32 _endAt) external{//function will return id of the campaign
        require(_startAt >= block.timestamp, "Start at cannot be before than now");
        require(_endAt >= _startAt, "End at cannot be before than start at");
        require(_endAt <= _startAt + maxDuration, "Campaign duration cannot exceed max duration");

        totalCampaigns++;
        campaigns[totalCampaigns] = Campaign({
            creator: msg.sender,
            goal: _goal,
            subject: _subject,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit ECreate(totalCampaigns, msg.sender, _goal, _subject, _startAt, _endAt);
    }

    function cancel(uint _id) external{
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "You are not the creator");
        require(block.timestamp < campaign.startAt, "Already started");

        delete campaigns[_id];
        emit ECancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "Campaign didn't start yet");
        require(block.timestamp <= campaign.endAt, "Campaign ended");

        campaign.pledged += _amount;
        pledges[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit EPledge(_id, msg.sender, _amount);
    }

    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "Campaign ended");

        campaign.pledged -= _amount;
        pledges[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit EUnpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "You are not the creator");
        require(block.timestamp > campaign.endAt, "Campaign did not end yet");
        require(campaign.pledged >= campaign.goal, "Campaign couldn't reach the goal");
        require(!campaign.claimed, "You already claimed");

        campaign.claimed = true;
        token.transfer(campaign.creator, campaign.pledged);

        emit EClaim(_id);
    }

    function refund(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "Campaign did not end yet");
        require(campaign.pledged < campaign.goal, "Campaign reached the goal");

        uint balance = pledges[_id][msg.sender];
        pledges[_id][msg.sender] = 0;
        token.transfer(msg.sender, balance);

        emit ERefund(_id, msg.sender, balance);
    }
}