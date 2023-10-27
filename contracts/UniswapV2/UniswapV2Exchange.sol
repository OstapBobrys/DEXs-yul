// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '../interfaces/IERC20.sol';

contract UniswapV2ExchangeSOL {
    address public immutable owner;

    error NotOwner();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function swap(address _pair, address _tokenToBuy, uint256 _buyAmount) external {
        IUniswapV2Pair pair = IUniswapV2Pair(_pair);
        address token0 = pair.token0();
        address token1 = pair.token0();

        address tokenToSell = token0 == _tokenToBuy ? token1 : token0;
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();

        uint256 numerator = reserve0 * _buyAmount;
        numerator = numerator * 1000;

        uint256 denominator = reserve1 - _buyAmount;
        denominator = denominator * 997;

        uint256 amountIn = numerator / denominator + 1;

        IERC20(tokenToSell).transfer(_pair, amountIn);

        (uint256 amount0Out, uint256 amount1Out) = token0 == _tokenToBuy
            ? (_buyAmount, uint256(0))
            : (uint256(0), _buyAmount);

        pair.swap(amount0Out, amount1Out, msg.sender, '');
    }

    function withdrawTokens(IERC20 _token) external onlyOwner {
        _token.transfer(msg.sender, _token.balanceOf(address(this)));
    }
}
