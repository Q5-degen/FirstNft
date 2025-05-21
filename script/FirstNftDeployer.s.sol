// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {FirstNft} from "../src/FirstNft.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FirstNftDeployer is Script {
    function run() external returns (FirstNft _fn, HelperConfig _config) {
        _config = new HelperConfig();
        HelperConfig.Params memory params = _config.getParams();

        vm.startBroadcast();
        _fn = new FirstNft(
            params._name,
            params._symbol,
            params._mintPrice,
            params._baseUri,
            params._tokenIdLimit
        );
        vm.stopBroadcast();
    }
}
