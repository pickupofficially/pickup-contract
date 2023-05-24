import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import '@openzeppelin/hardhat-upgrades'
import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";

require("@nomiclabs/hardhat-ethers");
require('hardhat-abi-exporter');
require('hardhat-contract-sizer');
const abiDecoder = require('abi-decoder');

dotenv.config();

const gas = "auto";
const gasPrice = "auto";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.10",
      },
    ],
  },
  defaultNetwork: "",
  zksolc: {
    version: "1.3.10",
    compilerSource: "binary",
    settings: {
      libraries:{}, // optional. References to non-inlinable libraries
      isSystem: false, // optional.  Enables Yul instructions available only for zkSync system contracts and libraries
      forceEvmla: false, // optional. Falls back to EVM legacy assembly if there is a bug with Yul
      optimizer: {
        enabled: true, // optional. True by default
        mode: '3' // optional. 3 by default, z to optimize bytecode size
      }
    }
  },
  networks: {
    local: {
      url: "http://127.0.0.1:8545/",
      accounts:
        [],
      gas: gas,
      gasPrice: gasPrice,
    }
  }
};

export default config;
