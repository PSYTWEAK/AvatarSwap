// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Payments {
    address immutable WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;

    function _transfer(address to, uint256 amount) internal transferCompleted(from, to, amount) {
        IERC20(WETH).transfer(to, amount);
    }

    function _transferFrom(address from, address to, uint256 amount) internal transferCompleted(from, to, amount) {
        IERC20(WETH).transferFrom(from, to, amount);
    }

    modifier transferCompleted(address to, uint256 amount) {
        uint256 balanceBefore = IERC20(WETH).balanceOf(to);
        _;
        uint256 balanceAfter = IERC20(WETH).balanceOf(to);
        require(balanceAfter - balanceBefore == amount, "WrappedETH: Transfer failed");
    }
}
