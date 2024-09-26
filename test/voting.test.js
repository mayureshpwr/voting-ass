// test case 10 pass 1 fail 

const assert = require("assert");
const { ethers } = require("hardhat");

describe("Voting Contract", function () {
  let Voting;
  let voting;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    Voting = await ethers.getContractFactory("Voting");
    voting = await Voting.deploy();
    await voting.deployed();
  });

  describe("Proposal Creation", function () {
    it("Should create a new proposal", async function () {
      await voting.createProposal("Is Mayuresh a Blockchain developer?", 60);
      
      const proposal = await voting.getProposalDetails(0);
      
      assert.strictEqual(proposal.id.toString(), "0");
      assert.strictEqual(proposal.description, "Is Mayuresh a Blockchain developer?");
      assert.strictEqual(proposal.votesFor.toString(), "0");
      assert.strictEqual(proposal.votesAgainst.toString(), "0");
    });

    it("Should emit a ProposalCreated event", async function () {
      await voting.createProposal("Proposal 1", 60); 
      const tx = await voting.createProposal("Proposal 2", 60); // Second proposal (ID = 1)
      const receipt = await tx.wait();

      // Checking if the ProposalCreated event was emitted
      const event = receipt.events.find(event => event.event === "ProposalCreated");
      assert.ok(event, "ProposalCreated event was not emitted");

      // Fix: The proposal ID should be 1 (since Proposal 0 was created earlier)
      assert.strictEqual(event.args.proposalId.toString(), "1");
      assert.strictEqual(event.args.creator, owner.address);
    });
  });

  describe("Voting Logic", function () {
    beforeEach(async function () {
      await voting.createProposal("Proposal 1", 60);
    });

    it("Should allow users to vote in favor", async function () {
      await voting.connect(addr1).vote(0, true);
      const proposal = await voting.getVoteCounts(0);
      
      assert.strictEqual(proposal.votesFor.toString(), "1");
      assert.strictEqual(proposal.votesAgainst.toString(), "0");
    });

    it("Should allow users to vote against", async function () {
      await voting.connect(addr1).vote(0, false);
      const proposal = await voting.getVoteCounts(0);
      
      assert.strictEqual(proposal.votesFor.toString(), "0");
      assert.strictEqual(proposal.votesAgainst.toString(), "1");
    });

    it("Should not allow double voting", async function () {
      await voting.connect(addr1).vote(0, true);
      
      try {
        await voting.connect(addr1).vote(0, true);
        assert.fail("Expected the vote to fail, but it succeeded");
      } catch (err) {
        assert.ok(err.message.includes("You have already voted on this proposal"));
      }
    });

    it("Should not allow voting after expiration", async function () {
      await ethers.provider.send("evm_increaseTime", [3600]); // 1 hour
      await ethers.provider.send("evm_mine", []); // Mine a new block
      
      try {
        await voting.connect(addr1).vote(0, true);
        assert.fail("Expected the vote to fail due to expiration, but it succeeded");
      } catch (err) {
        assert.ok(err.message.includes("Voting period has ended for this proposal"));
      }
    });
  });

  describe("Accessing Proposal Data", function () {
    beforeEach(async function () {
      await voting.createProposal("Proposal 1", 60);
      await voting.connect(addr1).vote(0, true);
      await voting.connect(addr2).vote(0, false);
    });

    it("Should return correct proposal data", async function () {
      const proposal = await voting.getProposalDetails(0);
      
      assert.strictEqual(proposal.id.toString(), "0");
      assert.strictEqual(proposal.votesFor.toString(), "1");
      assert.strictEqual(proposal.votesAgainst.toString(), "1");
    });

    it("Should allow access to vote counts", async function () {
      const counts = await voting.getVoteCounts(0);
      
      assert.strictEqual(counts.votesFor.toString(), "1");
      assert.strictEqual(counts.votesAgainst.toString(), "1");
    });

    it("Should check if a user has voted", async function () {
      assert.strictEqual(await voting.hasVotedOnProposal(0, addr1.address), true);
      assert.strictEqual(await voting.hasVotedOnProposal(0, addr2.address), true);
    });
  });

  describe("Contract Pausability", function () {
    it("Should allow the owner to pause and unpause the contract", async function () {
      // Pause the contract
      await voting.pauseContract();
  
      // Trying to create a proposal while the contract is paused and expect it to fail
      try {
        await voting.createProposal("Proposal 3", 60);
        assert.fail("Expected createProposal to fail while paused, but it succeeded");
      } catch (err) {
        assert.ok(err.message.includes("Pausable: paused"));
      }
  
      // Unpause the contract and create a new proposal
      await voting.unpauseContract();
      
      // Now that the contract is unpaused, create a new proposal
      await voting.createProposal("Proposal 3", 60);
  
      // Fetch the correct proposal ID (either 1 or 0, depending on the previous tests)
      const proposal = await voting.getProposalDetails(1); // Adjust this ID if necessary
      assert.strictEqual(proposal.description, "Proposal 3");
    });
  
    it("Should revert if non-owner tries to pause", async function () {
      try {
        await voting.connect(addr1).pauseContract();
        assert.fail("Expected pauseContract to fail for non-owner, but it succeeded");
      } catch (err) {
        assert.ok(err.message.includes("Only the owner can call this function"));
      }
    });
  });
  
});
