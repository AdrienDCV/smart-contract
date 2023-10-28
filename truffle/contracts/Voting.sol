// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "../../.deps/npm/@openzeppelin/contracts/access/Ownable.sol";
import "../../.deps/npm/@openzeppelin/contracts/utils/Strings.sol";

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
        GlobalSessionOpened,
        GlobalSessionClosed,
        VotersRegistrationStarted,
        VotersRegistrationEnded,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    address private contractOwner;

    mapping(address => Voter) private voters;

    Proposal[] private proposals;
    address[] private votersAddresses;

    bool private globalSessionIsOpened;
    bool private voterRegistrationIsOpened;
    bool private proposalRegistrationSessionIsOpened;
    bool private votingSessionIsOpened;

    WorkflowStatus private currentSessionStatus;
    WorkflowStatus private previousSessionStatus;

    constructor(address _contractOwner) Ownable(_contractOwner) {
        contractOwner = _contractOwner;
    }

    event VoterRegistered(address voterAddress);
    event VoterRemoved(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);
    event SessionReset(string SessionResetMessage);
    event VotingSessionReset(string VotingSessionResetMessage);

    modifier checkVoter(address addressToAdd) {
        require(voters[addressToAdd].isRegistered != true, string.concat("Voter ", Strings.toHexString(addressToAdd), " is already registered"));
        _;
    }

    function openNewSession() public returns (string memory confirmation) {
        require(msg.sender == contractOwner, "Only the contract's owner can open a new session");
        voterRegistrationIsOpened = false;
        proposalRegistrationSessionIsOpened = false;
        votingSessionIsOpened = false;
        if (votersAddresses.length > 0) {
            removeVoters(votersAddresses);
        }
        if (proposals.length > 0) {
            delete proposals;
        }
        confirmation = "A new session is now opened";
        globalSessionIsOpened = true;
    }

    // Gives to contractOwner the possibility to close the current global session at anytime
    function closeGlobalSession() public returns (string memory confirmation) {
        require(msg.sender == contractOwner, "Only the contract's owner can close the global session");
        require(globalSessionIsOpened == true, "The global session must be open before it can be closed");
        globalSessionIsOpened = false;
        previousSessionStatus = currentSessionStatus;
        currentSessionStatus = WorkflowStatus.GlobalSessionClosed;
        emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
        confirmation = "The global session is now closed";
    }

    function openVotersRegistration() public returns (string memory confirmation) {
        require(msg.sender == contractOwner, "Only the contract's owner can open the voters registration");
        require(globalSessionIsOpened == true, "The global session must be opened to open the voters registration");
        voterRegistrationIsOpened = true;
        previousSessionStatus = currentSessionStatus;
        currentSessionStatus = WorkflowStatus.VotersRegistrationStarted;
        emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
        confirmation = "The voters registration is now opened";
    }

    function closeVotersRegistration() public returns (string memory confirmation) {
        require(msg.sender == contractOwner, "Only the contract's owner can close the voters registration");
        require(voterRegistrationIsOpened == true, "The voters registration session must be open before it can be closed");
        voterRegistrationIsOpened = false;
        previousSessionStatus = currentSessionStatus;
        currentSessionStatus = WorkflowStatus.VotersRegistrationEnded;
        emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
        confirmation = "The voters registration is now closed";
    }

    function openProposalRegistration() public returns (string memory confirmation) {
        require(msg.sender == contractOwner, "Only the contract's owner can open the proposals registration");
        require(globalSessionIsOpened == true, "The global session must be opened to open the proposals registration");
        proposalRegistrationSessionIsOpened = true;
        previousSessionStatus = currentSessionStatus;
        currentSessionStatus = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
        confirmation = "The proposals registration is now opened";
    }

    function closeProposalRegistration() public returns (string memory confirmation ) {
        require(msg.sender == contractOwner, "Only the contract's owner can close the proposals registration");
        require(proposalRegistrationSessionIsOpened == true, "The proposals registration session must be open before it can be closed");
        proposalRegistrationSessionIsOpened = false;
        previousSessionStatus = currentSessionStatus;
        currentSessionStatus = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
        confirmation = "The proposals registration is now closed";
    }

    function openVotingSession() public returns (string memory confirmation) {
        require(msg.sender == contractOwner, "Only the contract's owner can open the voting session");
        require(globalSessionIsOpened == true, "The global session must be opened to open the votes registration");
        votingSessionIsOpened = true;
        previousSessionStatus = currentSessionStatus;
        currentSessionStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
        confirmation = "The voting session is now opened";
    }

    function closeVotingSession() public returns (string memory confirmation) {
        require(msg.sender == contractOwner, "Only the contract's owner can close the voting session");
        require(votingSessionIsOpened == true, "The voting registration session must be open before it can be closed");
        votingSessionIsOpened = false;
        previousSessionStatus = currentSessionStatus;
        currentSessionStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
        confirmation = "The voting session is now closed";
    }

    // Gives to contractOwner the possibility to reset the global session, going back to the voters registration session
    // and to cancel the former session. It means : reset proposals, votes
    function resetGlobalSession(string calldata message) public {
        require(msg.sender == contractOwner, "Only the contract's owner can reset the global session");
        require(globalSessionIsOpened == true, "The global session must be opened to be reset");
        string memory log = string.concat("The session has been fully reset for the following reason(s) : ", message);
        emit SessionReset(log);
        openNewSession();
        openProposalRegistration();
    }

    // Give to contractOwner the possibility to reset only the voting session. Going back to the proposals submission session
    // and to cancel the former submitted proposals and submitted votes.
    function resetVotingSession(string calldata message) public {
        require(msg.sender == contractOwner, "Only the contract's owner can reset the voting session");
        require(globalSessionIsOpened == true && votingSessionIsOpened == true, "The global session & voting session must be opened to reset the voting session");
        string memory log = string.concat("The session has been reset to the proposals submission session for the following reason(s) : ", message);
        emit VotingSessionReset(log);
        for (uint i = 0; i < votersAddresses.length; i++) {
            voters[votersAddresses[i]].hasVoted = false;
        }
        delete proposals;
        closeVotingSession();
        openProposalRegistration();
    }

    // Gives to contractOwner the possibility to add a single voter
    function registerVoter(address voterToAdd) public checkVoter(voterToAdd) returns (string memory confirmation) {
        require(msg.sender == contractOwner, "Only the contract's owner can add voter");
        require(globalSessionIsOpened == true, "The global session must be opened to open registration of a voter");
        require(currentSessionStatus == WorkflowStatus.VotersRegistrationStarted, "The voters registration session is closed. You cannot add new voters");
        voters[voterToAdd].isRegistered = true;
        voters[voterToAdd].hasVoted = false;
        votersAddresses.push(voterToAdd);
        emit VoterRegistered(voterToAdd);
        confirmation = "Voter registered";
    } 

    function registerVoters(address[] calldata votersToAdd) public returns (string memory confirmation) {
        require(msg.sender == contractOwner, "Only the contract's owner can add voters");
        require(globalSessionIsOpened == true, "The global session must be opened to open the registration of voters");
        require(currentSessionStatus == WorkflowStatus.VotersRegistrationStarted, "The voters registration session is closed. You cannot add a new voter");
        for (uint i = 0; i < votersToAdd.length; i++) {
            registerVoter(votersToAdd[i]);
        }
        confirmation = "Voters registered";
    } 

    // Gives to contractOwner the possibility to remove a registered voter at anytime
      function removeVoter(address voterToRemove) public returns (string memory confirmation) {
        require(msg.sender == contractOwner, "Only the contract's owner can remove voter");
        require(globalSessionIsOpened == true && votersAddresses.length > 0, "The global session must be opened & the number of voters must be > 0 to remove a voter");
        Voter storage voter = voters[voterToRemove];
        proposals[voter.votedProposalId].voteCount-- ;
        delete voters[voterToRemove];
        emit VoterRemoved(voterToRemove);
        confirmation = "Voters removed";
    }

    // Gives to contractOwner the possibility to remove several registered voters at anytime
    function removeVoters(address[] memory votersToRemove) public returns (string memory confirmation) {
        require(msg.sender == contractOwner, "Only the contract's owner can remove voters");
        require(globalSessionIsOpened == true && votersAddresses.length > 0, "The global session must be opened & the number of voters must be > 0 to remove voters");
        for (uint i = 0; i < votersToRemove.length; i++) {
            removeVoter(votersToRemove[i]);
        }
        confirmation = "Voters removed";
    } 

    function submitProposal(string calldata descritpion) public returns (string memory confirmation) {
        require(voters[msg.sender].isRegistered == true, "You are not allowed to submit proposals.");
        require(currentSessionStatus == WorkflowStatus.ProposalsRegistrationStarted, "The session for submitting proposals is not opened.");
        Proposal memory proposal = Proposal(msg.sender, descritpion, 0);
        proposals.push(proposal);
        emit ProposalRegistered(proposals.length-1);
        confirmation = "Proposal submitted";
    }

    function vote(uint proposalId) public returns (string memory confirmation) {
        require(currentSessionStatus == WorkflowStatus.VotingSessionStarted, "The voting session is not opened.");
        Voter storage voter = voters[msg.sender];
        require(voter.isRegistered, "You are not allowed to vote.");
        require(!voter.hasVoted, "Already voted.");
        voter.hasVoted = true;
        voter.votedProposalId = proposalId;
        proposals[proposalId].voteCount++;
        emit Voted(msg.sender, voter.votedProposalId);
        confirmation = "Vote registered";
    }

   function consultVote(address voterToConsult) public view returns (string memory voteToDisplay) {
        require(voters[msg.sender].isRegistered, "Voter unknown");
        require(globalSessionIsOpened == true && currentSessionStatus == WorkflowStatus.VotingSessionStarted, "The global session & voting session must be opened to consult the vote of another voter");
        require(voters[voterToConsult].hasVoted == true, "You cannot consult this voter's vote because this voter has not voted yet");
        uint256 proposalId = voters[voterToConsult].votedProposalId;
        string storage proposalDescription = proposals[proposalId].description;
        voteToDisplay = string.concat("Voter ", Strings.toHexString(voterToConsult), " has voted for proposal #", Strings.toString(proposalId), " : ", proposalDescription);
    }

    function displayProposals() public view returns (string memory proposalsToString) {
        require(voters[msg.sender].isRegistered, "You are not allowed to consult the proposals list.");
        require(proposals.length > 0, "No proposal submitted so far.");
        for (uint i = 0; i < proposals.length; i++) {
            proposalsToString = string.concat(proposalsToString, "- #", Strings.toString(i), " - ", proposals[i].description, "\n");
        }
    }

    function winningProposal() view private returns (uint winningProposalId) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposalId = p;
            }
        }
    }

    function tallyVotes() public  {
        require(msg.sender == contractOwner, "Only the contract's owner can count the votes and announce the winner.");
        require(proposals.length > 0, "There must be at least 1 proposal to tally the votes");
        previousSessionStatus = currentSessionStatus;
        currentSessionStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(previousSessionStatus, currentSessionStatus);
    }

    function getWinner() view public returns (address winnerID) {
        require(currentSessionStatus == WorkflowStatus.VotesTallied, "The votes must have been tailled to determine the winner");
        winnerID = proposals[winningProposal()].hasBeenSubmittedBy;
    }

    function getWinningProposal() public view returns (string memory winningProp) {
        require(currentSessionStatus == WorkflowStatus.VotesTallied, "The votes must have been tailled to determine the winning proposal");
        winningProp = proposals[winningProposal()].description;
    }

}