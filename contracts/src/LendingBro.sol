// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract LendingBro {
    uint256 public balance;

    function setBalance(uint256 _balance) public {
        balance = _balance;
    }
}
