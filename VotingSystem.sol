// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract VotingSystem {
    address public admin;
    bool public votingActive;
    bool public votingEnded;

    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    mapping(uint256 => Candidate) public candidates;
    mapping(address => bool) public voters;
    uint256 public candidatesCount;

    event CandidateAdded(uint256 id, string name);
    event CandidateDeleted(uint256 id);
    event VotingStarted();
    event VotingEnded();
    event Voted(address voter, uint256 candidateId);
    event WinnerDeclared(uint256 winnerId, string winnerName);
    event AdminTransferred(address newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier whenVotingActive() {
        require(votingActive, "Voting is not active");
        _;
    }

    constructor(address _admin) {
        admin = _admin;
    }

    function addCandidate(string memory _name) public onlyAdmin {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }

    function deleteCandidate(uint256 _candidateId) public onlyAdmin {
        require(_candidateId <= candidatesCount, "Invalid candidate ID");
        delete candidates[_candidateId];
        emit CandidateDeleted(_candidateId);
    }

    function startVoting() public onlyAdmin {
        require(!votingActive, "Voting is already active");
        votingActive = true;
        votingEnded = false;
        emit VotingStarted();
    }

    function endVoting() public onlyAdmin whenVotingActive {
        votingActive = false;
        votingEnded = true;
        emit VotingEnded();
    }

    function vote(uint256 _candidateId) public whenVotingActive {
        require(!voters[msg.sender], "You have already voted");
        require(candidates[_candidateId].id != 0, "Invalid candidate");

        voters[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        emit Voted(msg.sender, _candidateId);
    }

    function declareWinner() public onlyAdmin {
        require(votingEnded, "Voting must be ended to declare a winner");

        uint256 highestVotes = 0;
        uint256 winnerId;

        for (uint256 i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > highestVotes) {
                highestVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }

        emit WinnerDeclared(winnerId, candidates[winnerId].name);
    }

    function transferOwnership(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        admin = newAdmin;
        emit AdminTransferred(newAdmin);
    }

    function getCandidate(uint256 _candidateId) public view returns (string memory, uint256) {
        require(_candidateId <= candidatesCount, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.name, candidate.voteCount);
    }

    function getCandidatesCount() public view returns (uint256) {
        return candidatesCount;
    }
}
