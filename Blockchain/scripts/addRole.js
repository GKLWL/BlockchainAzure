const {Web3} = require("web3");

const RPC_URL = "http://172.16.0.5:7545";
const web3 = new Web3(RPC_URL);

const CONTRACT_ADDRESS = "0xdbAE263F802f763b410D249ef0fC7A0c99023902";
const ABI = require("../artifacts/contracts/blockchain.sol/Blockchain.json");
const PRIVATE_KEY = "0x2f8cac306c63a4cdc3eb6baa9e13d915dc7c338ee1b6333aa9dbe70d209798db";

const contract = new web3.eth.Contract(ABI.abi, CONTRACT_ADDRESS);

async function addRole(accountToGrant, roleValue) {
    try {
        
        const account = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY);
        web3.eth.accounts.wallet.add(account);
        web3.eth.defaultAccount = account.address;

        const txData = contract.methods.addRole(accountToGrant, roleValue).encodeABI();

        const tx = {
            from: account.address,
            to: CONTRACT_ADDRESS,
            gas: 2000000,
            data: txData,
        };

        const receipt = await web3.eth.sendTransaction(tx);

        console.log("Role assigned successfully:");
        console.log(`Address: ${accountToGrant}`);
        console.log(`Role: ${roleValue}`);
        console.log(`Transaction Hash: ${receipt.transactionHash}`);
    } catch (error) {
        console.error("Error assigning role:", error.message);
    }
}

(async () => {
    const ACCOUNT_TO_GRANT = "0x02dEC8A982dc2cfF1139cF74B88Ea3e8375CCbF1"; // Address to which the role should be assigned
    const ROLE_VALUE = 1; // 1 corresponds to Role.BLOCK_CREATOR in your smart contract

    await addRole(ACCOUNT_TO_GRANT, ROLE_VALUE);
})();
