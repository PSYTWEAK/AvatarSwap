import { ethers } from "hardhat";
// @ts-ignore
import { collectionData } from "./collectionData";

async function main() {
  const AvatarSwap = await ethers.getContractFactory("AvatarSwap");

  let avatarSwap = await AvatarSwap.deploy("0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619");

  await avatarSwap.deployed();

  console.log("AvatarSwap deployed to:", avatarSwap.address);

  // add collections
  for (let i = 0; i < collectionData.length; i++) {
    avatarSwap.addCollection(collectionData.collectionAddress, collectionData.ranges, collectionData.avatarTypes);
  }

  console.log("Collections added to AvatarSwap");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
