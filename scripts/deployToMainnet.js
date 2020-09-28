async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const cryptoPunksAddress = "0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB";

  const PunkToken = await ethers.getContractFactory("PunkToken");
  const PunkVault = await ethers.getContractFactory("PunkVault");

  const pt = await PunkToken.deploy();
  await pt.deployed();

  const pf = await PunkVault.deploy(pt.address, cryptoPunksAddress);
  await pf.deployed();

  console.log("PunkToken address:", pt.address);
  console.log("PunkVault address:", pf.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
