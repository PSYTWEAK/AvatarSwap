// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ReferalRouter.sol";

// when a referrer generates themselves a code, they also generate a new router contract logged in their address
// this router contract is used to identify the referrer as the expected traffic is going to be coming
// from users who can't have data added to their transactions (like a referral code) because they're
// transferring from reddit

contract ReferrerManagement {
    mapping(address => uint256) public referalCode;
    mapping(uint256 => address) public referalReceiver;
    mapping(address => address) public referrer;

    function createReferal() external {
        uint256 _referalCode = getReferalCode(msg.sender);
        require(referalCode[msg.sender] == 0, "ReferrerManagement: This account already has a referral code");
        referalCode[msg.sender] = _referalCode;

        ReferalRouter _referalRouter = new ReferalRouter (address(this));
        referalRouter[_referalCode] = address(_referalRouter);
        referrer[address(_referalRouter)] = msg.sender;
    }

    function getReferalCode(address _address) public pure returns (uint256) {
        uint256 number = uint256(keccak256(abi.encodePacked(_address)));
        return number;
    }

    function getReferalReceiver(uint256 _referalCode) external view returns (address) {
        return referalReceiver[_referalCode];
    }

    function getReferrer(address _address) external view returns (address) {
        require(referrer[_address] != address(0), "ReferrerManagement: This address is not a referrer");
        return referrer[_address];
    }
}
