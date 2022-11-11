// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Reddit avatars typically share a contract address with all the avatars made by that artist
// Example collection A has avatar types Mouse, Cat, Dog. Those types are in a range of Ids
// type Mouse is at Id range 0-1000, type Cat is at Id range 1001-2000, type Dog is at Id range 2001-3000
// AvatarIdentifer takes the contract address and Id and finds the token type
// This is used to find the correct offer list for the avatar being recieved

contract AvatarIdentifier is Ownable {
    mapping(address => uint256[]) public collectionRanges;
    mapping(address => mapping(uint256 => string)) public collectionTypes;

    function addCollection(address collection, uint256[] memory ranges, string[] memory types) public onlyOwner {
        require(ranges.length == types.length, "AvatarIdentifier: Ranges and types must be the same length");
        collectionRanges[collection] = ranges;
        for (uint256 i = 0; i < ranges.length; i++) {
            collectionTypes[collection][ranges[i]] = types[i];
        }
    }

    function removeCollection(address collection, uint256[] memory ranges) public onlyOwner {
        for (uint256 i = 0; i < ranges.length; i++) {
            delete collectionTypes[collection][ranges[i]];
        }
        delete collectionRanges[collection];
    }

    function getAvatarType(address collection, uint256 tokenId) public view returns (string memory) {
        uint256[] memory ranges = collectionRanges[collection];
        for (uint256 i = 0; i < ranges.length; i++) {
            if (tokenId <= ranges[i]) {
                return collectionTypes[collection][ranges[i]];
            }
        }
        return "";
    }

    function isValidAvatar(address collection, uint256 tokenId) public view returns (bool) {
        uint256[] memory ranges = collectionRanges[collection];
        for (uint256 i = 0; i < ranges.length; i++) {
            if (tokenId <= ranges[i]) {
                return true;
            }
        }
        return false;
    }

    modifier isValidAvatarType(address collection, uint256 tokenId) {
        require(isValidAvatar(collection, tokenId), "AvatarIdentifier: Invalid avatar");
        _;
    }
}
