import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { testCollectionData } from "./testCollectionData";
import { fixture } from "./Fixture";

// this test suite is for the AvatarSwap contract

describe("Create Offer", async function () {
  const { avatarSwap, owner, addr1, addr2, erc1155 } = await loadFixture(fixture);
  it("Should create an offer on Avo Cato", async function () {
    // create offer
    await avatarSwap.createOffer(erc1155.address, "Avo Cato", "1000000000000000000",0, 0)

    // get offer
    const offer = await avatarSwap.getOffer(erc1155.address, "Avo Cato", 0);
    console.log("Offer:", offer);
    expect(offer).to.have.property("maker", owner);
    expect(offer).to.have.property("price", "1000000000000000000");
    expect(offer).to.have.property("next", 0);
    expect(offer).to.have.property("prev", 0);
  })
  it("Should create a second offer on Avo Cato", async function () {
    // create offer
    await avatarSwap.createOffer(erc1155.address, "Avo Cato", "2000000000000000000",0, 0)

    // get offer
    const offer = await avatarSwap.getOffer(erc1155.address, "Avo Cato", 1);
    console.log("Offer:", offer);
    expect(offer).to.have.property("maker", owner);
    expect(offer).to.have.property("price", "2000000000000000000");
    expect(offer).to.have.property("next", 0);
    expect(offer).to.have.property("prev", 0);
  })
  it("Should create a third offer on Avo Cato", async function () {
    // create offer
    await avatarSwap.createOffer(erc1155.address, "Avo Cato", "3000000000000000000",0, 0)

    // get offer
    const offer = await avatarSwap.getOffer(erc1155.address, "Avo Cato", 2);
    console.log("Offer:", offer);
    expect(offer).to.have.property("maker", owner);
    expect(offer).to.have.property("price", "3000000000000000000");
    expect(offer).to.have.property("next", 0);
    expect(offer).to.have.property("prev", 0);
  })
  it("Should create a fourth offer but on Mouse au Chocolat", async function () {
    // create offer
    await avatarSwap.createOffer(erc1155.address, "Mouse au Chocolat", "4000000000000000000",0, 0)

    // get offer
    const offer = await avatarSwap.getOffer(erc1155.address, "Mouse au Chocolat", 0);
    console.log("Offer:", offer);
    expect(offer).to.have.property("maker", owner);
    expect(offer).to.have.property("price", "4000000000000000000");
    expect(offer).to.have.property("next", 0);
    expect(offer).to.have.property("prev", 0);
  })
});
