// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "IAvatarSwap.sol";

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
