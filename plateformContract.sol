// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Platform {
    address public owner;
    uint256 public pltTokenSupply = 1_000_000 ether;

    mapping(address => uint256) public userBalances; // PLT balance
    mapping(address => bool) public walletInitialized;

    struct CreatorToken {
        string name;
        string symbol;
        uint256 supply;
        uint256 price; // in PLT
        uint256 sold;
        address creator;
    }

    mapping(address => CreatorToken) public creatorTokens;
    mapping(address => mapping(address => uint256)) public userCreatorTokenBalances;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyCreator() {
        require(walletInitialized[msg.sender], "Wallet not initialized");
        _;
    }

    function initWallet() external {
        require(!walletInitialized[msg.sender], "Already initialized");
        walletInitialized[msg.sender] = true;
        userBalances[msg.sender] = 100 ether; // 100 PLT tokens on signup
    }

    function addPLT(uint256 amount) external onlyCreator {
        userBalances[msg.sender] += amount;
        pltTokenSupply += amount;
    }
mapping(string => address) public tokenNameToCreator;


    function createCreatorToken(string memory name, string memory symbol, uint256 supply, uint256 price) external onlyCreator {
        require(creatorTokens[msg.sender].supply == 0, "Already created");
        require(tokenNameToCreator[name] == address(0), "Name taken");
        tokenNameToCreator[name] = msg.sender;
        creatorTokens[msg.sender] = CreatorToken(name, symbol, supply, price, 0, msg.sender);
    }

    function buyCreatorToken(address creator, uint256 amount) external onlyCreator {
        CreatorToken storage token = creatorTokens[creator];
        require(token.supply >= token.sold + amount, "Not enough supply");
        uint256 cost = token.price * amount;
        require(userBalances[msg.sender] >= cost, "Insufficient PLT");

        userBalances[msg.sender] -= cost;
        userCreatorTokenBalances[msg.sender][creator] += amount;
        token.sold += amount;
    }

    function setTokenPrice(uint256 newPrice) external {
        CreatorToken storage token = creatorTokens[msg.sender];
        require(token.creator == msg.sender, "Not your token");
        token.price = newPrice;
    }

    function getMyCreatorToken() external view returns (CreatorToken memory) {
        return creatorTokens[msg.sender];
    }

    function getCreatorToken(address creator) external view returns (CreatorToken memory) {
        return creatorTokens[creator];
    }

    function getPLTBalance(address user) external view returns (uint256) {
        return userBalances[user];
    }

    function getCreatorTokenBalance(address creator) external view returns (uint256) {
        return userCreatorTokenBalances[msg.sender][creator];
    }
}
