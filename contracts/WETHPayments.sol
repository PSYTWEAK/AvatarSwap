// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WETHPayments {
    address public WETH;
    address immutable feeWallet = 0xe51B242853126C4DaB6a08FddE0CAEa122EB9Dd7;

    constructor(address _weth) {
        WETH = _weth;
    }

    function _paySeller(address to, uint256 price) internal {
        uint256 basicFee = price / 25;
        uint256 newPrice = price - basicFee;
        _transferWETH(feeWallet, basicFee);
        _transferWETH(to, newPrice);
    }

    function _transferWETH(address to, uint256 amount) internal transferWETHCompleted(to, amount) {
        IERC20(WETH).transfer(to, amount);
    }

    function _transferWETHFromBuyer(address from, address to, uint256 amount) internal transferWETHCompleted(to, amount) {
        IERC20(WETH).transferFrom(from, to, amount);
    }

    modifier transferWETHCompleted(address to, uint256 amount) {
        uint256 balanceBefore = IERC20(WETH).balanceOf(to);
        _;
        uint256 balanceAfter = IERC20(WETH).balanceOf(to);
        require(balanceAfter - balanceBefore == amount, "WrappedETH: Transfer failed");
    }
}
