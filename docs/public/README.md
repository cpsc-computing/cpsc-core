# Public Docs Overview

This folder contains **public-facing, high-level explainers** for core ideas in the CPSC / CPAC stack.  
They are intended for engineers, architects, and partners, and **do not** describe or limit any particular patent claims.

None of the documents here should be treated as specifications or legal filings.

---

## Available Overviews

### 1. Constraint-Projected State Computing (CPSC)

- File: `cpsc-overview.md`
- Purpose: Introduces the core CPSC paradigm in plain language.
- Focuses on:
  - Constraints as the source of truth,
  - Projection of state into a constraint-defined space,
  - Simple mechanical analogies for hardware and software.

### 2. Constraint-Projected Adaptive Compression (CPAC)

- File: `cpac-overview.md`
- Purpose: Explains CPAC as a structured compression front-end built on top of CPSC.
- Focuses on:
  - Constraint-aware structuring of data,
  - Degrees of freedom (DoFs) as the compressed representation,
  - How prediction and entropy coding fit around that structure.

### 3. Post-Quantum Cryptography (PQC)

- File: `pqc-overview.md`
- Purpose: Provides a high-level explanation of our PQC embodiments and how they protect data in transit, data at rest, and identity/lifecycle.
- Focuses on:
  - The PQC core and three main embodiments,
  - Hybrid classical + PQC handshakes and key hierarchies,
  - Practical deployment and migration toward a PQC-native ecosystem.

---

## Usage Notes

- These documents are **safe to share** externally in conversations, slide decks, or partner evaluations, subject to your own review and NDAs as appropriate.
- They deliberately avoid implementation details, parameter choices, and claim-like language.
- For formal patent content, see `docs/patents/` and related internal documents, which remain the authoritative sources for legal scope.

---

**Public Documentation README** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
