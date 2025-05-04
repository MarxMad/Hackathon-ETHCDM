// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Whitelist {
    mapping(address => bool) public whitelist;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Whitelist: Solo el dueno puede ejecutar");
        _;
    }

    function addAddress(address _direccion) external onlyOwner {
        whitelist[_direccion] = true;
    }

    function removeAddress(address _direccion) external onlyOwner {
        whitelist[_direccion] = false;
    }
}