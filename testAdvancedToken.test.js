const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AdvancedToken", function () {
    let token, owner, addr1, addr2;
    
    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        
        const AdvancedToken = await ethers.getContractFactory("AdvancedToken");
        token = await AdvancedToken.deploy(
            "Advanced Token",
            "ADV",
            18,
            ethers.parseEther("100000000"),
            owner.address
        );
        await token.waitForDeployment();
    });

    describe("Deployment", function () {
        it("Should set the correct name", async function () {
            expect(await token.name()).to.equal("Advanced Token");
        });

        it("Should set the correct symbol", async function () {
            expect(await token.symbol()).to.equal("ADV");
        });
    });

    describe("Minting", function () {
        it("Should mint tokens to an address", async function () {
            const mintAmount = ethers.parseEther("1000");
            await token.mint(addr1.address, mintAmount);
            expect(await token.balanceOf(addr1.address)).to.equal(mintAmount);
        });

        it("Should not allow non-minter to mint", async function () {
            const mintAmount = ethers.parseEther("1000");
            await expect(
                token.connect(addr1).mint(addr2.address, mintAmount)
            ).to.be.reverted;
        });
    });

    describe("Transfers", function () {
        beforeEach(async function () {
            await token.mint(owner.address, ethers.parseEther("10000"));
        });

        it("Should transfer tokens between accounts", async function () {
            await token.transfer(addr1.address, ethers.parseEther("100"));
            expect(await token.balanceOf(addr1.address)).to.equal(ethers.parseEther("100"));
        });
    });
});