const hre = require("hardhat");

async function main() {
  const creditScoreContract = await hre.ethers.deployContract("CreditScore");

  await creditScoreContract.waitForDeployment();

  console.log(
    `CreditScore contract deployed to https://sepolia.etherscan.io/address/${creditScoreContract.target}`
  );
  console.log("Contract address:", creditScoreContract.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
