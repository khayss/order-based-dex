// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TestERC20 is ERC20, Ownable {
    constructor(
        address _initialOwner
    ) ERC20("TestERC20", "TEST") Ownable(_initialOwner) {
        _mint(_initialOwner, 1000000000000000000000000);
    }
}
