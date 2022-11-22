import { expect } from "chai";
import { ethers } from "hardhat";
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";

// this test suite is for the AvatarSwap contract
const testCollectionData = [
  {
    // collectionAddress: "0x91E51B92a2EfEA89bF1B6f66ad719737264724bE", using contract generated in fixture
    indexes: ["0", "1", "2"],
    ranges: [
      [1, 10],
      [11, 20],
      [21, 31],
    ],
    avatarTypes: ["Avo Cato", "Hot Dog", "Mouse au Chocolat"],
  },
];
const testOfferData = {
  avoCatoId: 1,
  hotDog: 2,
};

describe("Create Offer", function () {
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

    await avatarSwap.addAvatarTypes(testAvatar.address, testCollectionData[0].ranges, testCollectionData[0].avatarTypes);
  });

  it("Should create an offer on Avo Cato", async function () {
    // create offer
    await avatarSwap.createOffer(testAvatar.address, testOfferData.avoCatoId, "1000000000000000000", 1, 0, 0);

    // get offer
    const offer = await avatarSwap.getOffer(testAvatar.address, testOfferData.avoCatoId, 1);

    expect(offer.buyer).to.equal(owner.address);
    expect(offer.price).to.equal("1000000000000000000");
    expect(offer.above).to.equal("0");
    expect(offer.below).to.equal("0");
  });
  it("Should create a second offer on Avo Cato higher than the first", async function () {
    // create offer
    await avatarSwap.createOffer(testAvatar.address, testOfferData.avoCatoId, "2000000000000000000", 1, 0, 1);

    // get offer
    const offer = await avatarSwap.getOffer(testAvatar.address, testOfferData.avoCatoId, 2);

    expect(offer.buyer).to.equal(owner.address);
    expect(offer.price).to.equal("2000000000000000000");
    expect(offer.above).to.equal("0");
    expect(offer.below).to.equal("1");
  });
  it("Should create a third offer on Avo Cato in the middle of previous two offers", async function () {
    // create offer
    await avatarSwap.createOffer(testAvatar.address, testOfferData.avoCatoId, "1500000000000000000", 1, 2, 1);

    // get offer
    const offer = await avatarSwap.getOffer(testAvatar.address, testOfferData.avoCatoId, 3);

    expect(offer.buyer).to.equal(owner.address);
    expect(offer.price).to.equal("1500000000000000000");
    expect(offer.above).to.equal("2");
    expect(offer.below).to.equal("1");
  });
  it("Should fail to create offer with incorrect above", async function () {
    await expect(avatarSwap.createOffer(testAvatar.address, testOfferData.avoCatoId, "10000000000000000", 1, 3, 0)).to.be.revertedWith("OfferHandler: Incorrect position, offer below does not match the below offer of the offer above");
  });
  it("Should fail to create offer with incorrect above", async function () {
    await expect(avatarSwap.createOffer(testAvatar.address, testOfferData.avoCatoId, "1600000000000000000", 1, 2, 1)).to.be.revertedWith("OfferHandler: Incorrect position, offer below does not match the below offer of the offer above");
  });
  it("Should create a fourth offer on Avo Cato which is the lowest offer yet", async function () {
    // create offer
    await avatarSwap.createOffer(testAvatar.address, testOfferData.avoCatoId, "1000000000000000", 1, 1, 0);

    // get offer
    const offer = await avatarSwap.getOffer(testAvatar.address, testOfferData.avoCatoId, 4);

    expect(offer.buyer).to.equal(owner.address);
    expect(offer.price).to.equal("1000000000000000");
    expect(offer.above).to.equal("1");
    expect(offer.below).to.equal("0");
  });

  it("Should create first offer on Mouse au Chocolat", async function () {
    // create offer
    await avatarSwap.createOffer(testAvatar.address, testOfferData.hotDog, "1000000000000000000", 1, 0, 0);

    // get offer
    const offer = await avatarSwap.getOffer(testAvatar.address, testOfferData.hotDog, 5);

    expect(offer.buyer).to.equal(owner.address);
    expect(offer.price).to.equal("1000000000000000000");
    expect(offer.above).to.equal("0");
    expect(offer.below).to.equal("0");
  });
  it("Should create second offer on Mouse au Chocolat", async function () {
    // create offer
    await avatarSwap.createOffer(testAvatar.address, testOfferData.hotDog, "2000000000000000000", 1, 0, 5);

    // get offer
    const offer = await avatarSwap.getOffer(testAvatar.address, testOfferData.hotDog, 6);

    expect(offer.buyer).to.equal(owner.address);
    expect(offer.price).to.equal("2000000000000000000");
    expect(offer.above).to.equal("0");
    expect(offer.below).to.equal("5");
  });
  it("Should create third offer on Mouse in the middle of previous two offers", async function () {
    // create offer
    await avatarSwap.createOffer(testAvatar.address, testOfferData.hotDog, "1500000000000000000", 1, 6, 5);

    // get offer
    const offer = await avatarSwap.getOffer(testAvatar.address, testOfferData.hotDog, 7);

    expect(offer.buyer).to.equal(owner.address);
    expect(offer.price).to.equal("1500000000000000000");
    expect(offer.above).to.equal("6");
    expect(offer.below).to.equal("5");
  });
  it("should fail to create offer on invalid avatartype", async function () {
    await expect(avatarSwap.createOffer(testAvatar.address, 100000, "1000000000000000000", 1, 0, 0)).to.be.revertedWith("AvatarIdentifier: Avatar type does not exist");
  });
});
