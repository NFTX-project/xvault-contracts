async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const CryptoPunksMarket = await ethers.getContractFactory(
    "CryptoPunksMarket"
  );
  const XToken = await ethers.getContractFactory("XToken");
  const XVault = await ethers.getContractFactory("XVault");

  const cpm = await CryptoPunksMarket.deploy();
  await cpm.deployed();

  const xToken = await XToken.deploy("XToken", "XTO");
  await xToken.deployed();

  const xVault = await XVault.deploy(xToken.address, cpm.address);
  await xVault.deployed();

  await xToken.transferOwnership(xVault.address);
  await xVault.increaseSecurityLevel();
  await xVault.transferOwnership("0x71D30468Ae4b9B9F931d076e21D1139D44199999");

  console.log("CPM address:", cpm.address);
  console.log("XToken address:", xToken.address);
  console.log("XVault address:", xVault.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
