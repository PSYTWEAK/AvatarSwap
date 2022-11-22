import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    polygon: {
      url: "https://polygon-mainnet.infura.io/v3/30939c22e73b45fd8c965adc6ccfc3fa",
      // @ts-ignore
      accounts: [process.env.PRIVATE_KEY],
      gas: 10000000,
    },
    // hardhat: { allowUnlimitedContractSize: true },
  },
};

export default config;
