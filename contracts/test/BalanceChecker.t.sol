// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/IConic.sol";
import "../src/IERC20.sol";

contract ContractBalanceChecker is Test {
    function testCheckBalanceAtBlock() public {
        // Exploit block 17740955; balance = 5699708354871225456;
        uint256 blockNumber = 17740955;
        address contractAddress = 0xBb787d6243a8D450659E09ea6fD82F1C859691e9;
        //address wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        address crvETHstETH = 0x06325440D014e39736583c165C2963BA99fAf14E;
        // Simulate the blockchain state at the given block number
        vm.roll(blockNumber);

        // Query the balance
        uint256 underlying = IConic(contractAddress).totalUnderlying();

        // Query the WETH balance
        uint256 underlying = IERC20(crvETHstETH).balanceOf(contractAddress);

        // Output the balance (for demonstration purposes, usually you'd assert something here)
        console2.log("Balance at block", blockNumber, "is", underlying);
    }
}
