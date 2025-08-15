
# 🖼 NFT Marketplace Smart Contract

A **Solidity-based** NFT minting and trading platform with:

* **Creator royalties** on every sale
* **Marketplace fee** for the owner
* Full **on-chain NFT listings** and **secure purchase flow**

---

## 📌 Overview

This contract lets users:

* **Mint NFTs** with a custom royalty percentage (up to **10%**).
* **List NFTs** for sale with a fixed ETH price.
* **Buy NFTs** securely — with automatic distribution of marketplace fees and creator royalties.
* **Unlist NFTs** anytime before they are sold.
* **Owner privileges** to set marketplace fee and collect revenue.

**Deployed on Base Sepolia Testnet**
📜 Contract Address: `0xcBCB09cd448Bc7c2Df0A8229b1e709EAf0AD3720`
🔍 [View on BaseScan](https://sepolia.basescan.org/address/0xcBCB09cd448Bc7c2Df0A8229b1e709EAf0AD3720#code) ✅

---

## ⚙ Features

* **Royalty Support** → Automatic creator royalty on every sale.
* **Marketplace Fee** → Default 2.5%, owner-adjustable (max 10%).
* **NFT Metadata** → Stores `tokenURI` for off-chain metadata.
* **Secure Sales** → Exact payment required to purchase.
* **Event Logging** → Easy tracking with:

  * `NFTMinted`
  * `Listed`
  * `Sold`
  * `Unlisted`

---

## 🛠 Deployment

### Requirements

* Solidity `^0.8.19`
* Base Sepolia testnet
* ETH for deployment gas fees

### Example Deployment

```solidity
NFTMarketplace marketplace = new NFTMarketplace();
```

**On deployment:**

* The deployer becomes the **owner**.
* Marketplace fee defaults to **2.5%**.

---

## 📜 Functions

### Mint an NFT

```solidity
mintNFT(string memory _tokenURI, uint256 _royalty)
```

* `_royalty` in basis points (`100 = 1%`, max `1000 = 10%`).
* Emits: `NFTMinted`.

---

### List an NFT

```solidity
listNFT(uint256 _tokenId, uint256 _price)
```

* Must be NFT owner.
* Price > 0 required.
* Emits: `Listed`.

---

### Buy an NFT

```solidity
buyNFT(uint256 _tokenId) payable
```

* Exact ETH amount required.
* Distributes:

  * Seller payment (minus fees)
  * Creator royalty
  * Marketplace fee
* Transfers NFT ownership.
* Emits: `Sold`.

---

### Unlist an NFT

```solidity
unlistNFT(uint256 _tokenId)
```

* Must be the seller.
* Emits: `Unlisted`.

---

### View Functions

* `ownerOf(uint256 _tokenId)` → Current owner address.
* `tokenURI(uint256 _tokenId)` → Metadata URI.

---

### Admin Function

```solidity
setMarketplaceFee(uint256 _fee)
```

* Only callable by owner.
* Max `1000` (10%).

---

## 🧪 Testing

Using Hardhat:

```bash
npm install
npx hardhat test
```

---

## 🔒 Security Notes

* Payments use **`transfer`** for ETH — can be updated to **`call`** for gas stipend flexibility.
* No ERC721 transfer approval — ownership is updated in contract storage.

---

## 📄 License

MIT — free to use and modify.

---


