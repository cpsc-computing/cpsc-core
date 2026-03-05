# Constraint-Projected State Computing and the Permission Infrastructure Problem
## A Computational Model Where Nothing Happens Without Permission

**Author:** Tristan Pierson, BitConcepts, LLC  
**Date:** March 2026  
**Version:** 1.0.0  
**Status:** Public whitepaper for the Permission Infrastructure Forum (PIF)  
**License:** This document is published for public discussion. The underlying CPSC technology is covered by U.S. Provisional Patent Application No. 63/980,251 (filed February 11, 2026) and is available under the CPSC Research & Evaluation License.

---

## 1. The Problem

Modern infrastructure is increasingly governed by software. Charging stations decide when to deliver power. Autonomous vehicles negotiate right-of-way. Shared mobility platforms allocate access to physical resources. AI agents propose actions that affect the real world.

Yet the computational models underlying these systems were not designed around permission. They were designed around execution. A program runs. A model infers. An agent acts. Permission — if it exists at all — is typically bolted on after the fact: an API check before a function call, a policy layer above the control loop, a log entry written after the action is already taken.

This creates a structural gap. The more autonomous and interconnected infrastructure becomes, the harder it gets to answer a simple question: **Was this action explicitly permitted before it was executed?**

---

## 2. What If Permission Were the Computation?

Constraint-Projected State Computing (CPSC) is a computing model that addresses this gap at the architectural level. In CPSC, computation is not defined as the execution of ordered instructions. It is defined as the projection of proposed system state onto a space defined by explicit constraints.

In plain terms:

- **State** represents the full configuration of the system — every variable, sensor reading, flag, command.
- **Constraints** declare which configurations are valid. These are the rules: physical limits, safety envelopes, authorization policies, protocol invariants.
- **Projection** is the act of taking a proposed state and resolving it into a state that satisfies all constraints — or deterministically rejecting it.

Nothing is committed until projection succeeds. There is no intermediate state that escapes constraint enforcement. The system cannot arrive at an invalid configuration because invalid configurations are not representable as committed state.

This is not permission as a check. This is **permission as the fundamental operation**.

---

## 3. How It Works

CPSC systems operate in **epochs** — discrete time intervals analogous to clock cycles in hardware or transaction boundaries in databases:

1. **Sense** — The system observes inputs: sensor data, commands, proposals from AI agents or operators.
2. **Compute** — A projection engine evaluates all constraints against the proposed state and applies bounded corrections.
3. **Evaluate** — The engine determines whether all constraints are satisfied (convergence) or whether the proposal must be rejected.
4. **Commit** — If and only if the projected state is valid, it becomes the new committed state. Otherwise, the system holds its current state.

Crucially, intermediate computations during projection have no semantic meaning. Only the committed state matters. This eliminates an entire class of problems where systems act on partially-evaluated or inconsistent state.

---

## 4. What This Means for Permission Infrastructure

CPSC maps directly to the themes the Permission Infrastructure Forum is exploring:

### Permission Before Action

In CPSC, no state transition occurs without first passing through constraint evaluation. This is not a policy layer sitting above the system — it is the system. A charging station governed by CPSC constraints cannot deliver power to an unauthorized vehicle because the state where "power = on" and "authorization = none" violates a declared constraint and will never be committed.

### Identity in Infrastructure

Identity, roles, and authorization levels are expressible as constraint variables. A vehicle's identity, an operator's certification, a device's commissioning status — these become part of the state model, subject to the same projection rules as physical variables like voltage, position, or torque. Identity is not a separate system; it is a first-class participant in the constraint space.

### Authorized Execution Models

The epoch cycle is itself an authorized execution model. Every state transition is bounded, deterministic, and traceable to a specific set of inputs and constraints. AI agents and autonomous systems can propose actions freely — but the projection engine is the sole authority on what is permitted. Proposals that violate constraints are corrected or rejected before they reach the physical world.

### Liability-Grade Logging

CPSC's determinism guarantee provides something that conventional logging cannot: **reproducibility**. Given the same initial state, the same constraints, and the same inputs, a CPSC system will produce the same output — always.

The minimal information needed to reconstruct any committed state is the **degrees-of-freedom (DoF) vector** — a compact representation of the independent variables. Storing the DoF record for each epoch gives you a complete, verifiable, replayable audit trail. An insurer or regulator does not need to trust the logs; they can re-run the projection and verify the outcome independently.

---

## 5. Concrete Example: EV Charging Authorization

Consider an EV charging station that must enforce:

- The vehicle is authenticated and authorized for this station
- The operator's account is in good standing
- The grid connection permits the requested power draw
- The vehicle's battery management system reports safe-to-charge
- The insurance policy for this session is active

In a conventional system, these checks happen in sequence — often across multiple services — and the charging session starts when all checks return "OK." If any service is slow, unavailable, or returns stale data, the system must handle the failure case after the fact.

In a CPSC system, all of these are constraints on a single state space. The state includes variables for vehicle identity, operator status, grid capacity, battery state, and insurance status. The projection engine evaluates them simultaneously. If any constraint is violated, the state where charging is active cannot be committed. There is no race condition, no partial authorization, no "check then act" gap. The permission and the action are the same computation.

---

## 6. Hardware and Edge Deployment

CPSC is not limited to cloud software. The model maps directly to hardware as a **constraint fabric** — parallel evaluation logic that enforces constraints without instruction execution, program counters, or operating systems. This makes CPSC suitable for:

- **Edge controllers** in charging infrastructure, building management, and industrial systems
- **FPGA-based enforcement** where constraints are compiled into hardware logic
- **Embedded systems** in vehicles, robots, and autonomous platforms

The same constraint model that runs in a cloud-based policy engine can be compiled to an FPGA at the edge, with identical semantics. This is critical for infrastructure where latency, reliability, and auditability at the point of action are non-negotiable.

---

## 7. Relationship to Existing Approaches

CPSC is not a replacement for identity providers, authorization protocols, or policy engines. It is a computational substrate that can host and enforce them.

- **OAuth tokens, X.509 certificates, and decentralized identifiers** can feed identity variables into the CPSC state model.
- **ABAC and RBAC policies** can be expressed as constraints in CAS-YAML (CPSC's declarative constraint format).
- **Existing logging and audit systems** can consume the DoF record as a compact, verifiable event stream.

The difference is that in CPSC, these are not separate layers with separate failure modes. They are constraints in a unified model, evaluated atomically at every epoch boundary.

---

## 8. Status and Availability

CPSC is developed by BitConcepts, LLC and is currently in the specification and early reference implementation phase. The core specification, declarative constraint format (CAS-YAML), and reference engines (Python, Rust, VHDL/FPGA) are available for research and evaluation under the CPSC Research & Evaluation License.

- **Specification:** [github.com/cpsc-computing/cpsc-core](https://github.com/cpsc-computing/cpsc-core)
- **Organization:** [github.com/cpsc-computing](https://github.com/cpsc-computing)
- **Patent:** U.S. Provisional Application No. 63/980,251 (filed February 11, 2026)

Commercial licensing is available for production deployment.

---

## 9. Summary

The Permission Infrastructure Forum asks: **Who or what has permission to act in the physical world?**

CPSC offers a computational answer: Permission is not a check before execution. Permission *is* the execution. By defining computation as constraint projection, CPSC ensures that no system state — and therefore no physical action — can occur unless it satisfies every declared constraint. The result is a deterministic, auditable, hardware-deployable model for infrastructure where authorization is not an afterthought but the architecture itself.

---

*Tristan Pierson, BitConcepts, LLC — March 2026*
