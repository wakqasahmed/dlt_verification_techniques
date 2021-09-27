# DLT5402 - Verification Techniques for Smart Contract

### Question 0: Specification Languages

You can find one property written for

- Escrow Smart Contract
- PiggyBank Smart Contract

using each of:

- finite state automata
- regular expression (positive)
- regular expression (negative)
- LTL
- CTL

### Question 1: Testing

_Pre-requisite (Recommended)_

- Truffle v5.4.11
- Ganache v2.5.4
- Node v14.17.5
- `npm install lite-server -g` OR `npm install http-server -g`

#### How to run tests

- Open ganache GUI at Port 7545
- `cd testing/Escrow` OR `cd testing/PiggyBank`
- `truffle test`

#### How to run coverage

- Open ganache GUI at Port 7545
- `cd testing/Escrow` OR `cd testing/PiggyBank`
- `truffle run coverage`
- `cd coverage`
- `lite-server index.html` OR `http-server index.html`

### Question 2: Runtime Verification

You can find Dynamic Event Automata written in the document.

### Question 3: Static Verification

_Functional Specifications_
