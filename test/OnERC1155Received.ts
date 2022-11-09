import { expect } from "chai";
import { ethers } from "hardhat";
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";

// this test suite is for the AvatarSwap contract

const testCollectionData = [
  {
    // collectionAddress: "0x91E51B92a2EfEA89bF1B6f66ad719737264724bE", using contract generated in fixture
    ranges: ["10", "20", "30"],
    avatarTypes: ["Avo Cato", "Hot Dog", "Mouse au Chocolat"],
  },
];

describe("On ERC1155 Received", function () {
  // @ts-ignore
  let avatarSwap: any, owner: any, addr1: any, addr2: any, testAvatar: any, testWETH: any;

  it("loads fixture", async function () {
    let [_owner, _addr1, _addr2] = await ethers.getSigners();
    owner = _owner;
    addr1 = _addr1;
    addr2 = _addr2;
    // Deploy TestToken contract
    const TestWETH = await ethers.getContractFactory("TestERC20");
    testWETH = await TestWETH.deploy();
    await testWETH.deployed();

    // @ts-ignore
    const AvatarSwap = await ethers.getContractFactory("AvatarSwap");
    avatarSwap = await AvatarSwap.deploy(testWETH.address);
    await avatarSwap.deployed();

    // mint tokens to addr1
    await testWETH.mint(addr1.address, "1000000000000000000000");
    // mint tokens to addr2
    await testWETH.mint(addr2.address, "1000000000000000000000");

    // Approve AvatarSwap contract to spend tokens
    await testWETH.connect(addr1).approve(avatarSwap.address, "10000000000000000000000");
    await testWETH.connect(addr2).approve(avatarSwap.address, "10000000000000000000000");
    await testWETH.connect(owner).approve(avatarSwap.address, "10000000000000000000000");

    // Deploy ERC721 contract
    const TestAvatar = await ethers.getContractFactory("TestAvatar");
    // @ts-ignore
    testAvatar = await TestAvatar.deploy();
    await testAvatar.deployed();

    // Mint ERC1155 tokens
    // @ts-ignore
    await testAvatar.mint(owner.address, 0, 40);

    await avatarSwap.addCollection(
      testAvatar.address,
      // @ts-ignore
      testCollectionData[0].ranges,
      // @ts-ignore
      testCollectionData[0].avatarTypes
    );

    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "100000", 0, 0);
    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "150000", 0, 1);
    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "200000", 0, 1);
  });

  it("Should accept best offer when testAvatar is transfered to AvatarSwap", async function () {
    // @ts-ignore
    await testAvatar.connect(owner).safeTransferFrom(owner.address, avatarSwap.address, 0, 1, "0x");
  });
});
