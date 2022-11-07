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

    uint256 offerId = 0;

    // Mapping the contract address and the token type to a list of offers
    // avatars share the same contract address but have different types
    mapping(address => mapping(string => mapping(uint256 => CollectionOffer))) public offers;
    mapping(address => mapping(string => OfferList)) public offerLists;

    function _addOffer(CollectionOffer memory collectionOffer, address collection, string memory avatarType)
        internal
        correctPosition(collectionOffer, collection, avatarType)
    {
        uint256 newOfferId = offerId;
        // if the offer list is empty, set the head and tail to the new offer id
        if (offerLists[collection][avatarType].length == 0) {
            offerLists[collection][avatarType].head = newOfferId;
            offerLists[collection][avatarType].tail = newOfferId;
        } else {
            // if the offer list is not empty, set the next of the offer below to the new offer id
            // set the prev of the offer above to the new offer id
            // if the offer above is 0, set the head to the new offer id
            // if the offer below is 0, set the tail to the new offer id
            offers[collection][avatarType][collectionOffer.prev].next = newOfferId;
            offers[collection][avatarType][collectionOffer.next].prev = newOfferId;
            if (collectionOffer.prev == 0) {
                offerLists[collection][avatarType].head = newOfferId;
            }
            if (collectionOffer.next == 0) {
                offerLists[collection][avatarType].tail = newOfferId;
            }
        }
        offerLists[collection][avatarType].length++;
        offerId++;
    }

    function _removeOffer(uint256 offerId, address collection, string memory avatarType)
        internal
        isMaker(offerId, collection, avatarType)
        offerExists(offerId, collection, avatarType)
    {
        CollectionOffer storage offer = offers[collection][avatarType][offerId];
        // if the offer is the head, set the head to the next offer
        // if the offer is the tail, set the tail to the prev offer
        // if the offer is not the head or tail, set the next of the prev offer to the next offer
        // and set the prev of the next offer to the prev offer
        if (offerId == offerLists[collection][avatarType].head) {
            offerLists[collection][avatarType].head = offer.next;
        } else if (offerId == offerLists[collection][avatarType].tail) {
            offerLists[collection][avatarType].tail = offer.prev;
        } else {
            offers[collection][avatarType][offer.prev].next = offer.next;
            offers[collection][avatarType][offer.next].prev = offer.prev;
        }

        offer.price = 0;
        offer.maker = address(0);

        offerLists[collection][avatarType].length--;
    }

    modifier correctPosition(CollectionOffer memory collectionOffer, address collection, string memory avatarType) {
        if (offerLists[collection][avatarType].length > 0) {
            CollectionOffer storage next = offers[collection][avatarType][collectionOffer.next];
            CollectionOffer storage prev = offers[collection][avatarType][collectionOffer.prev];
            require(next.price > collectionOffer.price, "OfferHandler: Offer below is not less than the new offer");
            require(prev.price < collectionOffer.price, "OfferHandler: Offer above is not greater than the new offer");
        }

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
