// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AIOracleCallbackReceiver} from "./AIOracleCallbackReceiver.sol";
import {IAIOracle} from "./interfaces/IAIOracle.sol";
import {IPrompt} from "./interfaces/IPrompt.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract InsORAnce is AIOracleCallbackReceiver, Ownable {
    struct InsuranceTerm {
        uint256 premium;
        uint256 coverage;
        string description;
        uint256 totalFunded;
        uint256 fundingLockTime;
        uint256 requestId;
    }

    struct ClaimRequest {
        bytes32 termId;
        uint256 lossPercentage;
        bytes output;
        uint256 incidentTimestamp;
    }

    address public zkAutomation;
    uint64 public constant AIORACLE_CALLBACK_GAS_LIMIT = 5000000;
    IPrompt public promptGenerator;
    mapping(bytes32 => InsuranceTerm) public insuranceTerms;
    mapping(bytes32 => mapping(address => bool)) public insurancePurchased;
    mapping(bytes32 => uint256) public insuredUnits;
    mapping(bytes32 => mapping(address => bool)) public insuranceClaimed;
    mapping(address => mapping(bytes32 => uint256)) public fundsByFunder;
    mapping(bytes32 => address[]) public fundersByTerm;
    mapping(bytes32 => uint256) public claimPercentage;
    mapping(address => uint256) public pendingWithdrawals;
    mapping(uint256 => ClaimRequest) public requests;

    event InsuranceTermAdded(bytes32 indexed termId, uint256 premium, uint256 coverage, string description);
    event InsurancePurchased(address indexed insured, bytes32 indexed termId, uint256 period);
    event InsuranceFunded(bytes32 indexed termId, uint256 amount, address indexed funder, uint256 lockTime);
    event WithdrawalAvailable(bytes32 indexed termId, address indexed funder, uint256 amount);
    event ClaimInitiated(bytes32 indexed termId, uint256 indexed lossPercentage, uint256 incidentTimestamp);
    event ClaimDecisionRecorded(uint256 requestId, bytes32 indexed termId, bool approved, uint256 percentage);

    modifier onlyZKAutomation() {
        require(msg.sender == zkAutomation, "only zkAutomation");
        _;
    }

    modifier onlyAIOracle() {
        require(msg.sender == address(aiOracle), "Caller is not the AI Oracle");
        _;
    }

    constructor(IAIOracle _aiOracle, IPrompt _prompt) AIOracleCallbackReceiver(_aiOracle) Ownable(msg.sender) {
        promptGenerator = _prompt;
    }

    function setZKAutomation(address _zkAutomation) external onlyOwner {
        zkAutomation = _zkAutomation;
    }

    function addInsuranceTerms(
        bytes32 termId,
        uint256 premium,
        uint256 coverage,
        uint256 period,
        string calldata description
    ) external {
        require(insuranceTerms[termId].coverage == 0, "Term already exists");
        insuranceTerms[termId] = InsuranceTerm({
            premium: premium,
            coverage: coverage,
            description: description,
            totalFunded: 0,
            fundingLockTime: block.timestamp + period,
            requestId: 0
        });
        emit InsuranceTermAdded(termId, premium, coverage, description);
    }

    function buyInsurance(bytes32 termId, uint256 period) external payable {
        InsuranceTerm storage term = insuranceTerms[termId];
        require(msg.value == term.premium, "Incorrect premium amount");
        insurancePurchased[termId][msg.sender] = true;
        insuredUnits[termId] += 1;
        emit InsurancePurchased(msg.sender, termId, period);
    }

    function fundTerm(bytes32 termId) external payable {
        require(msg.value > 0, "Funding amount must be greater than 0");
        InsuranceTerm storage term = insuranceTerms[termId];
        require(block.timestamp <= term.fundingLockTime, "Funding period has ended");
        term.totalFunded += msg.value;
        fundsByFunder[msg.sender][termId] += msg.value;
        fundersByTerm[termId].push(msg.sender);
        emit InsuranceFunded(termId, msg.value, msg.sender, term.fundingLockTime);
    }

    function unfundTerm(bytes32 termId) external {
        require(block.timestamp > insuranceTerms[termId].fundingLockTime, "Funding lock period not yet ended");
        uint256 amountToWithdraw = fundsByFunder[msg.sender][termId];
        require(amountToWithdraw > 0, "No funds to withdraw");
        require(claimPercentage[termId] == 0, "Claim on the term has been processed");

        fundsByFunder[msg.sender][termId] = 0;
        pendingWithdrawals[msg.sender] += amountToWithdraw;
        emit WithdrawalAvailable(termId, msg.sender, amountToWithdraw);
    }

    function aiClaim(bytes32 termId, uint256 lossPercentage, uint256 blockTimestamp) external /*onlyZKAutomation*/ {
        bytes memory prompt = promptGenerator.genPrompt(
            insuranceTerms[termId].description, insuranceTerms[termId].coverage, lossPercentage, blockTimestamp
        );
        aiOracle.requestCallback(
            1, prompt, address(this), AIORACLE_CALLBACK_GAS_LIMIT, abi.encode(lossPercentage, termId, blockTimestamp)
        );

        emit ClaimInitiated(termId, lossPercentage, blockTimestamp);
    }

    function decompose(string calldata result) internal pure returns (bool, uint256) {
        // Decompose the result
        return (true, 100);
    }

    function aiOracleCallback(uint256 requestId, bytes calldata output, bytes calldata callbackData)
        external
        override
        onlyAIOracleCallback
    {
        (uint256 lossPercentage, bytes32 termId, uint256 incidentTimestamp) =
            abi.decode(callbackData, (uint256, bytes32, uint256));
        ClaimRequest storage request = requests[requestId];
        request.output = output;
        request.termId = termId;
        request.lossPercentage = lossPercentage;
        request.incidentTimestamp = incidentTimestamp;
        string calldata result = string(output);
        (bool approved, uint256 percentage) = decompose(result);
        InsuranceTerm storage term = insuranceTerms[termId];
        term.requestId = requestId;

        require(term.coverage != 0, "Term does not exist");
        require(block.timestamp <= term.fundingLockTime, "Funding lock period has not ended");

        if (approved) {
            claimPercentage[termId] = percentage;
        } else {
            claimPercentage[termId] = 0;
        }
        emit ClaimDecisionRecorded(requestId, termId, approved, percentage);
    }

    function claimPayout(bytes32 termId) external {
        require(insurancePurchased[termId][msg.sender], "User has not purchased insurance for this term");
        require(insuranceClaimed[termId][msg.sender] == false, "User has already claimed insurance for this term");
        require(
            insuranceTerms[termId].requestId != 0 && aiOracle.isFinalized(insuranceTerms[termId].requestId),
            "Claim has not been finalized yet"
        );
        uint256 payoutPercentage = claimPercentage[termId];
        require(payoutPercentage > 0, "No payout available for this term");

        uint256 payout = insuranceTerms[termId].coverage * payoutPercentage / 100;
        if (insuranceTerms[termId].totalFunded < (payout * insuredUnits[termId])) {
            payout = insuranceTerms[termId].totalFunded / insuredUnits[termId];
        }
        require(insuranceTerms[termId].totalFunded > payout, "No funds available for payout");
        insuranceClaimed[termId][msg.sender] = true;
        pendingWithdrawals[msg.sender] += payout;
    }

    function userWithdraw() external {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds available for withdrawal");
        pendingWithdrawals[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
    }
}
