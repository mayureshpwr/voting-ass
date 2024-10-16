require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",   // This matches "^0.8.0" in your contract
      },
      {
        version: "0.8.20",  // This matches "^0.8.20" in your contract
      }
    ]
  }
};