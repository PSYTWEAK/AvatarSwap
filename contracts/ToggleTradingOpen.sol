// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

// Reddit avatars typically share a contract address with all the avatars made by that artist
// Example collection A has avatar types Mouse, Cat, Dog. Those types are in a range of Ids
// type Mouse is at Id range 0-1000, type Cat is at Id range 1001-2000, type Dog is at Id range 2001-3000
// AvatarIdentifer takes the contract address and Id and finds the token type
// This is used to find the correct offer list for the avatar being recieved

contract ToggleTradingOpen is Ownable {
    bool public tradingOpen = true;

    function toggleTradingOpen() external onlyOwner {
        tradingOpen = !tradingOpen;
    }

    modifier isTradingOpen() {
        require(tradingOpen, "AvatarSwap: Trading is not open");
        _;
    }
}