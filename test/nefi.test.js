const { ethers } = require("hardhat");
const assert = require("assert");

describe("NefiToken 5 Users Buy/Claim/Sell with Logs", function () {
  let NefiToken, nefiToken;
  let DEODToken, deodToken;
  let owner, users;

  const DEOD_SUPPLY = ethers.utils.parseEther("100000000"); // 100 million DEOD in wei
  const DEOD_AMOUNT = ethers.utils.parseEther("10000"); // 10,000 DEOD in wei

  // Set a larger timeout for this test suite
  this.timeout(300000); // 5 minutes = 300,000 ms

  before(async function () {
    // Get signers (limited to 5 users)
    [owner, ...users] = await ethers.getSigners();

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

  it("should allow 5 users to buy NEFI with 10,000 DEOD and log after each buy", async function () {
    for (let i = 0; i < 5; i++) {
      const user = users[i];
      console.log(`User ${i} is buying NEFI with 10,000 DEOD...`);

      const tx = await nefiToken.connect(user).BuyNefi(DEOD_AMOUNT);
      const receipt = await tx.wait();

      // Extract event from the transaction receipt
      const event = receipt.events.find(e => e.event === "NefiTokenBuy");
      const [buyer, nefiBuy, currentNefiPrice] = event.args;

      // Verify event emitted with correct values
      assert.strictEqual(buyer, user.address, "Buyer address mismatch");
      assert(nefiBuy.gt(0), "NEFI minted should be greater than 0");

      // Log relevant details after the buy transaction
      const contractDEODBalance = await deodToken.balanceOf(nefiToken.address);
      const nefiPrice = await nefiToken.getCurrentNefiPrice();
      const nefiBalance = await nefiToken.unclaimedNefiTokens(user.address);

      console.log(`User ${i} Nefi token got ${nefiBuy.toString()} NEFI`);
      // console.log(`User ${i} NEFI got: ${ethers.utils.formatEther(nefiBalance)} NEFI`);
      console.log(`Current NEFI price: ${ethers.utils.formatEther(nefiPrice)} DEOD`);
      console.log(`Contract DEOD balance after buying: ${ethers.utils.formatEther(contractDEODBalance)} DEOD`);
      console.log("---------------------------------------------");
    }
  });

  it("should allow the first 3 users to claim NEFI and log after each claim", async function () {
    for (let i = 0; i < 3; i++) {
      const user = users[i];
      console.log(`User ${i} is claiming their NEFI...`);
  
      // Get the unclaimed NEFI tokens for the user
      const nefiBalanceBefore = await nefiToken.unclaimedNefiTokens(user.address);
  
      // Ensure there's enough NEFI to claim
      assert(nefiBalanceBefore.gt(0), "No NEFI to claim");
  
      // Call claimTokens with the user's unclaimed balance
      const tx = await nefiToken.connect(user).claimTokens(nefiBalanceBefore);
      const receipt = await tx.wait();
  
      // Extract event from the transaction receipt
      const event = receipt.events.find(e => e.event === "TokensClaimed");
  
      if (event) {
        const [claimant, claimedAmount] = event.args;
  
        // Verify event emitted with correct values
        assert.strictEqual(claimant, user.address, "Claimant address mismatch");
        assert(claimedAmount.eq(nefiBalanceBefore), "Claimed amount mismatch");
  
        // Log relevant details after the claim
        const nefiBalanceAfter = await nefiToken.unclaimedNefiTokens(user.address);
        console.log(`User ${i} claimed ${ethers.utils.formatEther(claimedAmount)} NEFI`);
        console.log(`User ${i} NEFI balance before claim: ${ethers.utils.formatEther(nefiBalanceBefore)} NEFI`);
        console.log(`User ${i} NEFI balance after claim: ${ethers.utils.formatEther(nefiBalanceAfter)} NEFI`);
      } else {
        console.error(`TokensClaimed event was not emitted for user ${i}`);
      }
  
      console.log("---------------------------------------------");
    }
  });
  

  it("should allow the 4th and 5th users to sell NEFI and log after each sell", async function () {
    // Fast-forward time to bypass the cooldown
    const COOLDOWN_PERIOD = 60; // Assuming 60 seconds cooldown
    await ethers.provider.send("evm_increaseTime", [COOLDOWN_PERIOD]); // Increase time by cooldown period
    await ethers.provider.send("evm_mine"); // Force mine to apply the time shift

    for (let i = 3; i < 5; i++) {
      const user = users[i];
      const nefiBalance = await nefiToken.unclaimedNefiTokens(user.address);
      console.log(`User ${i} NEFI balance before selling: ${ethers.utils.formatEther(nefiBalance)} NEFI`);

      // Ensure NEFI balance is greater than 0
      assert(nefiBalance.gt(0), "NEFI balance should be greater than 0 before selling");

      console.log(`User ${i} is selling ${ethers.utils.formatEther(nefiBalance)} NEFI...`);

      const tx = await nefiToken.connect(user).sellNefi(nefiBalance);
      const receipt = await tx.wait();

      // Extract event from the transaction receipt
      const event = receipt.events.find(e => e.event === "NefiTokenSold");
      const [seller, nefiSold, currentNefiPrice, deodReturned] = event.args;
   
      // Verify event emitted with correct values
      assert.strictEqual(seller, user.address, "Seller address mismatch");
      assert(nefiSold.gt(0), "NEFI sold should be greater than 0");
      assert(deodReturned.gt(0), "DEOD returned should be greater than 0");

      // Log relevant details after the sell transaction
      const contractDEODBalance = await deodToken.balanceOf(nefiToken.address);
      const nefiPrice = await nefiToken.getCurrentNefiPrice();

      console.log(`User ${i} successfully sold ${ethers.utils.formatEther(nefiSold)} NEFI`);
      console.log(`DEOD returned: ${ethers.utils.formatEther(deodReturned)} DEOD`);
      console.log(`Current NEFI price: ${ethers.utils.formatEther(nefiPrice)} DEOD`);
      console.log(`Contract DEOD balance after selling: ${ethers.utils.formatEther(contractDEODBalance)} DEOD`);
      console.log("---------------------------------------------");
    }
  });
});
