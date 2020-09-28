async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Erc721 = await ethers.getContractFactory("ERC721");
  const XToken = await ethers.getContractFactory("XToken");
  const XVault = await ethers.getContractFactory("XVault");

  const nft = await Erc721.deploy("Nft", "NFT");
  await nft.deployed();

  const xToken = await XToken.deploy("XToken", "XTO");
  await xToken.deployed();

  const xVault = await XVault.deploy(xToken.address, nft.address);
  await xVault.deployed();

  await xToken.transferOwnership(xVault.address);

  console.log("NFT address:", nft.address);
  console.log("XToken address:", xToken.address);
  console.log("XVault address:", xVault.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
