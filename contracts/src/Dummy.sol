// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Dummy {
    event Called();

    function aiClaim() public {
        emit Called();
    }
}
