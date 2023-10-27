require('./compiler/YulCompiler');
require('@nomicfoundation/hardhat-toolbox');
require('@nomicfoundation/hardhat-ethers');
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: '0.8.22',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          viaIR: true,
        },
      },
    ],
  },
  networks: {
    hardhat: {
      forking: {
        url: `https://mainnet.infura.io/v3/${process.env.INFURA_KEY}`,
      },
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts: [process.env.PRIVATE_KEY],
    },
    goerli: {
      url: 'https://goerli.gateway.tenderly.co',
      accounts: [process.env.PRIVATE_KEY],
    },
    sepolia: {
      url: 'https://sepolia.gateway.tenderly.co',
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  gasReporter: {
    enabled: true,
  },

  // ABI for YUL contracts
  yulArtifacts: {
    UniswapV2Exchange: {
      abi: [
        {
          inputs: [],
          stateMutability: 'nonpayable',
          type: 'constructor',
        },
        {
          inputs: [],
          name: 'owner',
          outputs: [
            {
              internalType: 'address',
              name: '',
              type: 'address',
            },
          ],
          stateMutability: 'view',
          type: 'function',
        },
        {
          inputs: [
            {
              internalType: 'address',
              name: '_pair',
              type: 'address',
            },
            {
              internalType: 'address',
              name: '_tokenToBuy',
              type: 'address',
            },
            {
              internalType: 'uint256',
              name: '_buyAmount',
              type: 'uint256',
            },
          ],
          name: 'swap',
          outputs: [],
          stateMutability: 'nonpayable',
          type: 'function',
        },
        {
          inputs: [
            {
              internalType: 'contract IERC20',
              name: '_token',
              type: 'address',
            },
          ],
          name: 'withdrawTokens',
          outputs: [],
          stateMutability: 'nonpayable',
          type: 'function',
        },
      ],
    },
  },
};
