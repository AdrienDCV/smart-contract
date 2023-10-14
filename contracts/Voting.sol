// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Voting is Ownable {

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

    address private contractOwner;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    bool public voterRegistrationIsOpened;
    bool public proposalRegistrationSessionIsOpened;
    bool public votingSessionIsOpened;

    WorkflowStatus public currentSessionStatus;
    WorkflowStatus public previousSessionStatus;

    constructor(address _contractOwner) Ownable(_contractOwner) {
        contractOwner = _contractOwner;
    }

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    modifier check() {
        require(voters[msg.sender].isRegistered != true, "Unauthorized");
        _;
    }

    function openProposalRegistration() public returns (string memory confirmation) {
        if (msg.sender == contractOwner) {
            proposalRegistrationSessionIsOpened = true;
            previousSessionStatus = WorkflowStatus.RegisteringVoters;
            currentSessionStatus = WorkflowStatus.ProposalsRegistrationStarted;
            emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
            confirmation = "The proposals registration is now opened";
        } else {
            confirmation = "Only the owner can open the proposals registration";
        } 
    }

    function closeProposalRegistration() public returns (string memory confirmation ) {
        if (msg.sender == contractOwner) {
            proposalRegistrationSessionIsOpened = false;
            previousSessionStatus = currentSessionStatus;
            currentSessionStatus = WorkflowStatus.ProposalsRegistrationEnded;
            emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
            confirmation = "The proposals registration is now closed";
        } else {
            confirmation = "Only the owner can close the proposals registration";
        }
    }

    function openVotingSession() public returns (string memory confirmation) {
        if (msg.sender == contractOwner) {
            votingSessionIsOpened = true;
            previousSessionStatus = currentSessionStatus;
            currentSessionStatus = WorkflowStatus.VotingSessionStarted;
            emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
            confirmation = "The voting session is now opened";
        } else {
            confirmation = "Only the owner can open the voting session";
        }
    }

    function closeVotingSession() public returns (string memory confirmation) {
        if (msg.sender == contractOwner) {
            votingSessionIsOpened = false;
            previousSessionStatus = currentSessionStatus;
            currentSessionStatus = WorkflowStatus.VotingSessionEnded;
            emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
            confirmation = "The voting session is now opened";
        } else {
            confirmation = "Only the owner can close the voting session";
        }
    }

    function tallyVotes() public {
        previousSessionStatus = currentSessionStatus;
        currentSessionStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
    }


    function registerVoter(address voterToAdd) public check returns (string memory confirmation) {
        if (msg.sender == contractOwner) {
            voters[voterToAdd].isRegistered = true;
            voters[voterToAdd].hasVoted = false;
            emit VoterRegistered(voterToAdd);
            confirmation = "Voter added";
        } else {
            confirmation = "Impossible to add the voter";
        }

    } 

    function registerVoters(address[] calldata votersToAdd) public check returns (string memory confirmation) {
          if (msg.sender == contractOwner) {
            for (uint i = 0; i < votersToAdd.length; i++) {
                voters[votersToAdd[i]].isRegistered = true;
                voters[votersToAdd[i]].hasVoted = false;
                emit VoterRegistered(votersToAdd[i]);
            }
            confirmation = "Voters registered";
          } else {
            confirmation = "Only the owner can add voters";
          }
    } 

    function vote(uint proposalId) public returns (string memory confirmation) {
        if (votingSessionIsOpened) {
            Voter storage voter = voters[msg.sender];
            require(!voter.hasVoted, "Already voted.");
            voter.hasVoted = true;
            voter.votedProposalId = proposalId;

            proposals[proposalId].voteCount++;
            emit Voted(msg.sender, voter.votedProposalId);
            confirmation = "Voted";
        } else {
            confirmation = "Vote not available";
        }
    }

    function submitProposal(string calldata descritpion) public returns (string memory confirmation) {
        if (proposalRegistrationSessionIsOpened) {
             Proposal memory proposal = Proposal(msg.sender, descritpion, 0);
            proposals.push(proposal);
            emit ProposalRegistered(proposals.length-1);
            confirmation = "Proposal submitted";
        } else {
            confirmation = "Impossible to submit the proposal";
        }
    }

   function consultVote(address voterToConsult) public view returns (string memory result) {
        uint256 proposalId = voters[voterToConsult].votedProposalId;
        string storage proposalDescription = proposals[proposalId].description;
        result = string.concat("Voter ", Strings.toHexString(voterToConsult), " has voted for proposal #", Strings.toString(proposalId), " : ", proposalDescription);
    }

    function displayProposals() public view returns (string memory proposalsToString) {
        if (votingSessionIsOpened && proposals.length > 0) {
            for (uint i = 0; i < proposals.length; i++) {
            proposalsToString = string.concat(proposalsToString, "- #", Strings.toString(i), " - ", proposals[i].description, "\n");
            }
        }
        proposalsToString = "No proposal submitted.";
    }

    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function getWinner() public returns (address winnerID) {
        winnerID = proposals[winningProposal()].hasBeenSubmittedBy;
        tallyVotes();
    }

}