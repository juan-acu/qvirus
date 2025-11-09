# qvirus 0.0.5

## New features

### Quantum Key Distribution (QKD) Protocols
- Added full simulation of the **BB84** protocol through `run_bb84_simulation()`.  
  This function models the quantum key distribution process between Alice and Bob,  
  computing the **Quantum Bit Error Rate (QBER)** under both perfect (secure) and  
  eavesdropped (compromised) channels.
- Added simulation of the **E91 (Ekert 1991)** entanglement-based protocol via  
  `run_e91_simulation()`.  
  This implementation uses Bell’s inequality (CHSH statistic) to determine  
  whether the communication channel exhibits quantum behavior (`|S| > 2`) or  
  classical (insecure) behavior (`|S| ≤ 2`).

### Interaction and Payoffs Framework
- Improved integration between `Interaction` and `InteractionClassification` objects.
- Enhanced the payoff computation workflow, introducing **`mse.payoffs()`** for  
  evaluating mean squared errors between observed and predicted payoffs.
- Updated internal accessors to reduce direct exposure of object internals, ensuring  
  cleaner S3 method dispatch and reproducibility.

### Documentation and Testing
- Expanded documentation with detailed Roxygen examples and theoretical references  
  for both BB84 and E91 protocols.
- Added reproducible test cases and numerical rounding stability in snapshot tests.
- Improved code consistency and formatting to support reproducible builds on CRAN.

---

# qvirus 0.0.4

## New features

### Interaction
- Added new functionalities to the `Interaction` class, enhancing its capabilities for modeling quantum simulations.

### InteractionClassification
- Added new functionalities to the `InteractionClassification` class.

### Quantum game of phenotypes
- Added new fubnctionalities to design and simulate quantum games of HIV phenotypes
  