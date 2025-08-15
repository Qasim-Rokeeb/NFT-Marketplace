// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract NFTMarketplace {
    // Represents a sale listing for an NFT
    struct Listing {
        address seller;   // Address of the NFT owner who listed it
        uint256 tokenId;  // Token ID of the listed NFT
        uint256 price;    // Sale price in wei
        bool active;      // Whether the listing is active
    }
    
    // Represents an NFT's metadata and royalty info
    struct NFT {
        uint256 tokenId;      // Unique identifier for the NFT
        address creator;      // Original creator (receives royalties)
        string tokenURI;      // Metadata URI (image, JSON, etc.)
        uint256 royalty;      // Royalty fee in basis points (e.g., 100 = 1%)
    }
    
    // Mapping from tokenId to NFT details
    mapping(uint256 => NFT) public nfts;

    // Mapping from tokenId to its current sale listing
    mapping(uint256 => Listing) public listings;

    // Mapping from tokenId to current owner address
    mapping(uint256 => address) public tokenOwners;

    // Mapping from owner address to count of owned NFTs
    mapping(address => uint256) public balances;

    // Mapping from tokenId to an approved address for transfers (ERC721-like)
    mapping(uint256 => address) public tokenApprovals;

    // Mapping from owner to operator approvals (ERC721-like)
    mapping(address => mapping(address => bool)) public operatorApprovals;
    
    uint256 public nextTokenId;          // Next token ID to assign
    uint256 public marketplaceFee = 250; // Marketplace fee in basis points (250 = 2.5%)
    address public owner;                // Marketplace contract owner
    
    // Events for tracking actions
    event NFTMinted(uint256 indexed tokenId, address indexed creator, string tokenURI);
    event Listed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event Sold(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);
    event Unlisted(uint256 indexed tokenId);
    
    // Restricts function access to contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        nextTokenId = 1; // Start token IDs from 1
    }
    
    /**
     * @notice Mint a new NFT
     * @param _tokenURI Metadata URI for the NFT
     * @param _royalty Royalty in basis points (max 10%)
     */
    function mintNFT(string memory _tokenURI, uint256 _royalty) external {
        require(_royalty <= 1000, "Royalty too high"); // Limit to 10%
        
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        
        // Create new NFT record
        nfts[tokenId] = NFT({
            tokenId: tokenId,
            creator: msg.sender,
            tokenURI: _tokenURI,
            royalty: _royalty
        });
        
        // Assign ownership to minter
        tokenOwners[tokenId] = msg.sender;
        balances[msg.sender]++;
        
        emit NFTMinted(tokenId, msg.sender, _tokenURI);
    }
    
    /**
     * @notice List an owned NFT for sale
     * @param _tokenId The NFT to list
     * @param _price Sale price in wei
     */
    function listNFT(uint256 _tokenId, uint256 _price) external {
        require(tokenOwners[_tokenId] == msg.sender, "Not owner");
        require(_price > 0, "Price must be greater than 0");
        
        // Store listing data
        listings[_tokenId] = Listing({
            seller: msg.sender,
            tokenId: _tokenId,
            price: _price,
            active: true
        });
        
        emit Listed(_tokenId, msg.sender, _price);
    }
    
    /**
     * @notice Purchase an NFT from an active listing
     * @param _tokenId The NFT to buy
     */
    function buyNFT(uint256 _tokenId) external payable {
        Listing storage listing = listings[_tokenId];
        require(listing.active, "Not for sale");
        require(msg.value == listing.price, "Incorrect price sent");
        
        address seller = listing.seller;
        uint256 price = listing.price;
        
        // Calculate marketplace and royalty fees
        uint256 marketFee = (price * marketplaceFee) / 10000;
        uint256 royaltyFee = (price * nfts[_tokenId].royalty) / 10000;
        uint256 sellerAmount = price - marketFee - royaltyFee;
        
        // Transfer NFT ownership
        tokenOwners[_tokenId] = msg.sender;
        balances[seller]--;
        balances[msg.sender]++;
        
        // Distribute funds
        payable(seller).transfer(sellerAmount);                    // Seller payment
        payable(nfts[_tokenId].creator).transfer(royaltyFee);      // Royalty to creator
        payable(owner).transfer(marketFee);                        // Marketplace fee
        
        // Mark listing as inactive
        listing.active = false;
        
        emit Sold(_tokenId, msg.sender, seller, price);
    }
    
    /**
     * @notice Cancel an active listing
     * @param _tokenId The NFT to unlist
     */
    function unlistNFT(uint256 _tokenId) external {
        require(listings[_tokenId].seller == msg.sender, "Not seller");
        
        listings[_tokenId].active = false;
        
        emit Unlisted(_tokenId);
    }
    
    /**
     * @notice Get the owner of an NFT
     * @param _tokenId The NFT ID
     */
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return tokenOwners[_tokenId];
    }
    
    /**
     * @notice Get the metadata URI for an NFT
     * @param _tokenId The NFT ID
     */
    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return nfts[_tokenId].tokenURI;
    }
    
    /**
     * @notice Update the marketplace fee
     * @param _fee New fee in basis points (max 10%)
     */
    function setMarketplaceFee(uint256 _fee) external onlyOwner {
        require(_fee <= 1000, "Fee too high"); // Limit to 10%
        marketplaceFee = _fee;
    }
}
