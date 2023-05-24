// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "hardhat/console.sol";

contract NameService is OwnableUpgradeable {
    uint private constant MAX_DOMAIN_LENGTH = 32;
    uint private constant MIN_DOMAIN_LENGTH = 8;
    mapping(string => address) private ownerToDomain;
    mapping (address => string) private domainToOwner;

    function registry(string memory domain) public {
        console.log("domain:", domain,  ", length:", countCharacters(domain));
        require(bytes(domain).length <= MAX_DOMAIN_LENGTH, "Domain name too long");
        require(bytes(domain).length >= MIN_DOMAIN_LENGTH, "Domain name too short");
        require(bytes(domainToOwner[msg.sender]).length == 0, "This wallet address is already registered");
        ownerToDomain[domain] = _msgSender();
        domainToOwner[msg.sender] = domain;
    }

    function available(string memory domain) public view returns (bool) {
        return ownerToDomain[domain] == address(0);
    }

    function getOwner(string memory domain) public view returns (address) {
        return ownerToDomain[domain];
    }

    function getOwnedAddress() public view returns (string memory) {
        return domainToOwner[_msgSender()];
    }

    function getUserOwnedAddress(address _user) public view returns (string memory) {
        return domainToOwner[_user];
    }

    function countCharacters(string memory str) private pure returns (uint) {
        bytes memory strBytes = bytes(str);
        uint count = 0;
        for (uint i = 0; i < strBytes.length; i++) {
            if ((strBytes[i] & 0xC0) != 0x80) {
                count++;
            }
        }
        return count;
    }
}
