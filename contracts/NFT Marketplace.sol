// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title NFTMarketplace
 * @notice Minimal marketplace to mint, list, buy, and unlist NFTs with creator royalties and marketplace fees.
 * @dev Uses internal ownership tracking (non-ERC721) and basis points for fees/royalties.
 */

contract NFTMarketplace {
    // ====== Types ======
    /// @dev Represents a sale listing for an NFT.
    struct Listing {
        address seller;   // Address of the NFT owner who listed it
        uint256 tokenId;  // Token ID of the listed NFT
        uint256 price;    // Sale price in wei
        bool active;      // Whether the listing is active
    }
    
    /// @dev Represents an NFT's metadata and royalty info.
    struct NFT {
        uint256 tokenId;      // Unique identifier for the NFT
        address creator;      // Original creator (receives royalties)
        string tokenURI;      // Metadata URI (image, JSON, etc.)
        uint256 royalty;      // Royalty fee in basis points (e.g., 100 = 1%)
    }
    
    // ====== Storage ======
    /// @notice NFT details indexed by `tokenId`.
    mapping(uint256 => NFT) public nfts;

    /// @notice Current active (or last known) listing indexed by `tokenId`.
    mapping(uint256 => Listing) public listings;

    /// @notice Current owner address for each `tokenId`.
    mapping(uint256 => address) public tokenOwners;

    /// @notice Balance of NFTs per owner address.
    mapping(address => uint256) public balances;

    /// @dev Approved address for a `tokenId` (placeholder; ERC721-like, unused here).
    mapping(uint256 => address) public tokenApprovals;

    /// @dev Operator approvals per owner (placeholder; ERC721-like, unused here).
    mapping(address => mapping(address => bool)) public operatorApprovals;
    
    /// @notice Next token ID to assign when minting.
    uint256 public nextTokenId;          
    /// @notice Marketplace fee in basis points (250 = 2.5%).
    uint256 public marketplaceFee = 250; 
    /// @notice Marketplace contract owner.
    address public owner;                
    
    // ====== Events ======
    /// @notice Emitted when a new NFT is minted.
    /// @param tokenId Newly minted token ID.
    /// @param creator Address of the creator/minter.
    /// @param tokenURI Metadata URI associated with the NFT.
    event NFTMinted(uint256 indexed tokenId, address indexed creator, string tokenURI);
    /// @notice Emitted when an NFT is listed for sale.
    /// @param tokenId Token ID listed.
    /// @param seller Address listing the NFT.
    /// @param price Sale price in wei.
    event Listed(uint256 indexed tokenId, address indexed seller, uint256 price);
    /// @notice Emitted when an NFT is sold.
    /// @param tokenId Token ID sold.
    /// @param buyer Address purchasing the NFT.
    /// @param seller Address selling the NFT.
    /// @param price Sale price paid in wei.
    event Sold(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);
    /// @notice Emitted when an NFT listing is canceled or deactivated.
    /// @param tokenId Token ID unlisted.
    event Unlisted(uint256 indexed tokenId);
    
    // ====== Modifiers ======
    /// @dev Restricts function access to the contract owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    // ====== Constructor ======
    constructor() {
        owner = msg.sender;
        nextTokenId = 1; // Start token IDs from 1
    }
    
    /**
     * @notice Mint a new NFT
     * @param _tokenURI Metadata URI for the NFT
     * @param _royalty Royalty in basis points (max 10%)
     * @dev Assigns ownership to the minter and records creator/royalty info.
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
     * @dev Overwrites any existing listing for the token.
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
     * @dev Distributes marketplace fee and creator royalty; marks listing inactive.
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
     * @dev Marks the listing as inactive without deleting it.
     */
    function unlistNFT(uint256 _tokenId) external {
        require(listings[_tokenId].seller == msg.sender, "Not seller");
        
        listings[_tokenId].active = false;
        
        emit Unlisted(_tokenId);
    }
    
    /**
     * @notice Get the owner of an NFT
     * @param _tokenId The NFT ID
     * @return The address of the current owner for the given `tokenId`.
     */
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return tokenOwners[_tokenId];
    }
    
    /**
     * @notice Get the metadata URI for an NFT
     * @param _tokenId The NFT ID
     * @return The metadata URI associated with the given `tokenId`.
     */
    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return nfts[_tokenId].tokenURI;
    }
    
    /**
     * @notice Update the marketplace fee
     * @param _fee New fee in basis points (max 10%)
     * @dev Fee is applied on sales and sent to the contract owner.
     */
    function setMarketplaceFee(uint256 _fee) external onlyOwner {
        require(_fee <= 1000, "Fee too high"); // Limit to 10%
        marketplaceFee = _fee;
    }
}
