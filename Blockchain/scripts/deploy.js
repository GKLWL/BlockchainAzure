async function main() {
  const [deployer] = await ethers.getSigners();
  const balance = await deployer.getBalance();
  console.log("Deployer address:", deployer.address);
  console.log("Deployer balance:", ethers.utils.formatEther(balance), "ETH");
  console.log("Deploying contracts with the account:", deployer.address);

  const Blockchain = await ethers.getContractFactory("Blockchain");
  const blockchain = await Blockchain.deploy("Genesis block for Azure Automation logs");

  console.log("Blockchain contract deployed to:", blockchain.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
