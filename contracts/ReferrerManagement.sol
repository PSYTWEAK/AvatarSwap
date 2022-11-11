// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ReferralRouter.sol";

// when a referrer generates themselves a code, they also generate a new router contract logged in their address
// this router contract is used to identify the referrer as the expected traffic is going to be coming
// from users who can't have data added to their transactions (like a referral code) because they're
// transferring from reddit

contract ReferrerManagement {
    mapping(address => uint256) public referralCode;
    mapping(uint256 => address) public referralRouter;
    mapping(address => address) public referrer;

    function createReferral() external {
        ReferralRouter _referralRouter = new ReferralRouter (address(this));

        uint256 _referralCode = getReferralCode(msg.sender);

        require(referralCode[msg.sender] == 0, "ReferrerManagement: This account already has a referral code");

        referralCode[msg.sender] = _referralCode;
        referralRouter[_referralCode] = address(_referralRouter);
        referrer[address(_referralRouter)] = msg.sender;
    }

    function getReferralCode(address _address) public pure returns (uint256) {
        uint256 number = uint256(keccak256(abi.encodePacked(_address)));
        return number;
    }

    function getReferralRouter(uint256 _referralCode) public view returns (address) {
        require(referralRouter[_referralCode] != address(0), "ReferrerManagement: This referral Router does not exist");
        return referralRouter[_referralCode];
    }

    function getReferrer(address _address) public view returns (address) {
        require(referrer[_address] != address(0), "ReferrerManagement: This address is not a referrer");
        return referrer[_address];
    }

    modifier onlyReferralRouter() {
        require(referrer[msg.sender] != address(0), "ReferrerManagement: This address is not a referrer");
        _;
    }
}
