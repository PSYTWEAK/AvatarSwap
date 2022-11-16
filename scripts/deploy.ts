import { ethers } from "hardhat";
// @ts-ignore
const collectionData = [
  {
    collectionAddress: "0x622d8FeA4603BA9EdAF1084B407052D8b0A9bed7",
    ranges: [
      [0, 200099],
      [200100, 400199],
      [400200, 600299],
      [600300, 800399],
      [800400, 1000499],
      [1000500, 1200599],
      [1200600, 1400699],
      [1400700, 1600799],
      [1600800, 1800899],
      [1800900, 2000999],
      [2001000, 2201099],
      [2201100, 2401199],
      [2401200, 2601299],
      [2601300, 2801399],
      [2801400, 3801499],
      [3801500, 4001599],
      [4001600, 4201699],
      [4201700, 4401799],
      [4401800, 4801999],
      [4802000, 5002099],
      [5002100, 5202199],
      [5202200, 5402299],
      [5402300, 5802499],
      [5802500, 6202699],
      [6202700, 6402799],
      [6402800, 6602899],
      [6602900, 6802999],
      [6803000, 7003099],
      [7003100, 8003199],
      [8003200, 8203199],
    ],
    avatarTypes: [
      "Argentina",
      "Australia",
      "Belgium",
      "Brazil",
      "Cameroon",
      "Canada",
      "Costa Rica",
      "Croatia",
      "Denmark",
      "Ecuador",
      "England",
      "France",
      "Germany",
      "Ghana",
      "Earth",
      "Iran",
      "Japan",
      "South Korea",
      "Mexico",
      "Netherlands",
      "Poland",
      "Portugal",
      "Qatar",
      "Senegal",
      "spain",
      "Switzerland",
      "Tunisia",
      "Uruguay",
      "USA",
      "Wales",
    ],
  },
];

async function main() {
  const AvatarSwap = await ethers.getContractFactory("AvatarSwap");

  const avatarSwap = await AvatarSwap.deploy("0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619");

  await avatarSwap.deployed();

  console.log("AvatarSwap deployed to:", avatarSwap.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
