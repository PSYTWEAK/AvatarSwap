// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract TransferAvatars {
    function _payMaker(address to, address collectionAddress, uint256 id, uint256 value) internal {
        _transferAvatar(msg.sender, to, collectionAddress, id, value);
    }

    function _transferAvatar(address from, address to, address collection, uint256 id, uint256 value)
        internal
        transferCompleted(to, id)
    {
        IERC1155(collection).safeTransferFrom(from, to, id, value, "");
    }

    modifier transferCompleted(address to, uint256 id) {
        uint256 balanceBefore = IERC1155(WETH).balanceOf(to, id);
        _;
        uint256 balanceAfter = IERC1155(WETH).balanceOf(to, id);
        require(balanceAfter - balanceBefore == amount, "TransferAvatars: Transfer failed");
    }
}
