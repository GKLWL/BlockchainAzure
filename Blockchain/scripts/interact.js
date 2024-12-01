require("dotenv").config();
const { ethers, JsonRpcProvider} = require("ethers");

async function main(timestamp, caseID, description) {
  const RPC_URL = process.env.RPC_URL;
  const PRIVATE_KEY = process.env.PRIVATE_KEY;
  const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;
  const SCRIPTPATH = process.env.SCRIPTPATH;

  // Load the contract ABI
  const contractABI = require(`${SCRIPTPATH}/Blockchain.json`);

  // Connect to provider and wallet
  const provider = new JsonRpcProvider(RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

  // Connect to the contract
  const contract = new ethers.Contract(CONTRACT_ADDRESS, contractABI.abi, wallet);

  //try {
    // Fetch the chain length
    const chainLength = await contract.getChainLength();
    console.log(`Current chain length: ${chainLength.toString()}`);
    const lastBlockIndex = Number(chainLength) - 1;
    const lastBlock = await contract.getBlock(lastBlockIndex);
    previousHash = lastBlock.hash;
    console.log(`Previous hash retrieved: ${previousHash}`);

    console.log(`Adding block with caseID: ${caseID}, description: ${description}...`);

    // Add a new block
    const tx = await contract.addBlock(previousHash, Number(timestamp), caseID, description, {
  gasLimit: 500000,
});
    console.log("Transaction sent. Waiting for confirmation...");
    const receipt = await tx.wait();

    console.log(`Block added successfully in transaction: ${receipt.transactionHash}`);
  //} catch (error) {
    //console.error("Error interacting with the contract:", error.message);
  //}
}

// Extract command-line arguments
const args = process.argv.slice(2);
const [caseID, timestamp, description] = args;

// Execute the script
main(caseID, description)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error in script execution:", error.message);
    process.exit(1);
  });
