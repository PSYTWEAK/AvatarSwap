// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract OfferHandler {

    event OfferCreated(
        uint256 offerId, address indexed buyer, address indexed collectionAddress, uint256 avatarType, uint256 price, uint256 quantity
    );

    event OfferRemoved(
       uint256 offerId, address indexed buyer, address indexed collectionAddress, uint256 avatarType, uint256 price
    );

    struct CollectionOffer {
        address offerRouter;
        address buyer;
        uint256 price;
        uint256 quantity;
        uint256 above;
        uint256 below;
    }

    struct OfferList {
        uint256 head;
        uint256 tail;
        uint256 length;
    }

    uint256 offerId = 0;

    mapping(address => mapping(uint256 => mapping(uint256 => CollectionOffer))) public offers;
    mapping(address => mapping(uint256 => OfferList)) public offerLists;

    function _addOffer(CollectionOffer memory collectionOffer, address collection, uint256 avatarType)
        internal
    {
        offerId++;

        // if the offer list is empty, set the head and tail to the new offer id
        if (offerLists[collection][avatarType].length == 0) {
            offerLists[collection][avatarType].head = offerId;
            offerLists[collection][avatarType].tail = offerId;
        } else {

            if(collectionOffer.above != 0) {
                // if the collectionOffer.above is not 0 then the offer above is checked to make sure it is higher
                CollectionOffer storage above = offers[collection][avatarType][collectionOffer.above]; 
                require(above.price >= collectionOffer.price, "OfferHandler: Incorrect position, offer above is not above the new offer");     
                require(above.below == collectionOffer.below, "OfferHandler: Incorrect position, offer below does not match the below offer of the offer above");
                above.below = offerId;
            } 
            if(collectionOffer.below != 0) {
                // if the collectionOffer.below is not 0 then the offer below is checked to make sure it is lower
                CollectionOffer storage below = offers[collection][avatarType][collectionOffer.below];
                require(below.price < collectionOffer.price, "OfferHandler: Incorrect position, offer below is not below the new offer"); 
                require(below.above == collectionOffer.above, "OfferHandler: Incorrect position, offer above does not match the above offer of the offer below");
                below.above = offerId;  
            } 
            if(collectionOffer.above == 0) {
                // if the collectionOffer.above is 0 then the offer is the highest offer and the head is updated
                CollectionOffer storage head = offers[collection][avatarType][offerLists[collection][avatarType].head];
                require(head.price < collectionOffer.price, "OfferHandler: Incorrect position, offer is not the head");   
                head.above = offerId;
                // set new head
                offerLists[collection][avatarType].head = offerId;
            }
            if(collectionOffer.below == 0) {
                // if the collectionOffer.below is 0 then the offer is the lowest offer and the tail is updated
                CollectionOffer storage tail = offers[collection][avatarType][offerLists[collection][avatarType].tail];
                require(tail.price > collectionOffer.price, "OfferHandler: Incorrect position, offer is not the tail");   
                tail.below = offerId;
                // set new tail
                offerLists[collection][avatarType].tail = offerId;
            }
        }

        offers[collection][avatarType][offerId] = collectionOffer;
        offerLists[collection][avatarType].length++;

        emit OfferCreated(offerId, msg.sender, collection, avatarType, collectionOffer.price, collectionOffer.quantity);
    }

    function _removeOffer(uint256 offerId, address collection, uint256 avatarType)
        internal   
        offerExists(offerId, collection, avatarType)
    {
        CollectionOffer storage offer = offers[collection][avatarType][offerId];
        // if the offer is the new head, set the head to the below offer
        // if the offer is the new tail, set the tail to the above offer
        // if the offer is not the head or tail, set the above of the below offer to the above offer
        // and set the below of the above offer to the below offer
        if (offerId == offerLists[collection][avatarType].head) {
            offerLists[collection][avatarType].head = offer.below;
            offers[collection][avatarType][offer.below].above = 0;
        } else {
            offers[collection][avatarType][offer.below].above = offer.above;
        }

        if (offerId == offerLists[collection][avatarType].tail) {
            offerLists[collection][avatarType].tail = offer.above;
            offers[collection][avatarType][offer.above].below = 0;
        } else {
            offers[collection][avatarType][offer.above].below = offer.below;
        }  

        delete offers[collection][avatarType][offerId];

        offerLists[collection][avatarType].length--;

        emit OfferRemoved(offerId, msg.sender, collection, avatarType, offer.price);
    }

    function _updateOffer(uint256 offerId, address collection, uint256 avatarType) internal {
        CollectionOffer storage offer = offers[collection][avatarType][offerId];
        if (offer.quantity == 0) {
            _removeOffer(offerId, collection, avatarType);
        } else {
            offer.quantity--;
        }
    }

    modifier isBuyer(uint256 offerId, address collection, uint256 avatarType) {
        require(offers[collection][avatarType][offerId].buyer == msg.sender, "OfferHandler: Not the buyer of the offer");
        _;
    }

    modifier offerExists(uint256 offerId, address collection, uint256 avatarType) {
        require(offers[collection][avatarType][offerId].price != 0, "OfferHandler: Offer does not exist");
        _;
    }

    function getBestOffer(address collection, uint256 avatarType) public view returns (CollectionOffer memory) {
        return offers[collection][avatarType][getBestOfferId(collection, avatarType)];
    }

    function getBestOfferId(address collection, uint256 avatarType) public view returns (uint256) {
        return offerLists[collection][avatarType].head;
    }

    function getBestOfferPrice(address collection, uint256 avatarType) public view returns (uint256) {
        return offers[collection][avatarType][getBestOfferId(collection, avatarType)].price;
    }

    function getOffer(address collection, uint256 avatarType, uint256 offerId)
        public
        view
        returns (CollectionOffer memory)
    {
        return offers[collection][avatarType][offerId];
    }
}
