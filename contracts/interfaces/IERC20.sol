// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);

    function decimals() external view returns (uint);

    function transfer(address to, uint256 value) external returns (bool);
}
