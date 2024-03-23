// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {AIOracleCallbackReceiver} from "./AIOracleCallbackReceiver.sol";
import {IAIOracle} from "./IAIOracle.sol";


contract InsORAnce is AIOracleCallbackReceiver {
    struct InsuranceTerm {
        uint256 premium;
        uint256 coverage;
        string description;
        uint256 totalFunded;
        uint256 fundingLockTime;
    }

    IzkAutomation public zkAutomation;

    mapping(bytes32 => InsuranceTerm) public insuranceTerms;
    mapping(address => mapping(bytes32 => uint256)) public fundsByFunder;
    mapping(bytes32 => address[]) public fundersByTerm;
    mapping(bytes32 => uint256) public claimPayouts;
    mapping(address => uint256) public pendingWithdrawals;

    event InsuranceTermAdded(bytes32 indexed termId, uint256 premium, uint256 coverage, string description);
    event InsurancePurchased(address indexed insured, bytes32 indexed termId, uint256 period);
    event InsuranceFunded(bytes32 indexed termId, uint256 amount, address indexed funder, uint256 lockTime);
    event WithdrawalAvailable(bytes32 indexed termId, address indexed funder, uint256 amount);
    event ClaimInitiated(bytes32 indexed termId, address indexed claimant);
    event ClaimProcessed(uint256 requestId, bytes32 indexed termId, bool approved, uint256 payoutAmount);

    constructor(IAIOracle _aiOracle, address _zkGraph) AIOracleCallbackReceiver(_aiOracle) {
        zkGraph = _zkGraph;
    }

    modifier onlyAIOracle {
        require(msg.sender == address(aiOracle), "Caller is not the AI Oracle");
        _;
    }

    function addInsuranceTerms(bytes32 termId, uint256 premium, uint256 coverage, string calldata description) external {
        require(insuranceTerms[termId].coverage == 0, "Term already exists");
        insuranceTerms[termId] = InsuranceTerm({
            premium: premium,
            coverage: coverage,
            description: description,
            totalFunded: 0,
            fundingLockTime: 0
        });
        emit InsuranceTermAdded(termId, premium, coverage, description);
    }

    function buyInsurance(bytes32 termId, uint256 period) external payable {
        InsuranceTerm storage term = insuranceTerms[termId];
        require(msg.value == term.premium, "Incorrect premium amount");
        term.fundingLockTime = block.timestamp + period;
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

    function withdraw(bytes32 termId) external {
        require(block.timestamp > insuranceTerms[termId].fundingLockTime, "Funding lock period not yet ended");
        uint256 amountToWithdraw = fundsByFunder[msg.sender][termId];
        require(amountToWithdraw > 0, "No funds to withdraw");
        require(claimPayouts[termId] == 0, "Claim on the term has been processed");

        fundsByFunder[msg.sender][termId] = 0;
        pendingWithdrawals[msg.sender] += amountToWithdraw;
        emit WithdrawalAvailable(termId, msg.sender, amountToWithdraw);
    }
	
	 address public zkGraph;
	
	    modifier onlyZkGraph() {
        require(msg.sender == zkGraph, "only zkGraph");
        _;
    }
    

    function aiClaim(bytes32 termId, address insured) external onlyZkGraph {
  
        string prompt = insuranceTerms[termId].term_description;
        bytes memory input = bytes(prompt);
        aiOracle.requestCallback(
            1, input, address(this), this.OAOCallback.selector, AIORACLE_CALLBACK_GAS_LIMIT
        );

        emit ClaimInitiated(termId, insured);
    }

    function OAOCallback(
        uint256 modelId,
        bytes calldata input,
        bytes calldata output
    ) external onlyAIOracleCallback {
		string calldata result = string(output);
        (bytes32 termId, bool approved, uint256 payoutAmount) = resolve_result(result);
        InsuranceTerm storage term = insuranceTerms[termId];
        require(term.coverage != 0, "Term does not exist");
        require(block.timestamp <= term.fundingLockTime, "Funding lock period has ended");
        
        if (approved) {
            claimPayouts[termId] = payoutAmount;
            term.totalFunded -= payoutAmount;
        } else {
            claimPayouts[termId] = 0;
        }
        emit ClaimProcessed(requestId, termId, approved, payoutAmount);
    }

    function claimPayout(bytes32 termId) external {
        uint256 payoutAmount = claimPayouts[termId];
        require(payoutAmount > 0, "No payout available for this term");
        pendingWithdrawals[msg.sender] += payoutAmount;
        claimPayouts[termId] = 0;
    }

    function userWithdrawal() external {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds available for withdrawal");
        pendingWithdrawals[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
    }
    
}

