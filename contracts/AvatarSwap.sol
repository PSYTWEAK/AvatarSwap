// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./OfferHandler.sol";
import "./AvatarIdentifier.sol";
import "./WETHPayments.sol";
import "./TransferAvatars.sol";
import "./ToggleTradingOpen.sol";
import "./OfferRouterFactory.sol";

contract AvatarSwap is OfferHandler, OfferRouterFactory, AvatarIdentifier, WETHPayments, TransferAvatars, ToggleTradingOpen {



    constructor(address _weth) WETHPayments(_weth) public {}

    // Function to create a new offer, parameters need to include the offer above and below the new offer
    // The offer above and below are used to determine the position of the new offer in the list
    // revert if the offer above and below are not above and below the new offer
    function createOffer(
        address collectionAddress,
        uint256 avatarType,
        uint256 price,
        uint256 offerAbove,
        uint256 offerBelow
    ) public isTradingOpen {
        require(price > 0, "AvatarSwap: Price must be greater than 0");
        _transferWETHFrom(msg.sender, address(this), price);

        address _offerRouter = createOfferRouter();

        _addOffer(
            CollectionOffer({offerRouter: _offerRouter, maker: msg.sender, price: price, above: offerAbove, below: offerBelow}),
            collectionAddress,
            avatarType
        );


    }

    function removeOffer(address collectionAddress, uint256 avatarType, uint256 offerId) 
        public         
        isMaker(offerId, collectionAddress, avatarType) {

        uint256 refund = getOffer(collectionAddress, avatarType, offerId).price;

        _removeOffer(offerId, collectionAddress, avatarType);

        _transferWETH(msg.sender, refund);
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data)
        public
        
        returns (bytes4)
        
    {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        public
        returns (bytes4)
    {
        revert();
        return this.onERC1155BatchReceived.selector;
    }

    function acceptBestOffer(address collectionAddress, address _offerRouter, address sender, uint256 id, uint256 value) public isTradingOpen {
        _acceptBestOffer(collectionAddress, _offerRouter, sender, id, value);
    }

    function _acceptBestOffer(address _collectionAddress, address _offerRouter, address _sender, uint256 _id, uint256 _value)
        internal
    {

        uint256 avatarType = getAvatarType(_collectionAddress, _id);

        require(avatarType != 0, "AvatarSwap: Avatar type not found");

        CollectionOffer memory offer = getBestOffer(_collectionAddress, avatarType);

        require(offer.offerRouter == _offerRouter, "AvatarSwap: Incorrect offer router");

        uint256 offerId = getBestOfferId(_collectionAddress, avatarType);

        _removeOffer(offerId, _collectionAddress, avatarType);


        _paySeller(_sender, offer.price);
        _payMaker(offer.maker, _collectionAddress, _id, _value);
        
    }


}
