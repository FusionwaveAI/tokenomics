const { expect } = require("chai");

describe("Max Supply", function () {
  let IdoPresale;
  let idoPresale;
  let owner; // Declare a variable to store the owner address

  beforeEach(async function () {
    // Deploy the contract using one of Hardhat's default accounts
    [owner] = await ethers.getSigners(); // Get the first account

    IdoPresale = await ethers.getContractFactory("IdoPresale");
    idoPresale = await IdoPresale.deploy(owner.address);

    await idoPresale.deployed();
  });

  it("should have the correct maximum supply", async function () {
    // Get the maximum supply from the contract
    const MAX_SUPPLY = await idoPresale.MAX_SUPPLY();

    // Perform assertions
    // Modify this based on how your MAX_SUPPLY is calculated
    // For example, if it's a constant value, you can directly compare it
    // with the expected value
    expect(MAX_SUPPLY).to.equal(100000000000);
  });
});
