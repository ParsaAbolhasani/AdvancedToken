const { ethers } = require("hardhat");

async function main() {
    console.log("Deploying AdvancedToken...");

    const tokenName = "Advanced Token";
    const tokenSymbol = "ADV";
    const decimals = 18;
    const cap = ethers.parseEther("100000000");
    const admin = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"; // Hardhat default account

    const AdvancedToken = await ethers.getContractFactory("AdvancedToken");
    const token = await AdvancedToken.deploy(
        tokenName,
        tokenSymbol,
        decimals,
        cap,
        admin
    );

    await token.waitForDeployment();

    const tokenAddress = await token.getAddress();
    console.log(`✅ AdvancedToken deployed to: ${tokenAddress}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});