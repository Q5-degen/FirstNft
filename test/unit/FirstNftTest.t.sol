// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FirstNftDeployer} from "../../script/FirstNftDeployer.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {FirstNft} from "../../src/FirstNft.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract FirstNftTest is Test {
    using Strings for uint256;

    FirstNft private s_fn;
    HelperConfig private s_config;
    FirstNftDeployer private s_fnd;

    uint256 private constant FUND = 1 ether;
    address private s_minter = makeAddr("addr");
    address private DEFAULT_BROADCASTER =
        0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    function setUp() external {
        s_fnd = new FirstNftDeployer();
        (s_fn, s_config) = s_fnd.run();
        vm.deal(s_minter, FUND);
    }

    function testMintNftFailedWith__CollectionSoldOut() external {
        uint256 tokenIdLimit = s_config.getParams()._tokenIdLimit;
        uint256 mintPrice = s_config.getParams()._mintPrice;

        for (uint256 index; index < tokenIdLimit; index++) {
            vm.prank(s_minter);
            s_fn.mintNft{value: mintPrice}();
        }

        vm.prank(s_minter);
        vm.expectRevert(FirstNft.FirstNft__CollectionSoldOut.selector);
        s_fn.mintNft{value: mintPrice}();
    }

    function testMintNftFailedWith__MintPriceNotReached() external {
        vm.prank(s_minter);
        vm.expectRevert(FirstNft.FirstNft__MintPriceNotReached.selector);
        s_fn.mintNft{value: FUND}();
    }

    function testMintNftSucceed() external {
        uint256 tokenIdLimit = s_config.getParams()._tokenIdLimit;
        uint256 mintPrice = s_config.getParams()._mintPrice;

        for (uint256 index; index < tokenIdLimit; index++) {
            vm.prank(s_minter);
            s_fn.mintNft{value: mintPrice}();
        }

        uint256 tokenCounter = s_fn.tokenIdMinted();
        assertEq(tokenIdLimit, tokenCounter);

        uint256 minterBal = s_fn.balanceOf(s_minter);
        assertEq(minterBal, tokenCounter);

        for (uint256 tokenId; tokenId < tokenIdLimit; tokenId++) {
            address owner = s_fn.ownerOf(tokenId);
            assert(owner == s_minter);
        }
    }

    function testTransferNftFailedWithWrongOwnership() external {
        vm.expectRevert();
        s_fn.transferNft(s_minter, 0);
    }

    function testTransferNftFailedWithWrongToAddress() external {
        uint256 mintPrice = s_config.getParams()._mintPrice;
        uint256 firstTokenId = s_fn.tokenIdMinted();

        vm.prank(s_minter);
        s_fn.mintNft{value: mintPrice}();

        vm.prank(s_minter);
        vm.expectRevert();
        s_fn.transferNft(address(0), firstTokenId);
    }

    function testTransferNftFailedWithReceiverAddressNotImplementingOnERC721ReceivedFunc()
        external
    {
        uint256 mintPrice = s_config.getParams()._mintPrice;
        uint256 firstTokenId = s_fn.tokenIdMinted();

        vm.prank(s_minter);
        s_fn.mintNft{value: mintPrice}();

        vm.prank(s_minter);
        vm.expectRevert();
        s_fn.transferNft(address(this), firstTokenId);
    }

    function testTransferNftSucceed() external {
        address receiverAddress = makeAddr("addr0");

        uint256 mintPrice = s_config.getParams()._mintPrice;
        uint256 firstTokenId = s_fn.tokenIdMinted();

        vm.prank(s_minter);
        s_fn.mintNft{value: mintPrice}();
        address olderOwner = s_fn.ownerOf(firstTokenId);

        vm.prank(s_minter);
        s_fn.transferNft(receiverAddress, firstTokenId);

        address newOwner = s_fn.ownerOf(firstTokenId);
        assert(newOwner == receiverAddress);
        assert(olderOwner != newOwner);
    }

    function testTransferNftFromFailedWithNoApprovalGiven() external {
        address receiverAddress = makeAddr("addr0");
        uint256 mintPrice = s_config.getParams()._mintPrice;
        uint256 firstTokenId = s_fn.tokenIdMinted();

        vm.prank(s_minter);
        s_fn.mintNft{value: mintPrice}();

        vm.expectRevert();
        s_fn.transferNftFrom(s_minter, receiverAddress, firstTokenId, "");
    }

    function testTransferNftFromSucceed() external {
        address receiverAddress = makeAddr("addr0");
        uint256 mintPrice = s_config.getParams()._mintPrice;
        uint256 firstTokenId = s_fn.tokenIdMinted();

        vm.prank(s_minter);
        s_fn.mintNft{value: mintPrice}();
        address oldOwner = s_fn.ownerOf(firstTokenId);

        vm.prank(s_minter);
        s_fn.approve(address(this), firstTokenId);

        s_fn.transferNftFrom(s_minter, receiverAddress, firstTokenId, "");
        address newOwner = s_fn.ownerOf(firstTokenId);

        assert(newOwner == receiverAddress);
        assert(oldOwner != newOwner);
    }

    function testUpdateTokenIdLimitFailedWith__WrongCaller() external {
        uint256 newLimit = 10;

        vm.expectRevert(FirstNft.FirstNft__WrongCaller.selector);
        s_fn.updateTokenIdLimit(newLimit);
    }

    function testUpdateTokenIdLimitSucceed() external {
        uint256 oldLimit = s_fn.tokenIdLimit();

        uint256 newLimit = 10;

        vm.prank(DEFAULT_BROADCASTER);
        s_fn.updateTokenIdLimit(newLimit);

        uint256 newTokenIdLimit = s_fn.tokenIdLimit();
        assert(oldLimit != newLimit);
        assert(newTokenIdLimit == newLimit);
    }

    function testBurnFailedWith__WrongCaller() external {
        uint256 mintPrice = s_config.getParams()._mintPrice;
        uint256 firstTokenId = s_fn.tokenIdMinted();

        vm.prank(s_minter);
        s_fn.mintNft{value: mintPrice}();

        address owner = s_fn.ownerOf(firstTokenId);
        assert(owner == s_minter);

        vm.expectRevert();
        s_fn.burnNft(firstTokenId);
    }

    function testBurnSucceed() external {
        uint256 mintPrice = s_config.getParams()._mintPrice;
        uint256 firstTokenId = s_fn.tokenIdMinted();

        vm.prank(s_minter);
        s_fn.mintNft{value: mintPrice}();

        address owner = s_fn.ownerOf(firstTokenId);
        assert(owner == s_minter);

        vm.prank(s_minter);
        s_fn.burnNft(firstTokenId);

        vm.expectRevert();
        s_fn.ownerOf(firstTokenId);
    }

    function testGetTokenUriFailedWithIdDoesntExist() external {
        uint256 mintPrice = s_config.getParams()._mintPrice;
        uint256 firstTokenId = s_fn.tokenIdMinted();

        vm.prank(s_minter);
        s_fn.mintNft{value: mintPrice}();

        address owner = s_fn.ownerOf(firstTokenId);
        assert(owner == s_minter);

        vm.expectRevert();
        s_fn.tokenURI(firstTokenId + 1);
    }

    function testGetTokenUriPassed() external {
        uint256 mintPrice = s_config.getParams()._mintPrice;
        uint256 firstTokenId = s_fn.tokenIdMinted();

        vm.prank(s_minter);
        s_fn.mintNft{value: mintPrice}();

        address owner = s_fn.ownerOf(firstTokenId);
        assert(owner == s_minter);

        string memory uri = s_fn.tokenURI(firstTokenId);
        console.log("URI is : ", uri);

        string memory expectedUri = string(
            abi.encodePacked(
                s_config.getParams()._baseUri,
                firstTokenId.toString()
            )
        );

        assert(
            keccak256(abi.encodePacked(uri)) ==
                keccak256(abi.encodePacked(expectedUri))
        );
    }
}
