// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./OfferRouter.sol";


contract OfferRouterFactory {

    function createOfferRouter() internal returns (address) {
        OfferRouter offerRouter = new OfferRouter(address(this));
        return address(offerRouter);
    }
}




