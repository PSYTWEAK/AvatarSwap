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

    event AvatarAdded(address collection, string avatarName, uint256 avatarTypeId);

    event AvatarRemoved(address collection, uint256 avatarTypeId);

    // collection address => index => collection type 
    mapping(address => mapping(uint256 => uint256[])) internal collectionIdRanges;
    // collection address => index => internal avatar type identifier
    mapping(address => mapping(uint256 => uint256)) internal avatarTypeId;
    // collection address => avatar type
    mapping(address => uint256) internal numAvatarTypes;


    uint256 internalIdCounter = 0;

    function addAvatarTypes(address collection, uint256[] memory indexes, uint256[][] memory ranges, string[] memory avatarName) public onlyOwner {
        require(indexes.length == ranges.length, "AvatarIdentifier: Indexes and ranges must be the same length");

        for (uint256 i = 0; i < indexes.length; i++) {
            if (indexes[i] > 0 && ranges[i][0] < collectionIdRanges[collection][indexes[i] - 1][1]) {

            revert("AvatarIdentifier: Indexes must be in ascending order");
            }
            require(collectionIdRanges[collection][indexes[i]].length == 0, "AvatarIdentifier: Index already exists");
            require(ranges[i].length == 2, "AvatarIdentifier: Range must be 2 numbers");

            collectionIdRanges[collection][indexes[i]] = ranges[i];

            internalIdCounter++;
            avatarTypeId[collection][indexes[i]] = internalIdCounter;

            emit AvatarAdded(collection, avatarName[i], internalIdCounter);
        }
        numAvatarTypes[collection] += indexes.length;
    }

    function removeAvatarTypes(address collection, uint256[] memory indexes) public onlyOwner {
        for (uint256 i = 0; i < indexes.length; i++) {
            delete collectionIdRanges[collection][indexes[i]];
            delete avatarTypeId[collection][indexes[i]];

            emit AvatarRemoved(collection, avatarTypeId[collection][indexes[i]]);
        }
        numAvatarTypes[collection] -= indexes.length;
    }

    function getAvatarType(address collection, uint256 tokenId) public view returns (uint256) {
        // binary search through the ranges and find the range that the tokenId is in and return internalId
        uint256 min = 0;
        uint256 max = numAvatarTypes[collection] - 1;
        uint256 mid;
        while (min <= max) {
            mid = (min + max) / 2;
            if (collectionIdRanges[collection][mid][0] <= tokenId && collectionIdRanges[collection][mid][1] >= tokenId) {
                return avatarTypeId[collection][mid];
            } else if (collectionIdRanges[collection][mid][0] > tokenId) {
                max = mid - 1;
            } else {
                min = mid + 1;
            }
        }
        revert("AvatarIdentifier: TokenId not found");
    }

}
