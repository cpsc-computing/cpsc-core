# BitConcepts Terminology Glossary

This document defines canonical terminology used across all BitConcepts repositories to ensure consistency.

## Core Technologies

### CPSC (Constraint-Projected State Computing)
A declarative computing model in which computation is performed by projecting system state onto a space defined by explicit constraints, rather than by executing ordered instructions. Provides a foundation for deterministic, constraint-driven systems across software, compression, control systems, and hardware (FPGA/ASIC).

**Repositories**: `cpsc-core` (specifications), `cpsc-engine-python`, `cpac-engine-python`

### CPAC (Constraint-Projected Adaptive Compression)
A compression scheme built directly on CPSC that uses constraint-based state projection to identify degrees of freedom, applies optional prediction, and uses standard entropy coding on the simplified representation. Provides end-to-end compression for structured data formats.

**Repositories**: `cpac-engine-python`, `cpsc-python`

### MSN (Multi-Scale Normalization)
CPAC's Stage 1: deterministic extraction and canonicalization of structured data across multiple scales (byte, field, record levels) before constraint projection. Performs domain-specific normalization to prepare data for CPSC encoding.

**Historical note**: Internally also referred to as "Merkur Semantic Normalization" in acknowledgment of prior art that inspired the approach.

**Repositories**: `cpac-engine-python`  
**Key files**: `src/cpac/core/msn.py`, `docs/MSN-DOMAINS-ARCHITECTURE.md`

### SSR (Symbol-Space Reduction)
CPAC's Stage 2: reduces the symbol space of normalized data before constraint projection.

**Repositories**: `cpac-engine-python`

## Solver Technologies

### MaxSAT
Maximum Satisfiability solver - finds maximum number of clauses that can be satisfied in a boolean formula. Used in CPSC for constraint optimization.

### Ising/QUBO (Quadratic Unconstrained Binary Optimization)
Quadratic optimization over binary variables, equivalent to the Ising model from physics. Used in CPSC for finding optimal binary encodings.

**Implementation**: `cpsc-engine-python/src/cpsc/ising/`, `cpsc-engine-python/src/cpsc/solvers/ising.py`

### MILP (Mixed Integer Linear Programming)
Linear programming with integer constraints. Potential solver backend for CPSC.

## Architecture Components

### CAS (Constraint Algebra System)
The symbolic constraint representation system used by CPSC. Defines variables, domains, and constraints for compression problems.

**Key files**: `CAS-*.yaml` model files

### AdaptiveEngine
CPSC component that automatically selects the best solver strategy (direct, iterative, hybrid) based on problem characteristics.

**Repository**: `cpsc-engine-python`  
**Key file**: `src/cpsc/adaptive_engine.py`

### Constraint Fabric
The execution layer that coordinates constraint solving, handles solver backends, and manages state during compression/decompression.

**Repository**: `cpsc-engine-python`  
**Key files**: `src/cpsc/constraint_fabric.py`, `src/cpsc/solvers/*_fabric.py`

## Common Abbreviations

- **DoF**: Degrees of Freedom
- **CLI**: Command Line Interface
- **API**: Application Programming Interface
- **YAML**: YAML Ain't Markup Language (configuration format)

---

**Last updated**: Session after CPSC v1.0 release with parallel Ising engine  
**Maintainer**: Keep this glossary synchronized when introducing new terminology

---

**GLOSSARY.md** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
