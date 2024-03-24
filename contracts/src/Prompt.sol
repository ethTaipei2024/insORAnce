// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Prompt {
    string public opening =
        "As part of InsORAnce, a leading DeFi insurance protocol, you are tasked with evaluating insurance claims against our cover terms. Our goal is to support DeFi users by offering a safety net against losses due to security breaches in their chosen protocols.\n**Scenario for Evaluation:**";
    string public roleDescription =
        "You are a decision-maker assessing the validity of User As claim and determining appropriate compensation based on our general and specific cover terms.";
    string public taskDescription =
        "**Questions:**\n1. Should we extend coverage to User A? (Yes/No)\n2. If yes, what should be the compensation amount for User A? (Provide amount without the dollar sign or unit)\n3. Justify your decision based on the information and cover terms provided.\n**Expected Response Format:**\n```\nYes;Amount;Explanation...\n```\n**Note:** Use semicolons (;) to separate your answers and avoid using commas or currency symbols in the compensation amount.\n```\n";

    function genPrompt(string memory description, uint256 coverage, uint256 lossPercentage, uint256 blockTimestamp)
        public
        returns (bytes memory)
    {
        return abi.encode(
            opening,
            roleDescription,
            taskDescription,
            "\nproject description\n",
            description,
            "\ncoverage\n",
            coverage,
            "\nlossPercentage\n",
            lossPercentage,
            "\nblockTimestamp\n",
            blockTimestamp
        );
    }
}
