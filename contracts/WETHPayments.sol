// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ReferrerManagement.sol";

contract WETHPayments is ReferrerManagement {
    address immutable WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address immutable feeWallet = 0xe51B242853126C4DaB6a08FddE0CAEa122EB9Dd7;

    function _paySeller(address to, uint256 price) internal {
        _transferWETH(to, price);
    }

    function _payReferalSeller(address referrer, address to, uint256 price) internal {
        uint256 referrerFee = price / 50;
        uint256 newPrice = price - referrerFee;

        _transferWETH(to, referrer);
        _transferWETH(to, newPrice);
    }

    function _transferWETH(address to, uint256 amount) internal transferCompleted(from, to, amount) {
        IERC20(WETH).transfer(to, amount);
    }

    function _transferWETHFrom(address from, address to, uint256 amount) internal transferCompleted(from, to, amount) {
        IERC20(WETH).transferFrom(from, to, amount);
    }

    modifier transferCompleted(address to, uint256 amount) {
        uint256 balanceBefore = IERC20(WETH).balanceOf(to);
        _;
        uint256 balanceAfter = IERC20(WETH).balanceOf(to);
        require(balanceAfter - balanceBefore == amount, "WrappedETH: Transfer failed");
    }
}
