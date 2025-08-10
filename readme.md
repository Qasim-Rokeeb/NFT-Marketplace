

# 🖼 NFT Marketplace Smart Contract

A Solidity-based **NFT minting and marketplace** system with built-in royalties for creators and a marketplace fee for the owner. Users can mint NFTs, list them for sale, buy NFTs, and earn royalties on secondary sales.

---

## 📌 Overview

* **Mint NFTs** with a custom royalty percentage (up to 10%).
* **List NFTs for Sale** with a set price.
* **Buy NFTs** securely with ETH, ensuring marketplace fees and royalties are automatically distributed.
* **Unlist NFTs** if the seller changes their mind.
* **Owner Role:** Can set marketplace fee and collect revenue.

**Deployed & Verified on Base Sepolia:**
`0xcBCB09cd448Bc7c2Df0A8229b1e709EAf0AD3720`
🔍 [View Verified Contract on BaseScan](https://sepolia.basescan.org/address/0xcBCB09cd448Bc7c2Df0A8229b1e709EAf0AD3720#code) ✅

---

## ⚙️ Features

* **Royalty Support:** Automatic royalty payments to NFT creators on every sale.
* **Marketplace Fee:** Default 2.5% (adjustable by owner, max 10%).
* **NFT Metadata:** Stores `tokenURI` for each NFT.
* **Secure Sales:** Requires exact payment to buy NFTs.
* **Events:**

  * `NFTMinted`
  * `Listed`
  * `Sold`
  * `Unlisted`

---

## 🛠 Deployment

### Requirements

* Solidity `^0.8.19`
* Base Sepolia network
* ETH balance for deployment gas fees

### Example Deployment

```solidity
NFTMarketplace marketplace = new NFTMarketplace();
```

---

## 📜 Functions

### **mintNFT(string \_tokenURI, uint256 \_royalty)**

Mint a new NFT.

* `_royalty` is in basis points (e.g., `100 = 1%`).
* **Emits:** `NFTMinted`.

---

### **listNFT(uint256 \_tokenId, uint256 \_price)**

List an owned NFT for sale.

* Must be the token owner.
* Price must be > 0.
* **Emits:** `Listed`.

---

### **buyNFT(uint256 \_tokenId)** (payable)

Buy a listed NFT.

* Pays the seller (minus fees), marketplace owner, and NFT creator royalty.
* Transfers NFT ownership.
* **Emits:** `Sold`.

---

### **unlistNFT(uint256 \_tokenId)**

Unlist an NFT from sale.

* Must be the seller.
* **Emits:** `Unlisted`.

---

### **ownerOf(uint256 \_tokenId)**

Returns the current owner of the NFT.

---

### **tokenURI(uint256 \_tokenId)**

Returns the metadata URI of the NFT.

---

### **setMarketplaceFee(uint256 \_fee)** (onlyOwner)

Updates the marketplace fee (max 10%).

---

## 🧪 Testing

Run local tests using Hardhat:

```bash
npm install
npx hardhat test
```

---

## 📄 License

MIT License – Free to use and modify.

---
