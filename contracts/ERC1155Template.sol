// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "hardhat/console.sol";

contract ERC1155Template is ERC1155Upgradeable, OwnableUpgradeable {
    mapping(address => bool) private reward1MintedAddresses;
    using ECDSAUpgradeable for bytes32;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    address private rewardManager;
    EnumerableSetUpgradeable.UintSet private tokenIdSet;

    // set base info
    function initialize(string memory uri) public initializer {
        __ERC1155_init(uri);
        __Ownable_init();
        console.log("initialize", uri);
    }

    function mint(address user, uint256 id, uint256 amount) onlyOwner public {
        tokenIdSet.add(id);
        _mint(user, id, amount, "");
    }

    function mintForUser(address user, uint256 id, uint256 amount) private {
        tokenIdSet.add(id);
        _mint(user, id, amount, "");
    }

    function balanceBatch() view public returns(uint256[] memory, uint256[] memory) {
        uint256[] memory tokenIdList = tokenIdSet.values();
        uint256[] memory balanceList = new uint256[](tokenIdList.length);
        for (uint256 i = 0; i < tokenIdList.length; i++) {
            balanceList[i] = balanceOf(_msgSender(), tokenIdList[i]);
        }
        return (tokenIdList, balanceList);
    }

    function reward1(bytes memory signature, uint256 timestamp) public returns(uint256){
        console.log("timestamp", timestamp);
        console.log("block.timestamp", block.timestamp);
        console.log("rewardManager", rewardManager);
        // only one
        require(!reward1MintedAddresses[_msgSender()], "This address has already been minted");
        // 10min expire
        require((block.timestamp - timestamp) < 60 * 10, "signature expire");
        // get expect message hash
        require(verify(keccak256(abi.encodePacked(_msgSender(), timestamp, block.chainid)), signature, rewardManager), "invalid signature");

        reward1MintedAddresses[_msgSender()] = true;
        mintForUser(_msgSender(), 1, 1);
        return 1;
    }

    function reward1Available() public view returns (bool) {
        return !reward1MintedAddresses[_msgSender()];
    }

    function verify(bytes32 data, bytes memory signature, address user) private pure returns (bool) {
        return user == data
        .toEthSignedMessageHash()
        .recover(signature);
    }

    function setRewardManager(address _manager) public onlyOwner {
        rewardManager = _manager;
    }

    function setURI(string memory _uri) public onlyOwner {
        _setURI(_uri);
    }
}
