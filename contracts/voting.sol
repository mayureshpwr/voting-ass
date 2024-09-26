
/*
 \ \    / / __ \__   __|_   _| \ | |/ ____|    / ____/ __ \| \ | |__   __|  __ \     /\   / ____|__   __|
  \ \  / / |  | | | |    | | |  \| | |  __    | |   | |  | |  \| |  | |  | |__) |   /  \ | |       | |   
   \ \/ /| |  | | | |    | | | . ` | | |_ |   | |   | |  | | . ` |  | |  |  _  /   / /\ \| |       | |   
    \  / | |__| | | |   _| |_| |\  | |__| |   | |___| |__| | |\  |  | |  | | \ \  / ____ \ |____   | |   
     \/   \____/  |_|  |_____|_| \_|\_____|    \_____\____/|_| \_|  |_|  |_|  \_\/_/    \_\_____|  |_|   
*/                                           

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: voting.sol


pragma solidity ^0.8.0;

/**
 * @title Voting Contract
 * @dev A simple voting contract that allows users to create proposals and vote on them.
 * Only the owner of the contract can pause or unpause it.
 * The contract uses OpenZeppelin's Pausable contract to implement an emergency stop mechanism.
 */
contract Voting is Pausable {

    // Structure to store information about each proposal
    struct Proposal {
        uint256 id;  // Unique identifier for each proposal
        string description;  // Description of the proposal
        uint128 votesFor;  // Number of votes in favor of the proposal
        uint128 votesAgainst;  // Number of votes against the proposal
        uint256 expirationTime;  // Time after which voting ends
    }

    address public owner;  // The owner of the contract
    uint256 public proposalCounter;  // Counter to track the number of proposals

    // Mapping from proposal ID to Proposal struct
    mapping(uint256 => Proposal) public proposals;

    // Nested mapping to track if a user has voted on a specific proposal
    // proposalId => voter address => bool (true if voted)
    mapping(uint256 => mapping(address => bool)) public votes;

    // Array to store all proposal IDs, useful for fetching all proposals
    uint256[] public proposalIds;

    // Events
    event ProposalCreated(uint256 indexed proposalId, address indexed creator);
    event VoteCast(address indexed voter, uint256 indexed proposalId, bool inFavor);

    /**
     * @dev Initializes the contract and sets the deployer as the owner.
     * The contract starts in an unpaused state by default.
     */
    constructor() {
        owner = msg.sender;  // The deployer of the contract becomes the owner
        proposalCounter = 0;  // Initialize the proposal counter to 0
    }

    // Modifier to check if the proposal exists
    modifier proposalExists(uint256 _proposalId) {
        require(proposals[_proposalId].id == _proposalId, "Proposal does not exist");
        _;
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    /**
     * @dev Allows any user to create a new proposal.
     * Can only be called when the contract is not paused.
     * @param _description The description of the proposal.
     * @param _durationInMinutes The duration (in minutes) for which the proposal will be active.
     */
    function createProposal(string memory _description, uint256 _durationInMinutes) public whenNotPaused {
        uint256 proposalId = proposalCounter;  // Assign a new proposal ID
        proposalCounter++;  // Increment the proposal counter
        
        // Create a new proposal and add it to the proposals mapping
        proposals[proposalId] = Proposal({
            id: proposalId,
            description: _description,
            votesFor: 0,
            votesAgainst: 0,
            expirationTime: block.timestamp + (_durationInMinutes * 1 minutes)
        });
        
        // Store the proposal ID in the proposalIds array for easier access
        proposalIds.push(proposalId);

        // Emit an event to log the proposal creation
        emit ProposalCreated(proposalId, msg.sender);
    }

    /**
     * @dev Allows users to vote on an active proposal.
     * Can only be called when the contract is not paused.
     * @param _proposalId The ID of the proposal the user wants to vote on.
     * @param _inFavor True if the user votes in favor of the proposal, false if they vote against it.
     */
    function vote(uint256 _proposalId, bool _inFavor) public whenNotPaused proposalExists(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];  // Fetch the proposal by ID
        
        // Ensure the voting period is still active
        require(block.timestamp < proposal.expirationTime, "Voting period has ended for this proposal");

        // Check if the user has already voted on this proposal
        require(!votes[_proposalId][msg.sender], "You have already voted on this proposal");

        // Update the vote count based on whether the user voted in favor or against
        if (_inFavor) {
            proposal.votesFor += 1;
        } else {
            proposal.votesAgainst += 1;
        }

        // Mark that the user has voted on this proposal
        votes[_proposalId][msg.sender] = true;

        // Emit an event to log the vote
        emit VoteCast(msg.sender, _proposalId, _inFavor);
    }

    /**
     * @dev Pauses the contract, disabling proposal creation and voting.
     * Only callable by the owner of the contract.
     */
    function pauseContract() public onlyOwner {
        _pause();  // Call the inherited function from the Pausable contract
    }

    /**
     * @dev Unpauses the contract, enabling proposal creation and voting.
     * Only callable by the owner of the contract.
     */
    function unpauseContract() public onlyOwner {
        _unpause();  // Call the inherited function from the Pausable contract
    }

    /**
     * @dev Checks if a proposal is still active.
     * @param _proposalId The ID of the proposal to check.
     * @return bool Returns true if the proposal is still active, false if expired.
     */
    function checkProposalStatus(uint256 _proposalId) public view proposalExists(_proposalId) returns (bool) {
        // A proposal is active if the current timestamp is less than the expiration time
        return block.timestamp < proposals[_proposalId].expirationTime;
    }

    /**
     * @dev Returns the current vote counts for a given proposal.
     * @param _proposalId The ID of the proposal to fetch vote counts for.
     * @return votesFor The number of votes in favor of the proposal.
     * @return votesAgainst The number of votes against the proposal.
     */
    function getVoteCounts(uint256 _proposalId) public view proposalExists(_proposalId) returns (uint256 votesFor, uint256 votesAgainst) {
        Proposal memory proposal = proposals[_proposalId];  // Fetch the proposal from storage
        return (proposal.votesFor, proposal.votesAgainst);  // Return the vote counts
    }

    /**
     * @dev Returns the details of a specific proposal.
     * @param _proposalId The ID of the proposal to fetch details for.
     * @return id The ID of the proposal.
     * @return description The description of the proposal.
     * @return votesFor The number of votes in favor of the proposal.
     * @return votesAgainst The number of votes against the proposal.
     * @return expirationTime The time when the voting period ends.
     * @return timeLeft The time remaining for voting on this proposal.
     */
    function getProposalDetails(uint256 _proposalId) public view proposalExists(_proposalId) returns (
        uint256 id,
        string memory description,
        uint256 votesFor,
        uint256 votesAgainst,
        uint256 expirationTime,
        uint256 timeLeft
    ) {
        Proposal memory proposal = proposals[_proposalId];  // Fetch the proposal by ID
        
        // Calculate the remaining time for voting, if the proposal hasn't expired
        uint256 remainingTime = proposal.expirationTime > block.timestamp 
            ? proposal.expirationTime - block.timestamp 
            : 0;
        
        // Return all the details of the proposal
        return (
            proposal.id, 
            proposal.description, 
            proposal.votesFor, 
            proposal.votesAgainst, 
            proposal.expirationTime, 
            remainingTime
        );
    }

    /**
     * @dev Returns an array of all proposal IDs.
     * Useful for fetching all existing proposals.
     * @return uint256[] An array of proposal IDs.
     */
    function getAllProposals() public view returns (uint256[] memory) {
        return proposalIds;  // Return the array of proposal IDs
    }

    /**
     * @dev Checks if a specific user has voted on a given proposal.
     * @param _proposalId The ID of the proposal.
     * @param _voter The address of the voter.
     * @return bool Returns true if the user has voted, false otherwise.
     */
    function hasVotedOnProposal(uint256 _proposalId, address _voter) public view proposalExists(_proposalId) returns (bool) {
        return votes[_proposalId][_voter];  // Return whether the user has voted on the proposal
    }

    /**
     * @dev Transfers ownership of the contract to a new address.
     * Only callable by the current owner.
     * @param _newOwner The address of the new owner.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner cannot be the zero address");
        owner = _newOwner;  // Transfer ownership to the new address
    }
}
