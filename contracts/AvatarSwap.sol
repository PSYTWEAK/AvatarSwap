// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./OfferHandler.sol";
import "./AvatarIdentifier.sol";
import "./WETHPayments.sol";
import "./TransferAvatars.sol";

contract AvatarSwap is OfferHandler, AvatarIdentifier, WETHPayments, TransferAvatars {
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
        _transferWETHFrom(msg.sender, address(this), price);

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

        _transferWETH(msg.sender, refund);

        emit OfferRemoved(
            msg.sender, collectionAddress, avatarType, offers[collectionAddress][avatarType][offerId].price
            );
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data)
        public
        view
        returns (bytes4)
    {
        _acceptBestOffer(msg.sender, _from, _id, _value, false);

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        public
        returns (bytes4)
    {
        revert();
        return this.onERC1155BatchReceived.selector;
    }

    function _acceptBestOffer(address _collectionAddress, address _sender, uint256 _id, uint256 _value, bool _referred)
        internal
        isValidAvatarType(getAvatarType(_collectionAddress, _id))
    {
        string avatarType = getAvatarType(_collectionAddress, _id);

        CollectionOffer memory offer = getBestOffer(_collectionAddress, avatarType);

        uint256 offerId = getBestOfferId(collectionAddress, avatarType);

        _removeOffer(offerId, _collectionAddress, avatarType);

        if (_referred) {
            _payReferalSeller(_sender, offer.price);
        } else {
            _paySeller(_sender, offer.price);
        }

        _payMaker(offer.maker, _collectionAddress, _id, _value);

        emit OfferAccepted(offer.maker, _collectionAddress, avatarType, offer.price);

        return this.onERC1155Received.selector;
    }

    function acceptBestOfferReferral(address collectionAddress, uint256 id, uint256 value) public {
        _acceptBestOffer(collectionAddress, msg.sender, id, value, true);

        emit OfferAccepted(offer.maker, _collectionAddress, avatarType, offer.price);
    }

    modifier isValidAvatarType(string memory avatarType) {
        require(keccak256(abi.encodePacked(avatarType)) != 0x0, "AvatarSwap: Invalid avatar type");
        _;
    }
}
