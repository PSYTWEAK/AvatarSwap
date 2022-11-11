import { expect } from "chai";
import { ethers } from "hardhat";
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";

// this test suite is for the AvatarSwap contract

const testCollectionData = [
  {
    ranges: ["10", "20", "30"],
    avatarTypes: ["Avo Cato", "Hot Dog", "Mouse au Chocolat"],
  },
];

describe("Accept Best Offer Referral", function () {
  // @ts-ignore
  let avatarSwap: any, referralRouterAddress: any, owner: any, addr1: any, addr2: any, testAvatar: any, testWETH: any;

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

    // Approve AvatarSwap contract to spend tokens
    await testWETH.connect(owner).approve(avatarSwap.address, "10000000000000000000000");

    // Deploy ERC721 contract
    const TestAvatar = await ethers.getContractFactory("TestAvatar");
    // @ts-ignore
    testAvatar = await TestAvatar.deploy();
    await testAvatar.deployed();

    // Mint ERC1155 tokens
    // @ts-ignore
    await testAvatar.mint(addr1.address, 1, 1);
    await testAvatar.mint(addr1.address, 2, 1);

    await avatarSwap.addCollection(
      testAvatar.address,
      // @ts-ignore
      testCollectionData[0].ranges,
      // @ts-ignore
      testCollectionData[0].avatarTypes
    );

    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "100000", 0, 0);
    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "150000", 0, 1);
    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "200000", 0, 2);

    await avatarSwap.connect(owner).createReferral();
    const referralCode = await avatarSwap.getReferralCode(owner.address);
    referralRouterAddress = await avatarSwap.getReferralRouter(referralCode);
  });

  it("Should accept best offer when testAvatar is transfered to AvatarSwap", async function () {
    let balanceBefore = await testWETH.balanceOf(addr1.address);
    // transfer id 2 of testAvatar to AvatarSwap
    await testAvatar.connect(addr1).safeTransferFrom(addr1.address, referralRouterAddress, 1, 1, "0x");
    let balanceAfter = await testWETH.balanceOf(addr1.address);
    let expectedBalanceIncrease = 200000 - 200000 / 50;
    expect(balanceAfter).to.equal(balanceBefore.add(expectedBalanceIncrease.toString()));
  });

  it("Should accept best offer when testAvatar is transfered to AvatarSwap", async function () {
    let balanceBefore = await testWETH.balanceOf(addr1.address);
    // transfer id 2 of testAvatar to AvatarSwap
    await testAvatar.connect(addr1).safeTransferFrom(addr1.address, referralRouterAddress, 2, 1, "0x");
    let balanceAfter = await testWETH.balanceOf(addr1.address);
    let expectedBalanceIncrease = 150000 - 150000 / 50;

    expect(balanceAfter).to.equal(balanceBefore.add(expectedBalanceIncrease.toString()));
  });
});
