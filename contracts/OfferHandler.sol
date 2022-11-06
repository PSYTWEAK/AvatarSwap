// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract OfferHandler {
    struct CollectionOffer {
        address maker;
        uint256 price;
        uint256 next;
        uint256 prev;
    }

    struct OfferList {
        uint256 head;
        uint256 tail;
        uint256 length;
    }

    // Mapping the contract address and the token type to a list of offers
    // avatars share the same contract address but have different types
    mapping(address => mapping(string => mapping(uint256 => CollectionOffer))) public offers;
    mapping(address => mapping(string => OfferList)) public offerLists;

    function _addOffer(CollectionOffer memory collectionOffer, address collection, string memory avatarType)
        internal
        correctPosition(collectionOffer, collection, avatarType)
    {
        uint256 newOfferId = offerLists[collection][avatarType].length;

        offers[collection][avatarType][newOfferId] = collectionOffer;

        offers[collection][avatarType][collectionOffer.prev].next = newOfferId;
        offers[collection][avatarType][collectionOffer.next].prev = newOfferId;

        offerLists[collection][avatarType].length++;
    }

    function _removeOffer(uint256 offerId, address collection, string memory avatarType)
        internal
        isMaker(offerId, collection, avatarType)
        offerExists(offerId, collection, avatarType)
    {
        CollectionOffer memory offer = offers[collection][avatarType][offerId];

        offers[collection][avatarType][offer.prev].next = offers[collection][avatarType][offerId].next;
        offers[collection][avatarType][offer.next].prev = offers[collection][avatarType][offerId].prev;

        offerLists[collection][avatarType].length--;
    }

    modifier correctPosition(CollectionOffer memory collectionOffer, address collection, string memory avatarType) {
        require(
            offers[collection][avatarType][collectionOffer.prev].price == 0
                || offers[collection][avatarType][collectionOffer.prev].price < collectionOffer.price,
            "OfferHandler: Offer above is not greater than the new offer"
        );
        require(
            offers[collection][avatarType][collectionOffer.next].price == 0
                || offers[collection][avatarType][collectionOffer.next].price > collectionOffer.price,
            "OfferHandler: Offer below is not less than the new offer"
        );
        _;
    }

    modifier isMaker(uint256 offerId, address collection, string memory avatarType) {
        require(offers[collection][avatarType][offerId].maker == msg.sender, "OfferHandler: Not the maker of the offer");
        _;
    }

    modifier offerExists(uint256 offerId, address collection, string memory avatarType) {
        require(offers[collection][avatarType][offerId].price != 0, "OfferHandler: Offer does not exist");
        _;
    }

    function getBestOffer(address collection, string memory avatarType) public view returns (CollectionOffer memory) {
        return offers[collection][avatarType][getBestOfferId(collection, avatarType)];
    }

    function getBestOfferId(address collection, string memory avatarType) public view returns (uint256) {
        return offerLists[collection][avatarType].head;
    }

    function getOffer(address collection, string memory avatarType, uint256 offerId)
        public
        view
        returns (CollectionOffer memory)
    {
        return offers[collection][avatarType][offerId];
    }
}
