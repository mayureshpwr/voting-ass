const { ethers } = require("hardhat");
const assert = require("assert");

describe("NefiToken Zero Amount Test and Contract Access", function () {
    let NefiToken, nefiToken;
    let DEODToken, deodToken;
    let owner, users, contractAddress;
  
    const DEOD_SUPPLY = ethers.utils.parseEther("100000000"); // 100 million DEOD in wei
    const ZERO_AMOUNT = ethers.utils.parseEther("0"); // 0 DEOD in wei
    const DEOD_AMOUNT = ethers.utils.parseEther("10000"); // 10,000 DEOD in wei
  
    before(async function () {
      // Get signers (limited to 5 users)
      [owner, ...users] = await ethers.getSigners();
      contractAddress = owner.address; // Using owner's address as a stand-in for contract testing
  
      // Deploy MockDEODToken contract
      const DEODTokenFactory = await ethers.getContractFactory("MockDEODToken");
      deodToken = await DEODTokenFactory.deploy(DEOD_SUPPLY);
      await deodToken.deployed();
  
      console.log("DEOD token deployed at:", deodToken.address);
  
      // Deploy NefiToken contract
      const NefiTokenFactory = await ethers.getContractFactory("NefiToken");
      nefiToken = await NefiTokenFactory.deploy(deodToken.address);
      await nefiToken.deployed();
  
      console.log("NefiToken deployed at:", nefiToken.address);
  
      // Distribute DEOD to 5 users and approve NefiToken contract to spend their DEOD
      for (let i = 0; i < 5; i++) {
        const user = users[i];
        console.log(`Processing user ${i}, address: ${user.address}`);
  
        // Mint DEOD to each user's address
        await deodToken.transfer(user.address, DEOD_AMOUNT);
  
        // Each user approves the NefiToken contract to spend 10,000 DEOD on their behalf
        await deodToken.connect(user).approve(nefiToken.address, DEOD_AMOUNT);
      }
    });
  
    it("should prevent users from buying NEFI with zero DEOD", async function () {
      for (let i = 0; i < 5; i++) {
        const user = users[i];
        console.log(`User ${i} is attempting to buy NEFI with 0 DEOD...`);
  
        // User attempts to buy with zero DEOD
        await assert.rejects(
          nefiToken.connect(user).BuyNefi(ZERO_AMOUNT),
          /revert/, // Check if the transaction is reverted
          `User ${i} should not be able to buy NEFI with zero DEOD`
        );
      }
    });
  
    it("should prevent users from claiming zero NEFI", async function () {
      for (let i = 0; i < 5; i++) {
        const user = users[i];
        console.log(`User ${i} is attempting to claim 0 NEFI...`);
  
        // User attempts to claim zero NEFI
        await assert.rejects(
          nefiToken.connect(user).claimTokens(ZERO_AMOUNT),
          /revert/, // Check if the transaction is reverted
          `User ${i} should not be able to claim zero NEFI`
        );
      }
    });
  
    it("should prevent users from selling zero NEFI", async function () {
      for (let i = 0; i < 5; i++) {
        const user = users[i];
        console.log(`User ${i} is attempting to sell 0 NEFI...`);
  
        // User attempts to sell zero NEFI
        await assert.rejects(
          nefiToken.connect(user).sellNefi(ZERO_AMOUNT),
          /revert/, // Check if the transaction is reverted
          `User ${i} should not be able to sell zero NEFI`
        );
      }
    });
  
    it("should check if the contract address itself can call these functions", async function () {
      console.log("Checking if the contract address can call these functions...");
  
      // Contract (using owner's address as contract) attempts to buy NEFI with zero DEOD
      await assert.rejects(
        nefiToken.connect(owner).BuyNefi(ZERO_AMOUNT),
        /revert/,
        "Contract should not be able to buy NEFI with zero DEOD"
      );
  
      // Contract (using owner's address as contract) attempts to claim zero NEFI
      await assert.rejects(
        nefiToken.connect(owner).claimTokens(ZERO_AMOUNT),
        /revert/,
        "Contract should not be able to claim zero NEFI"
      );
  
      // Contract (using owner's address as contract) attempts to sell zero NEFI
      await assert.rejects(
        nefiToken.connect(owner).sellNefi(ZERO_AMOUNT),
        /revert/,
        "Contract should not be able to sell zero NEFI"
      );
    });
  });
  