# PQC Prior-Art Notes (Internal)

**Purpose:** Working notes for prior-art and literature review around CPSC/CPAC post-quantum embodiments. This file is INTERNAL and not intended for external distribution.

---

## 1. Core Themes / Claim Hypotheses

1. Constraint-projected verification pipeline for post-quantum cryptographic artifacts (DoF extraction + cryptographic state manifold + projection).
2. Explicit decomposition of cryptographic state into degrees of freedom vs. derived vs. fixed variables, used for exact reconstruction and compression of PQC state.
3. Instruction-free hardware constraint fabric specialized for PQC verification and key handling.
4. Constraint-projected adaptive compression of cryptographic state and artifacts.
5. Constraint-based governance of dual-stack (classical + PQC) cryptographic migration and configuration.

You can edit, add, or refine these as your thinking evolves.

---

## 2. Theme-by-Theme Search Log

For each theme, record what you searched, what you found, and how you currently differentiate.

### 2.1 Theme: Constraint-Projected PQC Verification Pipeline

- **Goal:** Find any work that treats PQC verification as constraint satisfaction / projection over a cryptographic state (rather than imperative code), or anything very close.
- **Searches Run:**
  - Google Patents / USPTO (via MCP):
    - `("post-quantum" OR PQC) (verification OR validator) (pipeline OR architecture) ("constraint-based" OR "state projection" OR "state manifold") (lattice OR "hash-based signature" OR Kyber OR Dilithium OR SPHINCS)`
    - `"post-quantum" (hardware OR accelerator OR "reconfigurable fabric" OR FPGA) (verification OR signature)`
  - Literature / IACR / arXiv:
    - `"post-quantum" verification constraint projection`
    - `"lattice-based signature" "state representation" "verification architecture"`
- **Closest References (initial pass):**
  - **US 11,205,017 – Post quantum public key signature operation for reconfigurable circuit devices (Intel)** – reconfigurable fabric with a mapped state machine for PQC public key generation and verification, combining dedicated and mapped hash engines.
  - **US 12,470,376 B2 – Cryptographic system for post-quantum cryptographic operations (PQShield)** – generalized PQC engine supporting multiple algorithms and hybrid classical+PQC operation across protocols.
  - **US 12,531,724 B2 – Post-quantum cryptography for secure boot (Google)** – use of PQC signatures/keys in secure boot verification chains for firmware images, including potential hybrid schemes.
  - **US 12,452,084 B2 – Lightweight post-quantum authentication** – protocol-level PQC authentication optimized for constrained devices.
  - **US 12,537,693 B2 – Low-memory Dilithium with masked hint vector computation (NXP)** – Dilithium implementation with masked hint computation and reduced memory footprint for signature operations.
  - **US 12,520,047 B1 – Quantum secure communication protocol and device based on double-helix structure composite multi-layer encoding** – multi-layer quantum-secure communication protocol using stacked encodings.
- **Differentiation Story (current draft):**
  - These references treat PQC verification in fairly traditional terms: specific algorithms, optimized state machines, hardened hardware pipelines, and protocol flows for signatures, authentication, or secure boot.
  - None of them model PQC artifacts as **degrees-of-freedom vectors** embedded in a **global cryptographic state manifold** with explicit **constraint projections** that determine acceptance or rejection across channels, storage, and identity simultaneously.
  - Your FIG. 10–12 embodiments treat verification as checking whether a DoF vector lies within a constraint-defined submanifold of cryptographic state, with an **instruction-free constraint fabric** that evaluates those projections independent of any instruction stream.
  - The prior art is algorithm- or protocol-specific; your work is explicitly **algorithm-agnostic and cross-layer**, using a single constraint/projection formalism to govern verification over PQC handshakes, signatures, key hierarchies, and compressed state.
- **Open Questions / Concerns:**
  - Need to keep an eye out for any later work from the same assignees (Intel, PQShield, Google, NXP, Visa, Wells Fargo, etc.) that may start to use more formal "state manifold" or "projection" language for verification.
  - For now, no direct hit on a **constraint-projected PQC verification manifold** spanning multiple layers and algorithms, but this should be re-checked before non-provisional filing.

### 2.2 Theme: DoF vs. Derived Cryptographic State Representation

- **Goal:** Look for explicit decomposition of cryptographic state into independent DoFs vs. derived variables, especially in PQC.
- **Searches Run:**
  - `("degrees of freedom" OR "DoF vector") (cryptographic state OR "signature state") (reconstruction OR projection)`
  - `("post-quantum" OR lattice OR Kyber OR Dilithium) (signature) (compression OR encoding) (structure-aware OR constraint-aware)`
- **Closest References (initial pass):**
  - **US 12,524,262 B1 – Integrated AI-driven and compliance-aware multi-state encoding framework** – defines a multi-state encoding framework for software/compliance state, but not a cryptographic DoF/derived/fixed decomposition.
  - **US 12,476,789 B1 – Computational function transformation (CFT) in computer implemented cryptography** – describes transforming cryptographic computations and internal function representations, but not a formal split between entropy-bearing and derived cryptographic variables.
  - **US 12,500,921 B2 – Systems and methods for data protection utilizing modelers** – uses model-based representations of data and risk; conceptually related to “state models”, but not to a DoF vector of cryptographic state.
  - **US 12,470,376 B2 – Cryptographic system for post-quantum cryptographic operations (PQShield)** – organizes internal state and keys for multiple PQC algorithms, but treats state in implementation terms rather than an explicit DoF / derived / fixed-variable manifold.
- **Differentiation Story (current draft):**
  - These references talk about multi-state encodings, transformed cryptographic functions, or model-based representations, but they do not define a **minimal degrees-of-freedom vector for cryptographic state** with a clear separation between independent, derived, and policy-fixed dimensions.
  - Your work treats cryptographic state as a structured manifold whose coordinates are partitioned into DoF, derived, and fixed components, enabling **exact reconstruction and compression** of PQC artifacts and key hierarchies from the DoF vector alone.
  - In particular, the DoF vs. derived split is used directly in the verification and compression embodiments (and FIG. 10–12), not just as an implementation convenience.
- **Open Questions:**
  - Watch for any later work that starts to speak explicitly about “degrees of freedom” of cryptographic state, especially tied to PQC signatures or keys.
  - Current art on multi-state encoding and model-based cryptography appears adjacent but not yet overlapping your specific DoF/derived/fixed decomposition.

### 2.3 Theme: Instruction-Free PQC Hardware Constraint Fabric

- **Goal:** Find FPGA/ASIC architectures for PQC verification that look like constraint fabrics or instruction-free engines.
- **Searches Run:**
  - `("post-quantum" OR PQC) (hardware) (fabric OR accelerator OR engine) ("constraint" OR "rule-based") ("no instruction stream" OR "without program counter")`
  - `(lattice signature verification) (FPGA OR ASIC) (pipeline) (constraint OR dataflow OR systolic)`
- **Closest References (initial pass):**
  - **US 11,205,017 – Post quantum public key signature operation for reconfigurable circuit devices (Intel)** – maps a PQC signature state machine into a reconfigurable fabric and combines dedicated and mapped hash engines; close on “hardware PQC verification pipeline,” but still expressed as a state machine implementation.
  - **US 12,499,277 B2 – Flexible hardware accelerators for masking conversions with a power of two modulus (NXP)** – describes dedicated hardware for cryptographic masking conversions with flexible pipelines; relevant as a specialized cryptographic fabric, but still oriented around specific operations rather than a general constraint network.
  - **US 12,470,379 B2 – Link encryption and key diversification on a hardware security module** – uses an HSM to manage link encryption and key diversification in hardware; shows hardware-centric cryptographic control, not a constraint-evaluating fabric.
  - **US 12,470,376 B2 – Cryptographic system for post-quantum cryptographic operations (PQShield)** – includes hardware and microarchitectural structures to support PQC algorithms, but appears to rely on instruction- or microcode-driven engines.
- **Differentiation Story:**
  - Existing PQC and cryptographic hardware focuses on **optimized state machines, dataflow pipelines, and accelerators** for specific algorithms or operations.
  - Your hardware embodiment is an **instruction-free constraint fabric** whose job is to evaluate whether a cryptographic DoF vector satisfies a set of constraints over a shared state manifold—**no program counter, no instruction stream**, and no algorithm-specific microcode.
  - Instead of hardwiring single algorithms into engines, you hardwire **constraints and projections**, so that multiple PQC schemes and key hierarchies can be verified by the same fabric as long as they are expressed in the shared constraint language.
- **Open Questions:**
  - Need a sanity check for any future patents that explicitly describe “instructionless” or “program-counter-free” cryptographic fabrics, especially in the PQC space.
  - For now, hardware prior art seems limited to state machines and engines rather than generalized constraint fabrics.

### 2.4 Theme: Constraint-Projected Compression of Cryptographic State

- **Goal:** Any schemes that compress signatures / PQC state using explicit structural or constraint models.
- **Searches Run:**
  - `("post-quantum" OR lattice OR Kyber OR Dilithium) (signature) compression`
  - `("constraint-based" OR "structural compression" OR "degree of freedom") cryptographic state`
- **Closest References (initial pass):**
  - **US 12,520,047 B1 – Quantum secure communication protocol and device based on double-helix structure composite multi-layer encoding** – uses a layered encoding structure for quantum-secure communication; conceptually about stacked encodings, not about extracting a minimal DoF vector.
  - **US 12,524,262 B1 – Integrated AI-driven and compliance-aware multi-state encoding framework** – proposes a multi-state encoding framework that can reduce or normalize state representations for compliance; again, no explicit cryptographic DoF manifold.
  - **US 12,452,084 B2 – Lightweight post-quantum authentication** – focuses on reducing computational and communication cost for PQC authentication; may implicitly reduce message sizes but does not formalize compression as projection onto constraints.
  - **US 12,499,277 B2 – Flexible hardware accelerators for masking conversions with a power of two modulus (NXP)** – performs internal representation conversions, which can change width/format of state, but is not framed as structural compression of full cryptographic state.
- **Differentiation Story:**
  - The above works do **encoding, layering, or optimization**, but they do not define compression as a side effect of **projecting a high-dimensional cryptographic state onto its independent degrees of freedom under explicit constraints**.
  - Your embodiments let you recover full PQC state (signatures, keys, projections, error terms) from a compact DoF vector, because the constraints and manifold structure encode all the relationships needed for reconstruction.
  - In other words, compression is governed by the **constraint structure of the cryptographic state space**, not by ad hoc encodings or format-specific tricks.
- **Open Questions:**
  - It would be good to periodically re-run searches around “post-quantum state compression” and “structural compression of signatures” in case more explicit work appears.
  - As of this pass, structural/constraint-driven compression of PQC state still looks like a gap.

### 2.5 Theme: Constraint-Governed PQC Migration and Dual-Stack Governance

- **Goal:** Prior art on formal/constraint-based governance of crypto posture and migration.
- **Searches Run:**
  - `"post-quantum" migration governance policy (constraint-based OR rule-based)`
  - `"dual stack" (PQC OR "post-quantum") ("policy engine" OR "configuration solver")`
- **Closest References (initial pass):**
  - **US 12,470,376 B2 – Cryptographic system for post-quantum cryptographic operations (PQShield)** – appears to support multiple PQC algorithms and classical algorithms in a single system, implying some form of algorithm agility and migration.
  - **US 12,519,625 B1 – Systems and methods for facilitating quantum-resistant encryption of data** – aims at introducing quantum-resistant encryption into existing systems; likely discusses how and when to apply quantum-resistant schemes.
  - **US 12,530,675 B2 – Hot wallet protection using a layer-2 blockchain network (PayPal)** – not PQC-specific, but includes policy-driven protection of cryptographic keys and transactions across multiple layers.
  - **US 11,205,017 / US 12,470,379 B2** – hardware-centric schemes that implicitly require policy choices about when to use particular engines or key-handling modes, but do not expose a formal constraint model.
- **Differentiation Story:**
  - These works show **algorithm agility, adoption of quantum-resistant schemes, and policy heuristics** for when to use which cryptographic mechanism, but governance is coded as imperative logic or configuration flags.
  - Your dual-stack governance model instead represents both classical and PQC configurations inside a **single constraint language over the cryptographic state manifold**, and treats posture/migration as solving a constraint problem (e.g., “all channels with property X must satisfy Y constraints in the state manifold”).
  - Migration steps correspond to **changing constraints and projections**, not rewriting code paths; the same verification and compression machinery continues to operate as long as the new posture is expressed in the constraint system.
- **Open Questions:**
  - Look out for any explicit “constraint solver for cryptographic configuration” or “formal crypto policy solver” patents, especially tied to PQC rollout.
  - Current art seems to stop at rule-based or configuration-driven agility, without a unified constraint-based state model.

---

## 3. General Observations

Use this section for higher-level notes (e.g., which companies/papers keep showing up, gaps you see, potential claim angles).

---

**PQC Prior Art Notes** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
