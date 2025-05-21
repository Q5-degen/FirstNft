//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FirstNft} from "../src/FirstNft.sol";
import {console} from "forge-std/console.sol";

/**
 * @custom:globalscriptnotice
 * =================================================================================================
 * IMPORTANT NOTES FOR ALL INTERACTION SCRIPTS BELOW
 * =================================================================================================
 * This file contains multiple Foundry script contracts designed to interact with the `FirstNft`
 * contract. Please review the following general guidelines before using or modifying these scripts:
 *
 * 1. PLACEHOLDER CONSTANTS (MUST BE MODIFIED):
 * ---------------------------------------------
 * Each script contract (e.g., `MintNft`, `TransferNft`, `Approve`, `UpdateTokenIdLimit`, `BurnNft`, `TokenUri`)
 * defines `private constant` variables (like `AMOUNT`, `TO`, `ID`, `FROM`, `TOKEN_ID`, `APPROVER`, `LIMIT`, `BURNER`, etc.).
 *
 * @dev Critical Action Required: These constant values are **placeholders for demonstration and testing purposes only**.
 * You **MUST** review and modify these constants within each script to reflect your specific testing scenario,
 * target contract state, deployed addresses, token IDs, desired amounts, and intended signers.
 * Using default zero addresses or incorrect values will likely lead to transaction failures or unintended outcomes.
 *
 * 2. TRANSACTION BROADCASTING (`vm.startBroadcast`):
 * -------------------------------------------------
 * These scripts use Foundry's cheatcodes `vm.startBroadcast()` and `vm.startBroadcast(address signer)`
 * to simulate or send transactions. Understanding the sender (broadcasting address) is crucial:
 *
 * a. `vm.startBroadcast()` (no arguments specified to `startBroadcast`):
 * The address used to broadcast the transaction (i.e., `msg.sender` in the target contract call)
 * is determined by Foundry in the following order of precedence:
 * 1. If the `--sender` CLI argument was provided when running `forge script`, that address is used.
 * 2. If exactly one signer (e.g., private key via `--private-key`, hardware wallet via `--ledger`/`--trezor`, or a configured keystore)
 * is active when `forge script` is invoked, that signer's address is used.
 * 3. Otherwise, Foundry's default sender address (0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38) is used.
 *
 * b. `vm.startBroadcast(address signer)` (an address is passed to `startBroadcast`):
 * The transaction is broadcast as if it originated directly from the `signer` address provided
 * as an argument to `vm.startBroadcast()`. This is used in scripts like `Approve` and `BurnNft`
 * where the `msg.sender` for the target contract function needs to be a specific token owner
 * (the `APPROVER` or `BURNER` constant in those scripts).
 *
 * @dev Ensure the broadcasting address has the necessary permissions (e.g., ownership of an NFT for `approve` or `burnNft`,
 * developer role for `updateTokenIdLimit`) and funds (for `mintNft`) for the transaction to succeed.
 *
 * General Advice:
 * ---------------
 * Always review the specific logic and constant values within each script contract before execution
 * to ensure it aligns with your intended actions on the `FirstNft` contract.
 * =================================================================================================
 */

contract MintNft is Script {
    uint256 private constant AMOUNT = 1e15;

    function mint(address _fnAddr, uint256 _amount) public {
        FirstNft fn = FirstNft(payable(_fnAddr));

        vm.startBroadcast();
        fn.mintNft{value: _amount}();
        vm.stopBroadcast();
    }

    function run() external {
        address fnAddress = DevOpsTools.get_most_recent_deployment(
            "FirstNft",
            block.chainid
        );

        mint(fnAddress, AMOUNT);
    }
}

contract TransferNft is Script {
    address private constant TO = address(0);
    uint256 private constant ID = 2;

    function transfer(address _fnAddr, address _to, uint256 _tokenId) public {
        FirstNft fn = FirstNft(payable(_fnAddr));

        vm.startBroadcast();
        fn.transferNft(_to, _tokenId);
        vm.stopBroadcast();
    }

    function run() external {
        address fnAddress = DevOpsTools.get_most_recent_deployment(
            "FirstNft",
            block.chainid
        );

        transfer(fnAddress, TO, ID);
    }
}

contract TransferNftFrom is Script {
    address private constant FROM = address(0);
    bytes private constant DATA = "";
    address private constant TO = address(0);
    uint256 private constant ID = 1;

    function transferFrom(
        address _fnAddr,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public {
        FirstNft fn = FirstNft(payable(_fnAddr));

        vm.startBroadcast();
        fn.transferNftFrom(_from, _to, _tokenId, _data);
        vm.stopBroadcast();
    }

    function run() external {
        address fnAddress = DevOpsTools.get_most_recent_deployment(
            "FirstNft",
            block.chainid
        );

        transferFrom(fnAddress, FROM, TO, ID, DATA);
    }
}

contract Approve is Script {
    address private constant TO = address(0);
    uint256 private constant TOKEN_ID = 1;
    address private constant APPROVER = address(0);

    function approve(
        address _fnAddr,
        address _to,
        uint256 _tokenId,
        address _approverAddr
    ) public {
        FirstNft fn = FirstNft(payable(_fnAddr));

        vm.startBroadcast(_approverAddr);
        fn.approve(_to, _tokenId);
        vm.stopBroadcast();
    }

    function run() external {
        address fnAddress = DevOpsTools.get_most_recent_deployment(
            "FirstNft",
            block.chainid
        );

        approve(fnAddress, TO, TOKEN_ID, APPROVER);
    }
}

contract UpdateTokenIdLimit is Script {
    uint256 private constant LIMIT = 4;

    function update(address _fnAddr, uint256 _newLimit) public {
        FirstNft fn = FirstNft(payable(_fnAddr));

        vm.startBroadcast();
        fn.updateTokenIdLimit(_newLimit);
        vm.stopBroadcast();
    }

    function run() external {
        address fnAddress = DevOpsTools.get_most_recent_deployment(
            "FirstNft",
            block.chainid
        );

        update(fnAddress, LIMIT);
    }
}

contract BurnNft is Script {
    uint256 private constant ID = 0;
    address private constant BURNER = address(0);

    function burn(address _fnAddr, uint256 _tokenId, address _burner) public {
        FirstNft fn = FirstNft(payable(_fnAddr));

        vm.startBroadcast(_burner);
        fn.burnNft(_tokenId);
        vm.stopBroadcast();
    }

    function run() external {
        address fnAddress = DevOpsTools.get_most_recent_deployment(
            "FirstNft",
            block.chainid
        );

        burn(fnAddress, ID, BURNER);
    }
}

contract TokenUri is Script {
    uint256 private constant ID = 1;

    function uri(
        address _fnAddr,
        uint256 _tokenId
    ) public returns (string memory _uriString) {
        FirstNft fn = FirstNft(payable(_fnAddr));

        vm.startBroadcast();
        _uriString = fn.tokenURI(_tokenId);
        vm.stopBroadcast();

        console.log("URI is : ", _uriString);
    }

    function run() external {
        address fnAddress = DevOpsTools.get_most_recent_deployment(
            "FirstNft",
            block.chainid
        );

        uri(fnAddress, ID);
    }
}
