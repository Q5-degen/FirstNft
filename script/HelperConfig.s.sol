//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HelperConfig {
    Params private s_params;

    string private constant NAME = "Fist Nft";
    string private constant SYMBOL = "FN";
    string private constant URI = ""; // dont forget to add URI here
    uint256 private constant MINT_PRICE = 1e15;
    uint256 private constant TOKEN_ID_LIMIT = 3;

    struct Params {
        string _name;
        string _symbol;
        uint256 _mintPrice;
        string _baseUri;
        uint256 _tokenIdLimit;
    }

    constructor() {
        if (block.chainid == 11155111) {
            s_params = whenOnSepolia();
        }
    }

    function whenOnSepolia() private pure returns (Params memory _params) {
        _params = Params({
            _name: NAME,
            _symbol: SYMBOL,
            _mintPrice: MINT_PRICE,
            _baseUri: URI,
            _tokenIdLimit: TOKEN_ID_LIMIT
        });
    }

    function getParams() external view returns (Params memory _params) {
        _params = s_params;
    }
}
