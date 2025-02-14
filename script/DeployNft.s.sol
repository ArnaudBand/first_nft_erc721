// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {NFT} from "../src/NFT.sol";

contract DeployNFT is Script {
    uint256 deploperPrivateKey = vm.envUint("PRIVATE_KEY");
    NFT public nft;

    function run() external returns (NFT) {
        vm.startBroadcast(deploperPrivateKey);
        nft = new NFT("MEME NFT", "MN");
        vm.stopBroadcast();

        return nft;
    }
}
