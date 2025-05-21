# FirstNft Solidity Contract

> ⚠️ **Disclaimer:** This smart contract has **not been professionally audited**. While it serves as a learning exercise, the code could potentially be improved for efficiency, security, and best practices. I am currently learning and developing my smart contract skills through the [Cyfrin Updraft](https://updraft.cyfrin.io/) platform and expect my coding abilities to become more refined over time. This project reflects my current stage in that journey. Please use with caution and for educational purposes only.

## 📜 Overview

`FirstNft` is a smart contract written in Solidity for creating a collection of Non-Fungible Tokens (NFTs) compliant with the ERC721 standard. It allows users to mint NFTs at a predefined price, up to a certain limit. The contract includes administrative functions for the developer, such as updating the total supply limit.

This contract is built using OpenZeppelin's ERC721 implementation, ensuring robust and secure NFT functionality.

**Author:** Selone Te

**License:** MIT

## ✨ Features

* **ERC721 Compliant:** Fully compatible with the ERC721 standard, allowing for interoperability with NFT marketplaces and wallets.
* **Fixed Mint Price:** NFTs can be minted by sending a specific amount of Ether, defined at contract deployment.
* **Limited Supply:** The total number of NFTs that can be minted is capped by `s_tokenIdLimit`.
* **Developer Controls:**
    * The deployer of the contract (`i_devWallet`) is designated as the developer.
    * The developer can update the total supply (`s_tokenIdLimit`) of the NFT collection using `updateTokenIdLimit()`.
* **Sequential Token IDs:** NFTs are minted with incrementally increasing token IDs, starting from 0.
* **Standard NFT Operations:**
    * `mintNft()`: Allows users to mint a new NFT by paying the `i_mintPrice`.
    * `transferNft()` / `transferNftFrom()`: Standard ERC721 functions for transferring NFTs.
    * `burnNft()`: Allows the owner of an NFT to permanently destroy it.
* **Metadata URI:** Supports a base URI for NFT metadata, which can be used to point to off-chain data (images, attributes, etc.).
* **Custom Errors:** Uses custom errors for clearer and more gas-efficient error reporting:
    * `FirstNft__CollectionSoldOut()`
    * `FirstNft__MintPriceNotReached()`
    * `FirstNft__WrongCaller()`

## 📋 Contract Details

### State Variables

* `i_devWallet (address private immutable)`: The wallet address of the contract deployer/developer.
* `i_mintPrice (uint256 private immutable)`: The price in wei required to mint one NFT.
* `s_baseUri (string private)`: The base URI for token metadata.
* `s_tokenIdLimit (uint256 private)`: The maximum number of NFTs that can be minted.
* `s_tokenIdMinted (uint256 private)`: A counter for the number of NFTs minted so far; also serves as the next token ID.
* `s_tokenIdToUri (mapping(uint256 => string) private)`: (Declared but not actively used in the provided logic for setting individual token URIs post-minting).

### Modifiers

* `onlyDevWallet()`: Restricts access to a function to only the `i_devWallet`.

### Constructor

```solidity
constructor(
    string memory _name,
    string memory _symbol,
    uint256 _mintPrice,
    string memory _baseUri,
    uint256 _tokenIdLimit
) ERC721(_name, _symbol)
### Constructor Arguments

When deploying the contract, you will need to provide the following arguments:

* `_name` (string): The name of your NFT collection (e.g., "My Awesome NFT").
* `_symbol` (string): The symbol for your NFT collection (e.g., "MAN").
* `_mintPrice` (uint256): The price per NFT in wei (e.g., `10000000000000000` for 0.01 ETH).
* `_baseUri` (string): The base URI for your token metadata. This URI will be concatenated with the token ID to form the full metadata URI for each token (e.g., `ipfs://<YOUR_CID>/`).
* `_tokenIdLimit` (uint256): The maximum number of NFTs that can be minted.

### Key Functions

* **`mintNft() external payable`**:
    * Allows any user to mint an NFT.
    * Requires `msg.value` to be equal to `i_mintPrice`.
    * Reverts if the collection is sold out (`s_tokenIdMinted == s_tokenIdLimit`).
* **`transferNft(address _to, uint256 _tokenId) external`**:
    * Transfers an NFT from `msg.sender` to `_to`.
* **`transferNftFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) external`**:
    * Transfers an NFT from `_from` to `_to`.
    * Requires `msg.sender` to be approved or the owner.
* **`updateTokenIdLimit(uint256 _newLimit) external onlyDevWallet`**:
    * Allows the `i_devWallet` (developer) to change the maximum supply of NFTs.
* **`burnNft(uint256 _tokenId) external`**:
    * Allows the owner of `_tokenId` to burn (destroy) it.
* **`baseTokenUri() external view returns (string memory)`**:
    * Returns the base URI for token metadata.
* **`_baseURI() internal view override returns (string memory)`**:
    * Internal function to retrieve the base URI (overrides ERC721's implementation).
* **`tokenIdMinted() external view returns (uint256)`**:
    * Returns the total number of NFTs minted so far.
* **`tokenIdLimit() external view returns (uint256)`**:
    * Returns the current maximum supply limit of NFTs.
* **`mintPrice() external view returns (uint256)`**:
    * Returns the minting price (in wei) of a single NFT.

## Getting Started

Follow these instructions to set up and interact with `FirstNft` within your Foundry project.

### Prerequisites

Ensure you have the following installed:

* **Foundry:** Follow the installation instructions on the [Foundry Book](https://book.getfoundry.sh/).

### Installation

1.  **Clone your repository:**
    ```bash
    git clone https://github.com/Q5-degen/CharityFactory.git
    cd CharityFactory
    ```

2.  **Install dependencies:**
    ```bash
    1.  Ensure you have [Foundry](https://book.getfoundry.sh/) installed on your system. Follow the instructions on the Foundry website for installation.

    2.  This project utilizes @openzeppelin ERC721 
      forge install OpenZeppelin/openzeppelin-contracts
    ```
