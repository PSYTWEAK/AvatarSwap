import { ethers } from "hardhat";
// @ts-ignore
import { collectionData } from "./collectionData";

async function main() {
  const AvatarSwap = await ethers.getContractFactory("AvatarSwap");
  const avatarSwap = await AvatarSwap.deploy();
  console.log("AvatarSwap deployed to:", avatarSwap.address);
 
  avatarSwap.deployed();

  // add collections
  for (let i = 0; i < collectionData.length; i++) {
      avatarSwap.addCollection(collectionData.collectionAddress, collectionData.ranges, collectionData.avatarTypes)
  }

  console.log("Collections added to AvatarSwap");



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
