// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

// an interface for ReferalReceiver to interact with AvatarSwap
interface IAvatarSwap {
    function acceptBestOfferReferral(address _collectionAddress, uint256 _id, uint256 _value) external;
}
