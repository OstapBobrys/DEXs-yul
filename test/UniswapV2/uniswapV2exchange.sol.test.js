const { ethers, network } = require('hardhat');
const { expect } = require('chai');

const UniswapV2Router02 = require('@uniswap/v2-periphery/build/IUniswapV2Router02.json');
const UNISWAP_V2_ROUTER = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';

const WETH = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';
const USDC = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
const USDT = '0xdAC17F958D2ee523a2206206994597C13D831ec7';
const WETH_WHALE = '0x57757E3D981446D585Af0D9Ae4d7DF6D64647806';

const buyAmount = 100n * 10n ** 6n;

describe('Uniswap V2 exchange', function () {
  let deployer;
  let user;
  let weth;
  let usdc;
  let usdt;
  let whale;
  let exchange;

  beforeEach(async function () {
    [deployer, user] = await ethers.getSigners();

    const EXCHANGE_FACTORY = await ethers.getContractFactory('UniswapV2ExchangeSOL');
    exchange = await EXCHANGE_FACTORY.deploy();

    weth = await ethers.getContractAt('IERC20', WETH);
    usdc = await ethers.getContractAt('IERC20', USDC);
    usdt = await ethers.getContractAt('IERC20', USDT);

    whale = await ethers.getSigner(WETH_WHALE);

    router = new ethers.Contract(UNISWAP_V2_ROUTER, UniswapV2Router02.abi, deployer);

    await network.provider.request({
      method: 'hardhat_impersonateAccount',
      params: [WETH_WHALE],
    });
  });

  it('#swapTokens', async function () {
    const balanceUsdc = await usdc.balanceOf(whale.address);
    expect(await usdt.balanceOf(whale.address)).to.eq(0);

    const amountIn = await router.getAmountsIn(buyAmount, [USDC, USDT]);

    await usdc.connect(whale).transfer(exchange.target, amountIn[0]);

    await exchange.connect(whale).swap('0x3041CbD36888bECc7bbCBc0045E3B1f144466f5f', USDT, buyAmount);

    expect(await usdc.balanceOf(whale.address)).to.eq(balanceUsdc - amountIn[0]);
    expect(await usdt.balanceOf(whale.address)).to.eq(buyAmount);
  });

  it('#withdrawTokens', async function () {
    expect(await usdc.balanceOf(exchange.target)).to.eq(0);
    expect(await usdc.balanceOf(deployer.address)).to.eq(0);

    await usdc.connect(whale).transfer(exchange.target, buyAmount);
    expect(await usdc.balanceOf(exchange.target)).to.eq(buyAmount);
    expect(await usdc.balanceOf(deployer.address)).to.eq(0);

    await exchange.withdrawTokens(USDC);

    expect(await usdc.balanceOf(exchange.target)).to.eq(0);
    expect(await usdc.balanceOf(deployer.address)).to.eq(buyAmount);
  });

  it('Should revert not owner', async function() {
    await usdc.connect(whale).transfer(exchange.target, buyAmount);
    await expect(exchange.connect(user).withdrawTokens(USDC)).to.be.reverted;
  })
});
