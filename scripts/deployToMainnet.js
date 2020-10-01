async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const cryptoPunksAddress = "0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB";

  const XToken = await ethers.getContractFactory("XToken");
  const XVault = await ethers.getContractFactory("XVault");

  const xToken = await XToken.deploy("Punk", "PUNK");
  await xToken.deployed();

  const xVault = await XVault.deploy(xToken.address, cryptoPunksAddress);
  await xVault.deployed();

  console.log("XToken address:", xToken.address);
  console.log("XVault address:", xVault.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
