// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./OfferHandler.sol";
import "./AvatarIdentifier.sol";
import "./WrappedETH.sol";

contract AvatarSwap is OfferHandler, AvatarIdentifier, Payments {
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
        address collectionAddress,
        string memory avatarType,
        uint256 price,
        uint256 offerAbove,
        uint256 offerBelow
    ) public {
        _transferFrom(msg.sender, address(this), price);

        _addOffer(
            CollectionOffer({maker: msg.sender, price: price, next: offerBelow, prev: offerAbove}),
            collectionAddress,
            avatarType
        );

        emit OfferCreated(msg.sender, collectionAddress, avatarType, price);
    }

    function removeOffer(address collectionAddress, string memory avatarType, uint256 offerId) public {
        _removeOffer(offerId, collectionAddress, avatarType);

        uint256 refund = getOffer(collectionAddress, avatarType, offerId).price;

        _transfer(msg.sender, refund);

        emit OfferRemoved(
            msg.sender, collectionAddress, avatarType, offers[collectionAddress][avatarType][offerId].price
            );
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data)
        public
        view
        paySender(_from, msg.sender, getAvatarType(collectionAddress, _id))
        removeOffer(msg.sender, getAvatarType(collectionAddress, _id))
        returns (bytes4)
    {
        emit OfferAccepted(offer.maker, collectionAddress, avatarType, offer.price);

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        public
        returns (bytes4)
    {
        revert();
        return this.onERC1155BatchReceived.selector;
    }

    modifier paySender(address to, address collectionAddress, string avatarType) {
        CollectionOffer memory offer = getBestOffer(collectionAddress, avatarType);
        _transfer(to, offer.price);
        _;
    }

    modifier removeOffer(address collectionAddress, string avatarType) {
        require(keccak256(abi.encodePacked(avatarType)) != 0x0, "AvatarSwap: Invalid avatar type");
        uint256 offerId = getBestOffer(collectionAddress, avatarType);
        _removeOffer(offerId, collectionAddress, avatarType);
        _;
    }
}
