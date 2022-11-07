// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ReferalReceiver.sol";

contract ReferrerManagement {
    mapping(address => uint256) public referalCode;
    mapping(uint256 => address) public referalReceiver;
    mapping(address => address) public referrer;

    function createReferal() external {
        uint256 referalCode = getReferalCode(msg.sender);
        require(referalCode[msg.sender] == 0, "ReferrerManagement: This account already has a referral code");
        referalCode[msg.sender] = referalCode;

        ReferalReceiver referalReceiver = new ReferalReceiver(address(this));
        referalReceiver[referalCode] = address(referalReceiver);
        referrer[address(referalReceiver)] = msg.sender;
    }

    function getReferalCode(address _address) public pure returns (uint256) {
        uint256 number = uint256(keccak256(abi.encodePacked(_address)));
        return number;
    }

    function getReferalReceiver(uint256 _referalCode) external view returns (address) {
        return referalReceiver[_referalCode];
    }

    function getReferrer(address _address) external view returns (address) {
        return referrer[_address];
    }
}
