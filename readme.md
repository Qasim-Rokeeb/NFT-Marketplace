
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
# 🖼 NFT Marketplace Smart Contract

A Solidity-based NFT minting and trading contract with:

- Creator royalties on every sale
- Marketplace fee for the owner
- On-chain listings and secure purchase flow

---

## 📌 Overview

This contract lets users:

- Mint NFTs with a custom royalty percentage (up to 10%).
- List NFTs for sale with a fixed ETH price.
- Buy NFTs securely — marketplace fee and creator royalty are auto-distributed.
- Unlist NFTs anytime before they are sold.
- Owner can set marketplace fee and collect revenue.

Deployed on Base Sepolia Testnet
- Contract Address: `0xcBCB09cd448Bc7c2Df0A8229b1e709EAf0AD3720`
- View on BaseScan: https://sepolia.basescan.org/address/0xcBCB09cd448Bc7c2Df0A8229b1e709EAf0AD3720#code

---

## ⚙ Features

- Royalty Support → Automatic creator royalty on every sale.
- Marketplace Fee → Default 2.5%, owner-adjustable (max 10%).
- NFT Metadata → Stores `tokenURI` for off-chain metadata.
- Secure Sales → Exact payment required to purchase.
- Event Logging → Track with `NFTMinted`, `Listed`, `Sold`, `Unlisted`.

---

## 🌐 Network Setup (Base Sepolia)

Add Base Sepolia to MetaMask:

- Network Name: Base Sepolia
- RPC URL: https://sepolia.base.org
- Chain ID: 84532
- Currency Symbol: ETH
- Block Explorer: https://sepolia.basescan.org

Funding: use an official Base Sepolia faucet to get test ETH.

---

## 🚀 Quick Start (Remix)

Remix is the easiest way to deploy and interact.

1. Open Remix: https://remix.ethereum.org
2. Create `contracts/NFT Marketplace.sol` and paste the contract from this repo.
3. In "Solidity Compiler": select `0.8.19`, then compile.
4. In "Deploy & Run":
   - Environment: Injected Provider - MetaMask
   - Network: Switch MetaMask to Base Sepolia
   - Click Deploy to deploy `NFTMarketplace`.
5. Interact:
   - Mint: `mintNFT("ipfs://...", 250)` (250 = 2.5% royalty)
   - List: `listNFT(1, 50000000000000000)` → lists token `1` for `0.05 ETH` (values are in wei)
   - Buy: set Value to the exact listing price (in wei), then call `buyNFT(1)`
   - Unlist: `unlistNFT(1)` as the seller

Tip: ETH amounts in Remix must be in wei.

---

## 🛠 Deployment (Solidity)

Requirements:

- Solidity ^0.8.19
- Base Sepolia testnet
- Test ETH for gas

Example:

```solidity
NFTMarketplace marketplace = new NFTMarketplace();
```

On deployment:

- Deployer becomes the owner.
- Marketplace fee defaults to 2.5%.

---

## 📐 Fees & Royalties (Math)

Let `price = P`, `marketplaceFee = mf` (basis points), `royalty = r` (basis points).

- Marketplace: `P * mf / 10000`
- Royalty: `P * r / 10000`
- Seller receives: `P - (marketplace + royalty)`

Example: `P = 0.50 ETH`, `mf = 250 (2.5%)`, `r = 100 (1%)` →
- Marketplace: `0.0125 ETH`
- Royalty: `0.005 ETH`
- Seller: `0.4825 ETH`

---

## 📜 Functions

Mint an NFT

```solidity
mintNFT(string memory _tokenURI, uint256 _royalty)
```

- `_royalty` in basis points (`100 = 1%`, max `1000 = 10%`).
- Emits: `NFTMinted`.

List an NFT

```solidity
listNFT(uint256 _tokenId, uint256 _price)
```

- Must be NFT owner.
- Price > 0 required.
- Emits: `Listed`.

Buy an NFT

```solidity
buyNFT(uint256 _tokenId) payable
```

- Value must equal listing price (in wei).
- Distributes seller amount, creator royalty, and marketplace fee.
- Transfers ownership and marks listing inactive.
- Emits: `Sold`.

Unlist an NFT

```solidity
unlistNFT(uint256 _tokenId)
```

- Must be the seller.
- Emits: `Unlisted`.

View Helpers

- `ownerOf(uint256 _tokenId)` → Current owner address.
- `tokenURI(uint256 _tokenId)` → Metadata URI.

Admin

```solidity
setMarketplaceFee(uint256 _fee)
```

- Only owner.
- Max `1000` (10%).

---

## 🧪 Testing & Frontend Interaction

### Remix (no tooling needed)
- Use Quick Start to deploy and call functions directly.
- For `buyNFT`, set the "Value" field to the exact listing price in wei.

### Frontend (viem/wagmi)
This repo includes `viem` and `wagmi`. Example usage:

```ts
import { createPublicClient, createWalletClient, http, parseAbi, parseEther } from 'viem';
import { baseSepolia } from 'viem/chains';

const CONTRACT_ADDRESS = '0xcBCB09cd448Bc7c2Df0A8229b1e709EAf0AD3720';
const ABI = parseAbi([
  'function mintNFT(string _tokenURI, uint256 _royalty)',
  'function listNFT(uint256 _tokenId, uint256 _price)',
  'function buyNFT(uint256 _tokenId) payable',
  'function unlistNFT(uint256 _tokenId)',
  'function ownerOf(uint256 _tokenId) view returns (address)',
  'function tokenURI(uint256 _tokenId) view returns (string)',
]);

const publicClient = createPublicClient({ chain: baseSepolia, transport: http() });
// In a browser, use wagmi to get a connected walletClient

async function mint(walletClient) {
  await walletClient.writeContract({
    address: CONTRACT_ADDRESS,
    abi: ABI,
    functionName: 'mintNFT',
    args: ['ipfs://Qm...', 250],
  });
}

async function list(walletClient) {
  await walletClient.writeContract({
    address: CONTRACT_ADDRESS,
    abi: ABI,
    functionName: 'listNFT',
    args: [1n, parseEther('0.05')],
  });
}

async function buy(walletClient) {
  await walletClient.writeContract({
    address: CONTRACT_ADDRESS,
    abi: ABI,
    functionName: 'buyNFT',
    args: [1n],
    value: parseEther('0.05'),
  });
}

async function ownerOfToken() {
  const owner = await publicClient.readContract({
    address: CONTRACT_ADDRESS,
    abi: ABI,
    functionName: 'ownerOf',
    args: [1n],
  });
  console.log('Owner:', owner);
}
```

Replace `CONTRACT_ADDRESS` with your deployment address if different.

---

## ✅ Verify on BaseScan

1. Open your contract page on BaseScan.
2. Click "Verify & Publish".
3. Select compiler `0.8.19` and paste the source.
4. Match optimization settings.
5. Submit to verify.

---

## 🩺 Troubleshooting

- "Incorrect price sent": `value` must equal listing price in wei.
- "Not owner": Only the current owner can `listNFT`.
- "Not seller": Only the lister can `unlistNFT`.
- "Only owner": `setMarketplaceFee` is owner-only.
- Failures: Ensure Base Sepolia is selected, you have test ETH, and gas is set automatically.

---

## ⚠️ Limitations & Notes

- Minimal marketplace; not full ERC-721 transfer/approval.
- `tokenApprovals` and `operatorApprovals` are placeholders and unused.
- Ownership is tracked internally; transfers occur via mint/buy only.
- Uses `transfer` for ETH payouts; consider `call` if you need more flexibility.

---

## 🔒 Security Notes

- Payments use `transfer` (2300 gas stipend). If recipients need more gas, switch to `call` with proper reentrancy guards.
- No external token standards are implemented; behavior is confined to this contract’s storage.

---

## 📄 License

MIT — free to use and modify.


