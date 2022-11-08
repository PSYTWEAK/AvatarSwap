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

describe("Create Offer", function () {
  // @ts-ignore
  let avatarSwap: any, owner: any, addr1: any, addr2: any, testAvatar: any, testWETH: any;

  it("loads fixture", async function () {
    let [_owner, _addr1, _addr2] = await ethers.getSigners();
    owner = _owner;
    addr1 = _addr1;
    addr2 = _addr2;
    // @ts-ignore
    const AvatarSwap = await ethers.getContractFactory("AvatarSwap");
    avatarSwap = await AvatarSwap.deploy();
    await avatarSwap.deployed();

    console.log("Deployed AvatarSwap contract to:", avatarSwap.address);

    // Deploy TestToken contract
    const TestWETH = await ethers.getContractFactory("TestERC20");
    testWETH = await TestWETH.deploy();
    await testWETH.deployed();

    console.log("Deployed TestWETH contract to:", testWETH.address);

    // mint tokens to addr1
    await testWETH.mint(addr1.address, "1000000000000000000000");
    // mint tokens to addr2
    await testWETH.mint(addr2.address, "1000000000000000000000");

    console.log("Minted 1000 tokens to addr1 and addr2");

    // Approve AvatarSwap contract to spend tokens
    await testWETH.connect(addr1).approve(avatarSwap.address, "1000000000000000000000");
    await testWETH.connect(addr2).approve(avatarSwap.address, "1000000000000000000000");
    await testWETH.connect(owner).approve(avatarSwap.address, "1000000000000000000000");

    console.log("Approved AvatarSwap contract to spend tokens");

    // Deploy ERC721 contract
    const TestAvatar = await ethers.getContractFactory("TestAvatar");
    // @ts-ignore
    testAvatar = await TestAvatar.deploy();
    await testAvatar.deployed();

    console.log("Deployed ERC1155 contract to:", testAvatar.address);

    // Mint ERC1155 tokens
    // @ts-ignore
    await testAvatar.mint(owner.address, 0, 40);

    console.log("Minted ERC1155 tokens to:", owner.address);

    // add collections
    console.log(testAvatar.address);

    await avatarSwap.addCollection(
      testAvatar.address,
      // @ts-ignore
      testCollectionData[0].ranges,
      // @ts-ignore
      testCollectionData[0].avatarTypes
    );

    console.log("Collections added to AvatarSwap");
  });

  it("Should create an offer on Avo Cato", async function () {
    // create offer
    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "1000000000000000000", 0, 0);

    // get offer
    const offer = await avatarSwap.getOffer(testAvatar.address, "Avo Cato", 1);

    expect(offer.maker).to.equal(owner.address);
    expect(offer.price).to.equal("1000000000000000000");
    expect(offer.next).to.equal("0");
    expect(offer.prev).to.equal("0");
  });
  it("Should create a second offer on Avo Cato", async function () {
    // create offer
    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "2000000000000000000", 0, 1);

    // get offer
    const offer = await avatarSwap.getOffer(testAvatar.address, "Avo Cato", 2);

    expect(offer.maker).to.equal(owner.address);
    expect(offer.price).to.equal("2000000000000000000");
    expect(offer.next).to.equal("0");
    expect(offer.prev).to.equal("1");
  }); /*
  it("Should create a third offer on Avo Cato", async function () {
    // create offer
    await avatarSwap.createOffer(testAvatar.address, "Avo Cato", "3000000000000000000", 0, 0);

    // get offer
    const offer = await avatarSwap.getOffer(testAvatar.address, "Avo Cato", 2);
    console.log("Offer:", offer);
    expect(offer).to.have.property("maker", owner);
    expect(offer).to.have.property("price", "3000000000000000000");
    expect(offer).to.have.property("next", 0);
    expect(offer).to.have.property("prev", 0);
  });
  it("Should create a fourth offer but on Mouse au Chocolat", async function () {
    // create offer
    await avatarSwap.createOffer(testAvatar.address, "Mouse au Chocolat", "4000000000000000000", 0, 0);

    // get offer
    const offer = await avatarSwap.getOffer(testAvatar.address, "Mouse au Chocolat", 0);
    console.log("Offer:", offer);
    expect(offer).to.have.property("maker", owner);
    expect(offer).to.have.property("price", "4000000000000000000");
    expect(offer).to.have.property("next", 0);
    expect(offer).to.have.property("prev", 0);
  }); */
});
