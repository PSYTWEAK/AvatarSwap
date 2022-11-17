import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    polygon: {
      url: "https://rpc-mainnet.matic.quiknode.pro",
      // @ts-ignore
      accounts: [process.env.PRIVATE_KEY],
      gas: 10000000,
    },
    // hardhat: { allowUnlimitedContractSize: true },
  },
};

export default config;
