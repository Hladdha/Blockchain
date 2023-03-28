const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

const { expect } = require("chai");

describe ("ERC20 contarct"  , function (){
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("Coins");
        const [_deployer, addr1, addr2] = await ethers.getSigners();
    
        const hardhatToken = await Token.deploy("Test Coins" , "TST");
    
        await hardhatToken.deployed();

        return { Token, hardhatToken, _deployer, addr1, addr2 };
    }

    describe ("Deployment", function (){
        
        it("should assign Name of Token" , async function(){
            const {hardhatToken} = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.name()).to.equal("Test Coins");
        });
    
        it("should assign Symbol of Token" , async function(){
            const {hardhatToken} = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.symbol()).to.equal("TST");
        });
    
        it("should set decimals to 18" , async function(){
            const {hardhatToken} = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.decimals()).to.equal(18);
        });
    
        it("should set totalSupply to 1000 coins" , async function(){
            const {hardhatToken} = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.totalSupply()).to.equal(1000n);
        });
    
        it("should set owner balance to 1000 coins which is returned by balanceOf" , async function(){
            const {_deployer ,hardhatToken} = await loadFixture(deployTokenFixture);
            expect(await hardhatToken.balanceOf(_deployer.address)).to.equal(1000);
        });
    });

    describe ("Transactions", function(){
        it("should transfer token from owner to recipent", async function(){
            const {_deployer ,hardhatToken ,addr1 , addr2} = await loadFixture(deployTokenFixture);
            await hardhatToken.transfer(addr1.address , 100);
            expect(await hardhatToken.balanceOf(_deployer.address)).to.equal(900);
            expect(await hardhatToken.balanceOf(addr1.address)).to.equal(100);
    
            await hardhatToken.connect(addr1).transfer(addr2.address, 50)
            expect(await hardhatToken.balanceOf(addr2.address)).to.equal(50);
            expect(await hardhatToken.balanceOf(addr1.address)).to.equal(50);
        });

        it("Should emit Transfer event when transfer from another account", async function () {
            const {_deployer, addr1, addr2,hardhatToken } = await loadFixture(deployTokenFixture);
            expect(hardhatToken.connect(addr1).transfer(_deployer.address, addr2.address,50)).to.emit().withArgs(_deployer.address,addr2.address, 50);
        });  
    
        it("should fail if sender doesn't have enough tokens", async function () {
            const { hardhatToken, _deployer, addr1 } = await loadFixture(deployTokenFixture);
            const initialOwnerBalance = await hardhatToken.balanceOf(_deployer.address);
      
            await expect(
              hardhatToken.connect(addr1).transfer(_deployer.address, 1)
            ).to.be.revertedWith("Insufficient Balance");
      
            expect(await hardhatToken.balanceOf(_deployer.address)).to.equal(1000);
        });
    
        it("should approve a Third Party to be approved for spending token of approver" , async function(){
            const {_deployer, addr1, hardhatToken } = await loadFixture(deployTokenFixture);
            await hardhatToken.approve(addr1.address, 100);
            expect(await hardhatToken.allowance(_deployer.address, addr1.address)).to.equal(100);
        });
        
        it("Should emit Approval event when transfer from another account", async function () {
            const {_deployer, addr1, addr2,hardhatToken } = await loadFixture(deployTokenFixture);
            expect(hardhatToken.connect(addr1).approve(addr1.address,50)).to.emit().withArgs(addr1.address, 50);
        });
        
        it("should return approved amount of token of spender", async function (){
            const {_deployer, addr1, hardhatToken} = await loadFixture(deployTokenFixture);
            await hardhatToken.approve(addr1.address, 100);
            expect(await hardhatToken.allowance(_deployer.address, addr1.address)).to.equal(100);
        });
          
        it("should allow to send token from address to another address", async function () {
            const {_deployer, addr1,addr2, hardhatToken } = await loadFixture(deployTokenFixture);
            await hardhatToken.approve(addr1.address, 100);
            await hardhatToken.connect(addr1).transferFrom(_deployer.address, addr2.address, 50)
            expect(await hardhatToken.allowance(_deployer.address, addr1.address)).to.equal(50);
            expect(await hardhatToken.balanceOf(_deployer.address)).to.equal(950);
            expect(await hardhatToken.balanceOf(addr2.address)).to.equal(50);
        });
    });

    describe("mint and burn", function () {
        it("should mint new token by owner", async function () {
            const {_deployer, hardhatToken} = await loadFixture(deployTokenFixture);
            const initialBalance = await hardhatToken.balanceOf(_deployer.address);
            const initialTotalSupply = await hardhatToken.totalSupply();
    
            await hardhatToken.mint(_deployer.address, 100);
            const finalBalance = await hardhatToken.balanceOf(_deployer.address);
            const finalTotalSupply = await hardhatToken.totalSupply();
    
            expect(parseInt(initialBalance) + 100).to.equal(finalBalance);
            expect(parseInt(initialTotalSupply) + 100).to.equal(finalTotalSupply);
        })
    
        it("should fail if somone else try to mint new tokens" , async function(){
            const {_deployer, addr1 , hardhatToken} = await loadFixture(deployTokenFixture);
            const initialBalance = await hardhatToken.balanceOf(_deployer.address);
            const initialTotalSupply = await hardhatToken.totalSupply();

            await expect(
                hardhatToken.connect(addr1).mint(_deployer.address, 100)
              ).to.be.revertedWith("not allowed to mint");
        });

        it("should burn Tokens " , async function(){
            const {_deployer, hardhatToken} = await loadFixture(deployTokenFixture);
            const initialBalance = await hardhatToken.balanceOf(_deployer.address);

            await hardhatToken.burn(200);
            const finalBalance = await hardhatToken.balanceOf(_deployer.address);

            expect(initialBalance - 200).to.equal(finalBalance);
        });

    });    
});