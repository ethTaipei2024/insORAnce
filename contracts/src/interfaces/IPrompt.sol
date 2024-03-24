// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IPrompt {
    function genPrompt(string memory description, uint256 coverage, uint256 lossPercentage, uint256 blockTimestamp)
        external
        returns (bytes memory);
}
