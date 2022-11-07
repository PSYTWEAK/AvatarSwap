import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { testCollectionData } from "./testCollectionData";

describe("Create Offer", function () {
  // Deploy AvatarSwap contract
  async function fixture([owner, addr1, addr2]) {
    const AvatarSwap = await ethers.getContractFactory("AvatarSwap");
    const avatarSwap = await AvatarSwap.deploy();
    await avatarSwap.deployed();

    // add collections
    for (let i = 0; i < testCollectionData.length; i++) {
      avatarSwap.addCollection(
        testCollectionData.collectionAddress,
        testCollectionData.ranges,
        testCollectionData.avatarTypes
      );
    }

    console.log("Collections added to AvatarSwap");

    return { avatarSwap, owner, addr1, addr2 };
  }

  it("Should create an offer", async function () {
    const { avatarSwap, owner, addr1, addr2 } = await loadFixture(fixture);

  })
});
