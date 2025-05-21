// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title FirstNft
 * @author Selone Te
 * @notice This contract implements a basic ERC721 Non-Fungible Token (NFT)
 * with a fixed mint price, a token ID limit, and a developer wallet for certain administrative functions.
 * It allows users to mint NFTs, transfer them, and burn them. The developer can update the token ID limit.
 */
contract FirstNft is ERC721 {
    error FirstNft__CollectionSoldOut();
    error FirstNft__MintPriceNotReached();
    error FirstNft__WrongCaller();

    address private immutable i_devWallet;
    uint256 private immutable i_mintPrice;

    string private s_baseUri;
    uint256 private s_tokenIdLimit;
    uint256 private s_tokenIdMinted;
    mapping(uint256 => string) private s_tokenIdToUri;

    modifier onlyDevWallet() {
        if (msg.sender != i_devWallet) revert FirstNft__WrongCaller();
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _mintPrice,
        string memory _baseUri,
        uint256 _tokenIdLimit
    ) ERC721(_name, _symbol) {
        i_devWallet = msg.sender;
        i_mintPrice = _mintPrice;
        s_baseUri = _baseUri;
        s_tokenIdLimit = _tokenIdLimit;
    }

    function mintNft() external payable {
        if (s_tokenIdMinted == s_tokenIdLimit)
            revert FirstNft__CollectionSoldOut();
        if (msg.value != i_mintPrice) revert FirstNft__MintPriceNotReached();

        _safeMint(msg.sender, s_tokenIdMinted);

        s_tokenIdMinted++;
    }

    function transferNft(address _to, uint256 _tokenId) external {
        _safeTransfer(msg.sender, _to, _tokenId, "");
    }

    function transferNftFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external {
        safeTransferFrom(_from, _to, _tokenId, _data);
    }

    function updateTokenIdLimit(uint256 _newLimit) external onlyDevWallet {
        s_tokenIdLimit = _newLimit;
    }

    function burnNft(uint256 _tokenId) external {
        if (msg.sender != ownerOf(_tokenId)) revert FirstNft__WrongCaller();

        _burn(_tokenId);
    }

    function baseTokenUri() external view returns (string memory _baseUri) {
        _baseUri = _baseURI();
    }

    function _baseURI() internal view override returns (string memory) {
        return s_baseUri;
    }

    function tokenIdMinted() external view returns (uint256 _counter) {
        _counter = s_tokenIdMinted;
    }

    function tokenIdLimit() external view returns (uint256 _limit) {
        _limit = s_tokenIdLimit;
    }

    function mintPrice() external view returns (uint256 _price) {
        _price = i_mintPrice;
    }
}
