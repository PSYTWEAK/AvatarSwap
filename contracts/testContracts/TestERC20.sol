// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// this contract is a basic ERC20 contract for testing purposes
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor() ERC20("TestToken", "TT") {
        _mint(msg.sender, 1000000000000000000000000);
    }

    function mint(address to, uint256 value) external {
        _mint(to, value);
    }

}
