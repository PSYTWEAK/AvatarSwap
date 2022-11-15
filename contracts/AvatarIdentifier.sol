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
    // collection address => Id ranges within collection
    mapping(address => uint256[][]) public collectionRanges;
    // collection address => range[0] or minimum id in the range => collection type 
    mapping(address => mapping(uint256 => string)) public collectionTypes;

    function addCollectionTypes(address collection, uint256[][] memory ranges, string[] memory types) public onlyOwner {
        for (uint256 i = 0; i < ranges.length; i++) {
            collectionTypes[collection][ranges[i][0]] = types[i];
        }
    }

    function addCollectionRanges(address collection, uint256[][] memory ranges) public onlyOwner {
        collectionRanges[collection] = ranges;
    }

    function removeCollectionTypes(address collection, uint256[][] memory ranges) public onlyOwner {
        for (uint256 i = 0; i < ranges.length; i++) {
            delete collectionTypes[collection][ranges[i][0]];
        }
    }

    function removeCollectionRanges(address collection, uint256[][] memory ranges) public onlyOwner {
        delete collectionRanges[collection];
    }

    function getAvatarType(address collection, uint256 tokenId) public view returns (string memory) {
        // binary search through the ranges and find the range that the tokenId is in
        uint256[][] memory ranges = collectionRanges[collection];
        uint256 min = 0;
        uint256 max = ranges.length - 1;
        while (min <= max) {
            uint256 mid = (min + max) / 2;
            if (ranges[mid][0] <= tokenId && ranges[mid][1] >= tokenId) {
                return collectionTypes[collection][ranges[mid][0]];
            } else if (ranges[mid][0] > tokenId) {
                max = mid - 1;
            } else {
                min = mid + 1;
            }
        }
        return "";
    }

}
