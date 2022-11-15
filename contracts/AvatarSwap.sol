// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./OfferHandler.sol";
import "./AvatarIdentifier.sol";
import "./WETHPayments.sol";
import "./TransferAvatars.sol";
import "./ToggleTradingOpen.sol";

contract AvatarSwap is OfferHandler, AvatarIdentifier, WETHPayments, TransferAvatars, ToggleTradingOpen {



    constructor(address _weth) WETHPayments(_weth) public {}

    // Function to create a new offer, parameters need to include the offer above and below the new offer
    // The offer above and below are used to determine the position of the new offer in the list
    // revert if the offer above and below are not above and below the new offer
    function createOffer(
        address collectionAddress,
        string memory avatarType,
        uint256 price,
        uint256 offerAbove,
        uint256 offerBelow
    ) public isTradingOpen {
        require(price > 0, "AvatarSwap: Price must be greater than 0");
        _transferWETHFrom(msg.sender, address(this), price);

        _addOffer(
            CollectionOffer({maker: msg.sender, price: price, above: offerAbove, below: offerBelow}),
            collectionAddress,
            avatarType
        );


    }

    function removeOffer(address collectionAddress, string memory avatarType, uint256 offerId) 
        public         
        isMaker(offerId, collectionAddress, avatarType) {

        uint256 refund = getOffer(collectionAddress, avatarType, offerId).price;

        _removeOffer(offerId, collectionAddress, avatarType);

        _transferWETH(msg.sender, refund);
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data)
        public
        isTradingOpen
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

    function acceptBestOfferReferral(address collectionAddress, address sender, uint256 id, uint256 value) public isTradingOpen onlyReferralRouter {
        _acceptBestOffer(collectionAddress, sender, id, value, true);
    }

    function _acceptBestOffer(address _collectionAddress, address _sender, uint256 _id, uint256 _value, bool _referred)
        internal
    {

        string memory avatarType = getAvatarType(_collectionAddress, _id);

        require(keccak256(abi.encodePacked(avatarType)) != keccak256(abi.encodePacked("")), "AvatarSwap: Avatar type not found");

        CollectionOffer memory offer = getBestOffer(_collectionAddress, avatarType);

        uint256 offerId = getBestOfferId(_collectionAddress, avatarType);

        _removeOffer(offerId, _collectionAddress, avatarType);

        if (_referred) {
            _payReferalSeller(_sender, offer.price);
            _payMakerFromReferral(offer.maker, _collectionAddress, _id, _value);
        } else {
            _paySeller(_sender, offer.price);
            _payMaker(offer.maker, _collectionAddress, _id, _value);
        }
    }


}
