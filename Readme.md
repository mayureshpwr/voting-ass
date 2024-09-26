# Voting Contract

## Overview

The Voting Contract allows users to create proposals and vote on them. The contract is secured with OpenZeppelin's `Pausable` contract, allowing the owner to pause the contract in case of emergencies. The contract enables users to vote on active proposals with protections against double voting and voting after the proposal's expiration.

### Features:
- **Proposal Creation**: Any user can create a proposal with a specified duration.
- **Voting**: Users can vote in favor or against a proposal. Each user can vote only once per proposal.
- **Pausable**: The owner can pause and unpause the contract to halt actions like creating proposals or voting.
- **Ownership Transfer**: The owner can transfer ownership of the contract to another address.
- **Reentrancy Guard**: Prevents reentrancy attacks on state-changing functions.

---

## Prerequisites

To run and test the contract locally, ensure you have the following installed:

- [Node.js](https://nodejs.org/) (version 14 or above)
- [npm](https://www.npmjs.com/)
- Hardhat (already configured in the project)

---

## Project Structure

```plaintext
.
├── contracts
│   └── Voting.sol       # The main voting contract
├── test
│   └── voting.test.js   # Test cases for the voting contract
├── node_modules/        # All necessary node dependencies (already installed)
├── artifacts/           # Compiled contract artifacts (already generated)
├── hardhat.config.js    # Hardhat configuration file
└── package.json         # Project dependencies and scripts
```

---

## Getting Started

### 1. Install Dependencies

Since the repository already contains the `node_modules` folder, this step is not necessary. However, if you want to reinstall the dependencies, run:

```bash
npm install
```

This will install all required dependencies such as Hardhat and OpenZeppelin contracts.

### 2. Running the Tests

The contract has already been compiled, so you just need to run the tests to ensure everything works correctly. The tests are located in the `test/voting.test.js` file and cover the following:

- Proposal creation.
- Voting logic, including edge cases like double voting and voting after expiration.
- Contract pausing and unpausing.

To run the tests:

1. Navigate to the project directory where the contract is located:

    ```bash
    cd C:\blockchain projects\voting ass
    ```

2. Run the test cases using the following command:

    ```bash
    npx hardhat test
    ```

This will execute all unit tests using the Hardhat testing framework and give you the results.

--- ![test case output](image.png)

## Steps to Deploy the Contract

You can deploy this contract using two different methods: **Hardhat** or **Remix IDE**.

### Option 1: Deploy Using Hardhat

1. **Compile the Contract:**

   First, compile the contract using Hardhat. Open your terminal in the project folder and run:

   ```bash
   npx hardhat compile
   ```

   This compiles the contract and generates the necessary artifacts in the `artifacts/` folder.

2. **Deploy the Contract:**

   You can deploy the contract to a local or remote blockchain (e.g., sepolia or bnb testnet). First, ensure your Hardhat configuration is set up for the network.

   For local deployment (optional), start the local blockchain node:

   ```bash
   npx hardhat node
   ```

   Then, deploy the contract using:

   ```bash
   npx hardhat run scripts/deploy.js --network localhost
   ```

   If deploying to sepolia or bnb or any other network, configure the network in `hardhat.config.js`, and use:

   ```bash
   npx hardhat run scripts/deploy.js --network sepolia or bnb
   ```

3. **Interact with the Contract:**

   Once deployed, you can interact with the contract via Hardhat scripts, directly through the Hardhat console, or using the block explorer if deployed on a public testnet (e.g., sepolia or bnb).

### Option 2: Deploy Using Remix IDE

1. **Open Remix IDE**:

   Navigate to the [Remix IDE](https://remix.ethereum.org/) in your browser.

2. **Create a New File**:

   In the file explorer, create a new file and name it `Voting.sol`.

3. **Copy the Contract Code**:

   Copy the code from the `contracts/Voting.sol` file in your repository and paste it into the newly created `Voting.sol` file in Remix.

4. **Compile the Contract**:

   Click on the "Solidity Compiler" tab on the left sidebar and press the "Compile Voting.sol" button.

5. **Deploy the Contract**:

   - Go to the "Deploy & Run Transactions" tab.
   - Select the environment (either **Injected Web3** if you are using Metamask or **JavaScript VM** for local testing).
   - Set the gas limit and deployment parameters if needed.
   - Click the "Deploy" button to deploy the contract.

6. **Interact with the Contract**:

   Once deployed, you will see the contract instance appear in the "Deployed Contracts" section. You can now interact with the contract using the available functions (e.g., `createProposal`, `vote`, `pauseContract`, etc.).

---

## Interacting with the Deployed Contract on bnb

The contract is deployed on the Bnb testnet. Here are the basic details:

- **Contract Address**: `0xd813D3dAde1c4C75517966338a8fea2B421ED7c2`
- **Network**: Bnb testnet
- **Link** : (https://testnet.bscscan.com/address/0xd813D3dAde1c4C75517966338a8fea2B421ED7c2#code)
---

### Compile the Contract (if needed)

If you make any changes to the contract and need to recompile it, use:

```bash
npx hardhat compile
```