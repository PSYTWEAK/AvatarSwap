// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "IAvatarSwap.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract ReferalRouter {
    IAvatarSwap avatarSwap;

    constructor(address _avatarSwap) {
        avatarSwap = IAvatarSwap(_avatarSwap);
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data)
        public
        view
        returns (bytes4)
    {
        IERC1155(msg.sender).approve(address(avatarSwap), _id);

        avatarSwap.acceptBestOfferReferral(msg.sender, _id, _value);

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
