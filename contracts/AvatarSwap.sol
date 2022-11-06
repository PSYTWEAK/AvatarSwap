// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./OfferHandler.sol";
import "./AvatarIdentifier.sol";

contract AvatarSwap is OfferHandler, AvatarIdentifier {
    // Event emitted when a new offer is created
    event OfferCreated(
        address indexed maker, address indexed contractAddress, string indexed avatarType, uint256 price
    );

    event OfferRemoved(
        address indexed maker, address indexed contractAddress, string indexed avatarType, uint256 price
    );
    event OfferAccepted(
        address indexed maker, address indexed contractAddress, string indexed avatarType, uint256 price
    );

    // Function to create a new offer, parameters need to include the offer above and below the new offer
    // The offer above and below are used to determine the position of the new offer in the list
    // revert if the offer above and below are not above and below the new offer
    function createOffer(
        address contractAddress,
        string memory avatarType,
        uint256 price,
        uint256 offerAbove,
        uint256 offerBelow
    ) public {
        // Create a new offer
        _addOffer(
            CollectionOffer({maker: msg.sender, price: price, next: offerBelow, prev: offerAbove}),
            contractAddress,
            avatarType
        );

        emit OfferCreated(msg.sender, contractAddress, avatarType, price);
    }

    function removeOffer(address contractAddress, string memory avatarType, uint256 offerId) public {
        // Remove the offer from the list
        _removeOffer(offerId, contractAddress, avatarType);

        emit OfferRemoved(msg.sender, contractAddress, avatarType, offers[contractAddress][avatarType][offerId].price);
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data)
        public
        view
        returns (bytes4)
    {
        address collection = msg.sender;
        string memory avatarType = getCollectionType(collection, _id);
        require(keccak256(abi.encodePacked(avatarType)) != 0x0, "AvatarSwap: Invalid avatar type");

        CollectionOffer memory offer = getOffer(collection, avatarType);

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        public
        returns (bytes4)
    {
        revert();
        return this.onERC1155BatchReceived.selector;
    }
}
