// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// this contract is a basic ERC1155 contract for testing purposes
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract TestAvatar is ERC1155 {
    constructor() ERC1155("https://test.com/id.json") {
        _mint(msg.sender, 0, 1, "");
    }

    function mint(address to, uint256 id, uint256 value) external {
        _mint(to, id, value, "");
    }
}
