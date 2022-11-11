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

describe("Create Referral", function () {
  // @ts-ignore
  let avatarSwap: any, owner: any, addr1: any, addr2: any, testAvatar: any, testWETH: any;

  it("loads fixture", async function () {
    let [_owner, _addr1, _addr2] = await ethers.getSigners();
    owner = _owner;
    addr1 = _addr1;
    addr2 = _addr2;

    // @ts-ignore
    const AvatarSwap = await ethers.getContractFactory("AvatarSwap");
    avatarSwap = await AvatarSwap.deploy("0xe51B242853126C4DaB6a08FddE0CAEa122EB9Dd7"); // dummy address
    await avatarSwap.deployed();
  });
  it("Should create referral", async function () {
    // @ts-ignore
    await avatarSwap.connect(addr1).createReferral();

    // @ts-ignore
    const referralCode = await avatarSwap.getReferralCode(addr1.address);
    const referralRouter = await avatarSwap.getReferralRouter(referralCode);

    expect(referralRouter).to.not.equal(ethers.constants.AddressZero);
  });
  it("Should fail to create referral again with addr1", async function () {
    // @ts-ignore
    await expect(avatarSwap.connect(addr1).createReferral()).to.be.revertedWith("ReferrerManagement: This account already has a referral code");
  });
});
