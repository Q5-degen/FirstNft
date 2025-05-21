// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FirstNftDeployer} from "../../script/FirstNftDeployer.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {FirstNft} from "../../src/FirstNft.sol";
import {MintNft, TransferNft, TransferNftFrom, Approve, UpdateTokenIdLimit, BurnNft, TokenUri} from "../../script/Interactions.s.sol";

/**
 * @notice Make sure to set a value for constant variable `URI` in `HelperConfig.s.sol`
 * for testing to work here
 */
contract FirstNftTest is Test {
    FirstNft private s_fn;
    HelperConfig private s_config;
    FirstNftDeployer private s_fnd;
    MintNft private s_mint;
    TransferNft private s_transfer;
    TransferNftFrom private s_transferF;
    Approve private s_approve;
    UpdateTokenIdLimit private s_updateLimit;
    BurnNft private s_burn;
    TokenUri private s_uri;

    uint256 private constant FUND = 1 ether;
    address private DEFAULT_BROADCASTER =
        0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    function setUp() external {
        s_fnd = new FirstNftDeployer();
        s_mint = new MintNft();
        s_transfer = new TransferNft();
        s_transferF = new TransferNftFrom();
        s_approve = new Approve();
        s_updateLimit = new UpdateTokenIdLimit();
        s_burn = new BurnNft();
        s_uri = new TokenUri();
        (s_fn, s_config) = s_fnd.run();
    }

    function testMintPlusTransferPlusApprovePlusTransferFromPlusUpdateLimitPlusTokenUriPlusBurnNftSucceed()
        external
    {
        address receiverAddress0 = makeAddr("0");
        address receiverAddress1 = makeAddr("1");
        vm.deal(receiverAddress0, FUND);
        vm.deal(receiverAddress1, FUND);

        uint256 tokenIdToBeMinted = s_fn.tokenIdMinted();

        uint256 nftPrice = s_fn.mintPrice();
        s_mint.mint(address(s_fn), nftPrice);

        address oldOwner = s_fn.ownerOf(tokenIdToBeMinted);
        assert(DEFAULT_BROADCASTER == oldOwner);

        s_transfer.transfer(address(s_fn), receiverAddress0, tokenIdToBeMinted);
        address nextOwner = s_fn.ownerOf(tokenIdToBeMinted);
        assert(receiverAddress0 == nextOwner);

        s_approve.approve(
            address(s_fn),
            DEFAULT_BROADCASTER,
            tokenIdToBeMinted,
            receiverAddress0
        );
        s_transferF.transferFrom(
            address(s_fn),
            receiverAddress0,
            receiverAddress1,
            tokenIdToBeMinted,
            ""
        );
        address newOwner = s_fn.ownerOf(tokenIdToBeMinted);
        assert(receiverAddress1 == newOwner);

        uint256 newTokenIdLimit = 4;
        s_updateLimit.update(address(s_fn), newTokenIdLimit);
        uint256 expectedLimit = s_fn.tokenIdLimit();
        assert(expectedLimit == newTokenIdLimit);

        string memory stringUri = s_uri.uri(address(s_fn), tokenIdToBeMinted);
        assert(abi.encodePacked(stringUri).length > 0);

        s_burn.burn(address(s_fn), tokenIdToBeMinted, receiverAddress1);

        vm.expectRevert();
        s_fn.ownerOf(tokenIdToBeMinted);
    }
}
