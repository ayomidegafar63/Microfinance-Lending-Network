# Microfinance Lending Network

A decentralized microfinance platform built on Stacks blockchain that enables peer-to-peer lending through group formation, loan processing, and financial education tracking.

## System Overview

The Microfinance Lending Network consists of five interconnected smart contracts that work together to provide a complete microfinance solution:

### 1. Borrower Group Formation Contract (`borrower-groups.clar`)
- Creates and manages peer lending circles
- Handles group member registration and validation
- Tracks group formation status and member limits
- Manages group leadership and governance

### 2. Loan Application Processing Contract (`loan-applications.clar`)
- Processes loan applications from borrowers
- Evaluates basic creditworthiness criteria
- Manages application status and approval workflow
- Tracks loan application history

### 3. Repayment Tracking Contract (`repayment-tracking.clar`)
- Monitors loan repayment schedules
- Tracks payment history and defaults
- Calculates outstanding balances
- Manages repayment status updates

### 4. Interest Rate Calculation Contract (`interest-rates.clar`)
- Determines fair lending rates based on risk factors
- Manages base rates and risk multipliers
- Calculates personalized interest rates
- Tracks rate history and adjustments

### 5. Financial Literacy Education Contract (`financial-education.clar`)
- Tracks borrower training completion
- Manages educational course requirements
- Records certification status
- Links education completion to loan eligibility

## Key Features

- **Peer Lending Circles**: Form groups of 5-10 borrowers for mutual support
- **Credit Assessment**: Basic creditworthiness evaluation system
- **Flexible Repayment**: Multiple repayment schedule options
- **Dynamic Interest Rates**: Risk-based rate calculation
- **Education Integration**: Financial literacy requirements for borrowers
- **Transparent Tracking**: Complete audit trail of all transactions

## Contract Architecture

Each contract operates independently while maintaining data consistency through standardized data structures and validation rules.

### Data Flow
1. Borrowers complete financial education requirements
2. Form or join lending groups
3. Submit loan applications with group backing
4. Interest rates calculated based on risk profile
5. Approved loans tracked through repayment lifecycle

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Stacks wallet for deployment

### Installation

\`\`\`bash
git clone <repository-url>
cd microfinance-lending-network
npm install
\`\`\`

### Testing

\`\`\`bash
# Run all tests
npm test

# Run specific contract tests
npm test borrower-groups
npm test loan-applications
npm test repayment-tracking
npm test interest-rates
npm test financial-education
\`\`\`

### Deployment

\`\`\`bash
# Check contracts
clarinet check

# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
\`\`\`

## Contract Functions

### Borrower Groups
- `create-group`: Form new lending circle
- `join-group`: Add member to existing group
- `get-group-info`: Retrieve group details
- `update-group-status`: Modify group state

### Loan Applications
- `submit-application`: Create new loan request
- `process-application`: Evaluate and approve/reject
- `get-application`: Retrieve application details
- `update-application-status`: Modify application state

### Repayment Tracking
- `record-payment`: Log loan payment
- `calculate-balance`: Get outstanding amount
- `get-payment-history`: Retrieve payment records
- `mark-default`: Flag defaulted loans

### Interest Rates
- `calculate-rate`: Determine borrower's rate
- `update-base-rate`: Modify system base rate
- `get-rate-history`: Retrieve rate changes
- `apply-risk-factors`: Adjust rates for risk

### Financial Education
- `complete-course`: Mark course completion
- `verify-certification`: Check education status
- `get-education-record`: Retrieve training history
- `update-requirements`: Modify education criteria

## Security Considerations

- All functions include proper access controls
- Input validation prevents malicious data
- State changes are atomic and consistent
- Error handling provides clear feedback

## Contributing

1. Fork the repository
2. Create feature branch
3. Add comprehensive tests
4. Submit pull request with detailed description

## License

MIT License - see LICENSE file for details
