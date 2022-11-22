import { ethers } from "hardhat";
// @ts-ignore
const collectionData = [
  {
    name: "Argentina",
    "lowest ID": 0,
    "highest ID": 200099,
  },
  {
    name: "Australia",
    "lowest ID": 200100,
    "highest ID": 400199,
  },
  {
    name: "Belgium",
    "lowest ID": 400200,
    "highest ID": 600299,
  },
  {
    name: "Brazil",
    "lowest ID": 600300,
    "highest ID": 800399,
  },
  {
    name: "Cameroon",
    "lowest ID": 800400,
    "highest ID": 1000499,
  },
  {
    name: "Canada",
    "lowest ID": 1000500,
    "highest ID": 1200599,
  },
  {
    name: "Costa Rica",
    "lowest ID": 1200600,
    "highest ID": 1400699,
  },
  {
    name: "Croatia",
    "lowest ID": 1400700,
    "highest ID": 1600799,
  },
  {
    name: "Denmark",
    "lowest ID": 1600800,
    "highest ID": 1800899,
  },
  {
    name: "Ecuador",
    "lowest ID": 1800900,
    "highest ID": 2000999,
  },
  {
    name: "England",
    "lowest ID": 2001000,
    "highest ID": 2201099,
  },
  {
    name: "France",
    "lowest ID": 2201100,
    "highest ID": 2401199,
  },
  {
    name: "Germany",
    "lowest ID": 2401200,
    "highest ID": 2601299,
  },
  {
    name: "Ghana",
    "lowest ID": 2601300,
    "highest ID": 2801399,
  },
  {
    name: "Earth",
    "lowest ID": 2801400,
    "highest ID": 3801499,
  },
  {
    name: "Iran",
    "lowest ID": 3801500,
    "highest ID": 4001599,
  },
  {
    name: "Japan",
    "lowest ID": 4001600,
    "highest ID": 4201699,
  },
  {
    name: "South Korea",
    "lowest ID": 4201700,
    "highest ID": 4401799,
  },
  {
    name: "Mexico",
    "lowest ID": 4401800,
    "highest ID": 4601899,
  },
  {
    name: "Morocco",
    "lowest ID": 4601900,
    "highest ID": 4801999,
  },
  {
    name: "Netherlands",
    "lowest ID": 4802000,
    "highest ID": 5002099,
  },
  {
    name: "Poland",
    "lowest ID": 5002100,
    "highest ID": 5202199,
  },
  {
    name: "Portugal",
    "lowest ID": 5202200,
    "highest ID": 5402299,
  },
  {
    name: "Qatar",
    "lowest ID": 5402300,
    "highest ID": 5602399,
  },
  {
    name: "Saudi Arabia",
    "lowest ID": 5602400,
    "highest ID": 5802499,
  },
  {
    name: "Senegal",
    "lowest ID": 5802500,
    "highest ID": 6002599,
  },
  {
    name: "Serbia",
    "lowest ID": 6002600,
    "highest ID": 6202699,
  },
  {
    name: "spain",
    "lowest ID": 6202700,
    "highest ID": 6402799,
  },
  {
    name: "Switzerland",
    "lowest ID": 6402800,
    "highest ID": 6602899,
  },
  {
    name: "Tunisia",
    "lowest ID": 6602900,
    "highest ID": 6802999,
  },
  {
    name: "Uruguay",
    "lowest ID": 6803000,
    "highest ID": 7003099,
  },
  {
    name: "USA",
    "lowest ID": 7003100,
    "highest ID": 8003199,
  },
  {
    name: "Wales",
    "lowest ID": 8003200,
    "highest ID": 9203399,
  },
];

const WCCollectionAddress = "0x622d8FeA4603BA9EdAF1084B407052D8b0A9bed7";

async function main() {
  const AvatarSwap = await ethers.getContractFactory("AvatarSwap");

  const avatarSwap = await AvatarSwap.attach("0x43c14639Ca19DedD4a7668F3346667d943f02570");

  console.log("AvatarSwap attached:", avatarSwap.address);
  let names = [];
  let ranges = [];

  for (let i = 0; i < collectionData.length; i++) {
    names.push(collectionData[i].name);
    let range = [collectionData[i]["lowest ID"], collectionData[i]["highest ID"]];
    ranges.push(range);
  }

  const tx = await avatarSwap.addAvatarTypes(WCCollectionAddress, ranges, names);
  console.log("tx:", tx.hash);
  console.log("Collections added to AvatarSwap");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
