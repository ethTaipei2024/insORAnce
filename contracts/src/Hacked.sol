// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Hacked {
    uint256 public balance;

    function setBalance(uint256 _balance) public {
        balance = _balance;
    }
}
