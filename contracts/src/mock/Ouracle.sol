pragma solidity ^0.8.13;

import {IAIOracle} from "../interfaces/IAIOracle.sol";

contract Ouracle is IAIOracle {
    uint256 public gasPrice;
    bytes4 public constant callbackFunctionSelector = 0xb0347814;
    uint256 public currentRequestId = 0;
    string public constant mockOutput = "mock output";

    function requestCallback(
        uint256 modelId,
        bytes memory input,
        address callbackContract,
        uint64 gasLimit,
        bytes memory callbackData
    ) external payable returns (uint256) {
        currentRequestId++;
        // invoke callback
        if (callbackContract != address(0)) {
            bytes memory payload =
                abi.encodeWithSelector(callbackFunctionSelector, currentRequestId, abi.encode(mockOutput), callbackData);
            (bool success, bytes memory data) = callbackContract.call{gas: gasLimit}(payload);
            require(success, "failed to call selector");
            if (!success) {
                assembly {
                    revert(add(data, 32), mload(data))
                }
            }
        }
        return currentRequestId;
    }

    function estimateFee(uint256 modelId, uint256 gasLimit) external view returns (uint256) {
        return gasPrice * gasLimit;
    }

    function isFinalized(uint256 requestId) external view returns (bool) {
        return true;
    }
}
