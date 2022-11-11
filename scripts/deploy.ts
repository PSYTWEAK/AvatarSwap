import { ethers } from "hardhat";
// @ts-ignore
const collectionData = [
  {
    collectionAddress: "0x91E51B92a2EfEA89bF1B6f66ad719737264724bE",
    ranges: [
      900, // if ID lower than 900, it's an Avo Cato
      1049, // if ID lower than 1049, it's a Hot Dog
      2238,
    ], // if ID lower than 2238, it's a Mouse au Chocolat
    avatarTypes: ["Avo Cato", "Hot Dog", "Mouse au Chocolat"],
  },
  {
    collectionAddress: "0x622d8FeA4603BA9EdAF1084B407052D8b0A9bed7",
    ranges: [250000],
    avatarTypes: ["Argentina"],
  },
];

async function main() {
  const AvatarSwap = await ethers.getContractFactory("AvatarSwap");

  const avatarSwap = await AvatarSwap.attach("0xd0870Dd658e5e75b091B23464DBD55De45f8d181");

  console.log("AvatarSwap deployed to:", avatarSwap.address);

  await avatarSwap.addCollection(collectionData[1].collectionAddress, collectionData[1].ranges, collectionData[1].avatarTypes);

  console.log("Collections added to AvatarSwap");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
