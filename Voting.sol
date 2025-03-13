// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {

    struct Vote {
        string description;
        uint256 deadline;
        uint256 yesVotes;
        uint256 noVotes;
        bool isActive;
    }

   
    address public admin;
    Vote[] public votes; 
    mapping(address => uint256) public stakedTokens; 
    mapping(address => mapping(uint256 => bool)) public hasVoted;

   
    constructor() {
        admin = msg.sender;
    }

    
    function createVote(string memory _description, uint256 _duration) external {
        require(msg.sender == admin);
        uint256 deadline = block.timestamp + _duration;
        votes.push(Vote({
            description: _description,
            deadline: deadline,
            yesVotes: 0,
            noVotes: 0,
            isActive: true
        }));
    }

    function stakeTokens(uint256 _amount) external {
        require(_amount > 0);
        stakedTokens[msg.sender] += _amount;
    }

    function vote(uint256 _voteId, bool _vote) external {
        require(_voteId < votes.length);
        require(votes[_voteId].isActive, "Vote is not active");
        require(block.timestamp <= votes[_voteId].deadline, "Deadline passed");
        require(!hasVoted[msg.sender][_voteId], "This wallet voted");
        require(stakedTokens[msg.sender] > 0, "No staked tokens");

        if (_vote) {
            votes[_voteId].yesVotes += stakedTokens[msg.sender];
        } else {
            votes[_voteId].noVotes += stakedTokens[msg.sender];
        }

        hasVoted[msg.sender][_voteId] = true;
    }

    function getVoteResult(uint256 _voteId) external view returns (uint256 yesVotes, uint256 noVotes, bool isActive) {
        require(_voteId < votes.length, "Invalid vote ID");
        Vote memory currentVote = votes[_voteId]; // Renamed variable to avoid conflict
        return (currentVote.yesVotes, currentVote.noVotes, currentVote.isActive);
    }
}
