import { expect } from "chai";
import { ethers } from "hardhat";
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";

// this test suite is for the AvatarSwap contract

const testCollectionData = [
  {
    // collectionAddress: "0x91E51B92a2EfEA89bF1B6f66ad719737264724bE", using contract generated in fixture
    ranges: [
      [1, 10],
      [11, 20],
      [21, 31],
    ],
    avatarTypes: ["Avo Cato", "Hot Dog", "Mouse au Chocolat"],
  },
];

describe("Accept Best Offer", function () {
  // @ts-ignore
  let avatarSwap: any, owner: any, addr1: any, addr2: any, testAvatar: any, testWETH: any, unlistedAvatar: any;

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

    await avatarSwap.addCollectionRanges(
      testAvatar.address,
      // @ts-ignore
      testCollectionData[0].ranges
    );
    await avatarSwap.addCollectionTypes(
      testAvatar.address,
      // @ts-ignore
      testCollectionData[0].ranges,
      // @ts-ignore
      testCollectionData[0].avatarTypes
    );

    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "100000", 0, 0);
    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "150000", 0, 1);
    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "200000", 0, 2);

    unlistedAvatar = await TestAvatar.deploy();
    await unlistedAvatar.deployed();
    await unlistedAvatar.mint(addr1.address, 1, 1);
  });

  it("Should fail to accept any unlistedAvatar", async function () {
    await expect(unlistedAvatar.connect(addr1).safeTransferFrom(addr1.address, avatarSwap.address, 1, 1, "0x")).to.be.revertedWith("ERC1155: transfer to non ERC1155Receiver implementer");
  });
  it("Should fail to accept an unlisted ID", async function () {
    await testAvatar.mint(addr1.address, 400, 1);
    await expect(testAvatar.connect(addr1).safeTransferFrom(addr1.address, avatarSwap.address, 400, 1, "0x")).to.be.revertedWith("AvatarSwap: Avatar type not found");
  });

  it("Should accept best offer when testAvatar is transfered to AvatarSwap", async function () {
    let balanceBefore = await testWETH.balanceOf(addr1.address);
    // transfer id 2 of testAvatar to AvatarSwap
    await testAvatar.connect(addr1).safeTransferFrom(addr1.address, avatarSwap.address, 1, 1, "0x");
    let balanceAfter = await testWETH.balanceOf(addr1.address);
    let expectedBalanceIncrease = 200000 - 200000 / 25;

    expect(balanceAfter).to.equal(balanceBefore.add(expectedBalanceIncrease.toString()));
  });
  it("Offer 3 should have been deleted", async function () {
    const offer = await avatarSwap.getOffer(testAvatar.address, "Avo Cato", 3);

    expect(offer.maker).to.equal("0x0000000000000000000000000000000000000000");
    expect(offer.price).to.equal(0);
    expect(offer.below).to.equal(0);
    expect(offer.above).to.equal(0);
  });
  it("Best offerID should equal 2", async function () {
    const bestOfferId = await avatarSwap.getBestOfferId(testAvatar.address, "Avo Cato");
    expect(bestOfferId).to.equal(2);
  });

  it("Should accept best offer when testAvatar is transfered to AvatarSwap", async function () {
    let balanceBefore = await testWETH.balanceOf(addr1.address);
    // transfer id 2 of testAvatar to AvatarSwap
    await testAvatar.connect(addr1).safeTransferFrom(addr1.address, avatarSwap.address, 2, 1, "0x");
    let balanceAfter = await testWETH.balanceOf(addr1.address);
    let expectedBalanceIncrease = 150000 - 150000 / 25;

    expect(balanceAfter).to.equal(balanceBefore.add(expectedBalanceIncrease.toString()));
  });
  it("Offer 2 should have been deleted", async function () {
    const offer = await avatarSwap.getOffer(testAvatar.address, "Avo Cato", 2);

    expect(offer.maker).to.equal("0x0000000000000000000000000000000000000000");
    expect(offer.price).to.equal(0);
    expect(offer.below).to.equal(0);
    expect(offer.above).to.equal(0);
  });
  it("Best offerID should equal 1", async function () {
    const bestOfferId = await avatarSwap.getBestOfferId(testAvatar.address, "Avo Cato");
    expect(bestOfferId).to.equal(1);
  });
});
