// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CreditScore {
    // --- Structs ---
    struct Borrower {
        string nid; // National ID or unique identifier
        string name;
        uint8 accountBalanceScore; // Score (0-100) for Account Balance category
        uint8 paymentHistoryScore; // Score (0-100) for Payment History category
        uint8 totalTransactionsScore; // Score (0-100) for Total Transactions category
        uint8 totalRemainingLoanScore; // Score (0-100) for Total Remaining Loan category
        uint8 creditAgeScore; // Score (0-100) for Credit Age category
        uint8 professionalRiskFactorScore; // Score (0-100) for Professional Risk Factor category
        uint8 finalCreditScore; // The calculated final credit score (0-100)
        bool exists;
    }

    // --- State Variables ---
    mapping(string => Borrower) public borrowers; // nid => Borrower data

    // --- Weights for Scoring Categories ---
    uint8 public constant WEIGHT_ACCOUNT_BALANCE = 25;
    uint8 public constant WEIGHT_PAYMENT_HISTORY = 30;
    uint8 public constant WEIGHT_TOTAL_TRANSACTIONS = 15;
    uint8 public constant WEIGHT_TOTAL_REMAINING_LOAN = 10;
    uint8 public constant WEIGHT_CREDIT_AGE = 10;
    uint8 public constant WEIGHT_PROFESSIONAL_RISK = 10;

    // --- Events ---
    event BorrowerAdded(string indexed nid, string name, uint8 finalCreditScore);
    event BorrowerUpdated(string indexed nid, uint8 newFinalCreditScore);

    // --- Functions ---
    function addOrUpdateBorrower(
        string memory _nid,
        string memory _name,
        uint8 _accountBalanceScore,
        uint8 _paymentHistoryScore,
        uint8 _totalTransactionsScore,
        uint8 _totalRemainingLoanScore,
        uint8 _creditAgeScore,
        uint8 _professionalRiskFactorScore
    ) public {
        require(bytes(_nid).length > 0, "NID cannot be empty");
        // Input validation
        require(_accountBalanceScore <= 100 && _paymentHistoryScore <= 100 && _totalTransactionsScore <= 100 && _totalRemainingLoanScore <= 100 && _creditAgeScore <= 100 && _professionalRiskFactorScore <= 100, "Scores must be between 0 and 100");

        Borrower storage borrower = borrowers[_nid];
        bool wasExisting = borrower.exists;

        borrower.nid = _nid;
        borrower.name = _name;
        borrower.accountBalanceScore = _accountBalanceScore;
        borrower.paymentHistoryScore = _paymentHistoryScore;
        borrower.totalTransactionsScore = _totalTransactionsScore;
        borrower.totalRemainingLoanScore = _totalRemainingLoanScore;
        borrower.creditAgeScore = _creditAgeScore;
        borrower.professionalRiskFactorScore = _professionalRiskFactorScore;
        
        borrower.finalCreditScore = _calculateFinalCreditScore(borrower);
        borrower.exists = true;

        if (wasExisting) {
            emit BorrowerUpdated(_nid, borrower.finalCreditScore);
        } else {
            emit BorrowerAdded(_nid, _name, borrower.finalCreditScore);
        }
    }

    function _calculateFinalCreditScore(Borrower memory _borrower) internal pure returns (uint8) {
        uint256 weightedScore = 0;
        weightedScore += uint256(_borrower.accountBalanceScore) * WEIGHT_ACCOUNT_BALANCE;
        weightedScore += uint256(_borrower.paymentHistoryScore) * WEIGHT_PAYMENT_HISTORY;
        weightedScore += uint256(_borrower.totalTransactionsScore) * WEIGHT_TOTAL_TRANSACTIONS;
        weightedScore += uint256(_borrower.totalRemainingLoanScore) * WEIGHT_TOTAL_REMAINING_LOAN;
        weightedScore += uint256(_borrower.creditAgeScore) * WEIGHT_CREDIT_AGE;
        weightedScore += uint256(_borrower.professionalRiskFactorScore) * WEIGHT_PROFESSIONAL_RISK;
        return uint8(weightedScore / 100);
    }

    function getBorrowerDetails(string memory _nid) public view returns (Borrower memory) {
        require(borrowers[_nid].exists, "Borrower does not exist");
        return borrowers[_nid];
    }
}
