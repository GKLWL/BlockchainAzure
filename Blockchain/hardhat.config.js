/** @type import('hardhat/config').HardhatUserConfig */
/** module.exports = {*/
/**  solidity: "0.8.27", */

/** };*/

require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.0",
  networks: {
    ganache: {
      url: "http://172.16.0.5:7545",
      accounts: [
        "0x2f8cac306c63a4cdc3eb6baa9e13d915dc7c338ee1b6333aa9dbe70d209798db"
      ],
    },
  },
};

