// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract IdoPresale is
    ERC20,
    ERC20Burnable,
    ERC20Pausable,
    Ownable,
    ERC20Permit
{
    struct Round {
        uint256 poolSize;
        uint256 mintedTokens;
    }

    struct TeamMember {
        uint256 percentage; // Percentage of tokens assigned to the team member
        bool whitelisted; // Indicates whether the team member is whitelisted
    }

    Round[] public rounds;

    Round public privateSaleRound;
    Round public publicSaleRound;
    Round public teamRound;

    // Token pools
    uint256 private constant PRIVATE_SALE_POOL = 80000000 * 10**18;
    uint256 private constant PUBLIC_SALE_POOL = 100000000 * 10**18;
    uint256 private constant MARKETING_POOL = 60000000 * 10**18;
    uint256 private constant TEAM_POOL = 150000000 * 10**18;
    uint256 private constant STRATEGIC_FUNDING_POOL = 180000000 * 10**18;
    uint256 private constant AIRDROP_POOL = 300000000 * 10**18;
    uint256 private constant LIQUIDITY_POOL = 25000000 * 10**18;
    uint256 private constant ADVISORY_POOL = 20000000 * 10**18;
    uint256 private constant RESERVE_POOL = 25000000 * 10**18;

    mapping(address => TeamMember) public teamMembers;
    address[] public teamMemberAddresses; // To store whitelisted team member addresses

    uint8[25] vestingSchedulePresale = [
        10,
        1,
        1,
        1,
        1,
        12,
        1,
        2,
        1,
        2,
        1,
        12,
        2,
        2,
        2,
        2,
        2,
        2,
        14,
        2,
        3,
        3,
        3,
        3,
        15
    ];

    uint8[13] vestingSchedulePublicSale = [
        50,
        3,
        3,
        3,
        3,
        3,
        10,
        3,
        3,
        3,
        3,
        3,
        10
    ];

    uint8[19] vestingScheduleTeam = [
        15,
        2,
        2,
        2,
        2,
        2,
        2,
        15,
        3,
        3,
        3,
        3,
        3,
        15,
        3,
        3,
        3,
        3,
        16
    ];

    uint256 public constant MAX_SUPPLY =
        PRIVATE_SALE_POOL +
            PUBLIC_SALE_POOL +
            MARKETING_POOL +
            TEAM_POOL +
            STRATEGIC_FUNDING_POOL +
            AIRDROP_POOL +
            LIQUIDITY_POOL +
            ADVISORY_POOL +
            RESERVE_POOL;

    // Token TGE Time
    uint256 private constant TGE_TIME = 0 weeks;
    uint256 private constant WEEK_DURATION = 1 weeks;
    uint256 private constant TOTAL_WEEKS = 25;

    constructor(address initialOwner)
        ERC20("MyToken", "MTK")
        Ownable(initialOwner)
        ERC20Permit("MyToken")
    {
        // Initialize rounds
        rounds.push(Round(PRIVATE_SALE_POOL, 0));
        rounds.push(Round(PUBLIC_SALE_POOL, 0));
        rounds.push(Round(MARKETING_POOL, 0));
        rounds.push(Round(TEAM_POOL, 0));
        rounds.push(Round(STRATEGIC_FUNDING_POOL, 0));
        rounds.push(Round(AIRDROP_POOL, 0));
        rounds.push(Round(LIQUIDITY_POOL, 0));
        rounds.push(Round(ADVISORY_POOL, 0));
        rounds.push(Round(RESERVE_POOL, 0));

        privateSaleRound = Round(PRIVATE_SALE_POOL, 0);
        publicSaleRound = Round(PUBLIC_SALE_POOL, 0);
        teamRound = Round(TEAM_POOL, 0);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _getWeek(uint256 timestamp) internal pure returns (uint256) {
        return (timestamp - TGE_TIME) / WEEK_DURATION;
    }

    function _calculateAvailableTokens(
        uint256 week,
        uint256 salePool,
        uint8[] memory percentages
    ) internal pure returns (uint256) {
        require(week < TOTAL_WEEKS, "Distribution period ended");

        return (salePool * percentages[week]) / 100;
    }

    function mintPrivateSale(address to, uint256 amount) external onlyOwner {
        uint256 currentWeek = _getWeek(block.timestamp);

        uint8[] memory vestingScheduleDynamic = new uint8[](
            vestingSchedulePresale.length
        );
        for (uint256 i = 0; i < vestingSchedulePresale.length; i++) {
            vestingScheduleDynamic[i] = vestingSchedulePresale[i];
        }

        // Calculate available tokens for the current week
        uint256 availableTokens = 0;
        for (uint256 week = 0; week <= currentWeek; week++) {
            availableTokens += _calculateAvailableTokens(
                week,
                PRIVATE_SALE_POOL,
                vestingScheduleDynamic
            );
        }

        require(
            amount <= availableTokens,
            "Exceeds available tokens for this week"
        );
        require(
            privateSaleRound.mintedTokens + amount <= privateSaleRound.poolSize,
            "Exceeds pool size"
        );

        privateSaleRound.mintedTokens += amount;
        _mintFromPool(to, amount, 0);
    }

    function mintPublicSale(address to, uint256 amount) external onlyOwner {
        uint256 currentWeek = _getWeek(block.timestamp);

        uint8[] memory vestingScheduleDynamic = new uint8[](
            vestingSchedulePublicSale.length
        );
        for (uint256 i = 0; i < vestingSchedulePublicSale.length; i++) {
            vestingScheduleDynamic[i] = vestingSchedulePublicSale[i];
        }

        // Calculate available tokens for the current week
        uint256 availableTokens = 0;
        for (uint256 week = 0; week <= currentWeek; week++) {
            availableTokens += _calculateAvailableTokens(
                week,
                PRIVATE_SALE_POOL,
                vestingScheduleDynamic
            );
        }

        require(
            amount <= availableTokens,
            "Exceeds available tokens for this week"
        );
        require(
            publicSaleRound.mintedTokens + amount <= publicSaleRound.poolSize,
            "Exceeds pool size"
        );

        publicSaleRound.mintedTokens += amount;
        _mintFromPool(to, amount, 1);
    }

    function mintMarketingPool(address to, uint256 amount) external onlyOwner {
        _mintFromPool(to, amount, 2);
    }

    // Function to whitelist a team member and assign a percentage of tokens
    function whitelistTeamMember(address memberAddress, uint256 percentage)
        external
        onlyOwner
    {
        require(
            percentage <= 100,
            "Percentage must be less than or equal to 100"
        );
        require(
            !teamMembers[memberAddress].whitelisted,
            "Team member already whitelisted"
        );

        teamMembers[memberAddress] = TeamMember(percentage, true);
        teamMemberAddresses.push(memberAddress);
    }

    function mintTeam(uint256 amount) external onlyWhitelistedTeamMember {
        uint256 currentWeek = _getWeek(block.timestamp);

        uint8[] memory vestingScheduleDynamic = new uint8[](
            vestingScheduleTeam.length
        );

        // Calculate available tokens for the current week
        uint256 availableTokens = 0;
        for (uint256 week = 6; week <= currentWeek; week++) {
            availableTokens += _calculateAvailableTokens(
                week,
                PRIVATE_SALE_POOL,
                vestingScheduleDynamic
            );
        }

        require(
            amount <= availableTokens,
            "Exceeds available tokens for this week"
        );

        // Distribute tokens to the caller based on their assigned percentage
        uint256 memberPercentage = teamMembers[msg.sender].percentage;
        uint256 memberAmount = (amount * memberPercentage) / 100;
        _mintFromPool(msg.sender, memberAmount, 3); // Assuming poolIndex 3 is for team
    }

    function mintStrategicFunding(address to, uint256 amount)
        external
        onlyOwner
    {
        _mintFromPool(to, amount, 4);
    }

    function mintAirdrop(address to, uint256 amount) external onlyOwner {
        _mintFromPool(to, amount, 5);
    }

    function mintLiquidity(address to, uint256 amount) external onlyOwner {
        _mintFromPool(to, amount, 6);
    }

    function mintAdvisory(address to, uint256 amount) external onlyOwner {
        _mintFromPool(to, amount, 7);
    }

    function mintReserve(address to, uint256 amount) external onlyOwner {
        _mintFromPool(to, amount, 8);
    }

    function _mintFromPool(
        address to,
        uint256 amount,
        uint256 poolIndex
    ) private onlyOwner {
        require(poolIndex < rounds.length, "Invalid pool index");
        require(
            rounds[poolIndex].mintedTokens + amount <=
                rounds[poolIndex].poolSize,
            "Exceeds pool size"
        );

        rounds[poolIndex].mintedTokens += amount;
        _mint(to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }

    modifier onlyWhitelistedTeamMember() {
        require(
            teamMembers[msg.sender].whitelisted,
            "Caller is not a whitelisted team member"
        );
        _;
    }
}
