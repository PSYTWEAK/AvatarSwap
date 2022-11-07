import { ethers } from "hardhat";
import { testCollectionData } from "./testCollectionData";

export async function fixture([owner, addr1, addr2]) {
    const AvatarSwap = await ethers.getContractFactory("AvatarSwap");
    const avatarSwap = await AvatarSwap.deploy();
    await avatarSwap.deployed();

    console.log("Deployed AvatarSwap contract to:", avatarSwap.address);

    // Deploy ERC721 contract
    const ERC1155 = await ethers.getContractFactory("ERC1155");
    const erc1155 = await ERC1155.deploy();
    await erc1155.deployed();

    console.log("Deployed ERC1155 contract to:", erc1155.address);

    // Mint ERC1155 tokens
    await erc1155.mint(owner.address, 0, 40, "0x");

    console.log("Minted ERC1155 tokens to:", owner.address);

    // add collections

    await avatarSwap.addCollection(
        erc1155.address,
        testCollectionData.ranges,
        testCollectionData.avatarTypes
      );


    console.log("Collections added to AvatarSwap");

    return { avatarSwap, owner, addr1, addr2, erc1155 };
  }