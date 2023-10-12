// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

//import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting {

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        address hasBeenSubmittedBy;
        string description;
        uint voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    address public chairperson;

    mapping(address => bool) public voters;

    Proposal[] public proposals;
    
    event Authorized(address indexed _address);
    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);


    modifier check() {
        require(voters[msg.sender] == true, "Unauthorized");
        _;
    }
    
    function authorize(address _address) public check {
        voters[_address] = true;
        emit Authorized(_address);
    } 

    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function getWinner() public view
            returns (address winnerID)
    {
        winnerID = proposals[winningProposal()].hasBeenSubmittedBy;
    }

}