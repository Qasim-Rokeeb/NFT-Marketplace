// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract NFTMarketplace {
    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 price;
        bool active;
    }
    
    struct NFT {
        uint256 tokenId;
        address creator;
        string tokenURI;
        uint256 royalty; // in basis points (100 = 1%)
    }
    
    mapping(uint256 => NFT) public nfts;
    mapping(uint256 => Listing) public listings;
    mapping(uint256 => address) public tokenOwners;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public tokenApprovals;
    mapping(address => mapping(address => bool)) public operatorApprovals;
    
    uint256 public nextTokenId;
    uint256 public marketplaceFee = 250; // 2.5%
    address public owner;
    
    event NFTMinted(uint256 indexed tokenId, address indexed creator, string tokenURI);
    event Listed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event Sold(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);
    event Unlisted(uint256 indexed tokenId);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        nextTokenId = 1;
    }
    
    function mintNFT(string memory _tokenURI, uint256 _royalty) external {
        require(_royalty <= 1000, "Royalty too high"); // Max 10%
        
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        
        nfts[tokenId] = NFT({
            tokenId: tokenId,
            creator: msg.sender,
            tokenURI: _tokenURI,
            royalty: _royalty
        });
        
        tokenOwners[tokenId] = msg.sender;
        balances[msg.sender]++;
        
        emit NFTMinted(tokenId, msg.sender, _tokenURI);
    }
    
    function listNFT(uint256 _tokenId, uint256 _price) external {
        require(tokenOwners[_tokenId] == msg.sender, "Not owner");
        require(_price > 0, "Price must be greater than 0");
        
        listings[_tokenId] = Listing({
            seller: msg.sender,
            tokenId: _tokenId,
            price: _price,
            active: true
        });
        
        emit Listed(_tokenId, msg.sender, _price);
    }
    
    function buyNFT(uint256 _tokenId) external payable {
        Listing storage listing = listings[_tokenId];
        require(listing.active, "Not for sale");
        require(msg.value == listing.price, "Incorrect price");
        
        address seller = listing.seller;
        uint256 price = listing.price;
        
        // Calculate fees
        uint256 marketFee = (price * marketplaceFee) / 10000;
        uint256 royaltyFee = (price * nfts[_tokenId].royalty) / 10000;
        uint256 sellerAmount = price - marketFee - royaltyFee;
        
        // Transfer NFT
        tokenOwners[_tokenId] = msg.sender;
        balances[seller]--;
        balances[msg.sender]++;
        
        // Transfer payments
        payable(seller).transfer(sellerAmount);
        payable(nfts[_tokenId].creator).transfer(royaltyFee);
        payable(owner).transfer(marketFee);
        
        // Remove listing
        listing.active = false;
        
        emit Sold(_tokenId, msg.sender, seller, price);
    }
    
    function unlistNFT(uint256 _tokenId) external {
        require(listings[_tokenId].seller == msg.sender, "Not seller");
        
        listings[_tokenId].active = false;
        
        emit Unlisted(_tokenId);
    }
    
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return tokenOwners[_tokenId];
    }
    
    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return nfts[_tokenId].tokenURI;
    }
    
    function setMarketplaceFee(uint256 _fee) external onlyOwner {
        require(_fee <= 1000, "Fee too high"); // Max 10%
        marketplaceFee = _fee;
    }
}
