# Draft Claim Set – Theme H (Constraint-Projected Cryptographic State and Post-Quantum Verification)

**Status:** Draft – Internal, Non-Legal  
**Scope:** Outline-only examples for a Theme H continuation focused on cryptographic state, post-quantum verification, and compression-coupled cryptographic state handling under the CPSC paradigm.

These are **not** final legal claims and MUST be reviewed and rewritten by counsel.

---

## 1. Independent Claims

### Claim 1 – Independent Paradigm Claim (Anchor)

1. A method of computation comprising:
   1.1 representing a system state using a plurality of state variables;
   1.2 defining, for the system state, a plurality of declarative constraints specifying valid relationships among the state variables; and
   1.3 applying a deterministic projection operation that, given a proposed assignment of values to at least a subset of the state variables, produces either:
       - (i) a valid state satisfying the plurality of declarative constraints, or
       - (ii) an indication of failure when no such valid state is reachable within declared bounds;

   wherein computation is defined by the deterministic projection operation rather than by execution of an ordered sequence of instructions.

### Claim 2 – Independent PQC Claim (Theme H – Cryptographic DoF + Projection)

2. A method of verifying a cryptographic artifact for a post-quantum cryptographic algorithm, the method comprising:
   2.1 representing the cryptographic artifact as a degree-of-freedom vector over a cryptographic state, the cryptographic state comprising a plurality of cryptographic state variables;
   2.2 defining, for the cryptographic state, a plurality of declarative cryptographic constraints specifying valid relationships among the cryptographic state variables;
   2.3 applying a deterministic projection operation that, given the degree-of-freedom vector, iteratively updates derived ones of the cryptographic state variables until either:
       - (i) the cryptographic state satisfies the plurality of declarative cryptographic constraints within declared bounds, or
       - (ii) a failure condition is detected; and
   2.4 determining that the cryptographic artifact is valid when the cryptographic state satisfies the plurality of declarative cryptographic constraints and invalid when the failure condition is detected;

   wherein the post-quantum cryptographic algorithm is unchanged and cryptographic correctness is enforced by the deterministic projection operation over the cryptographic state.

---

## 2. Dependent Claims – Generic Cryptographic Structure

### Claim 3 – Independent / Derived / Fixed Cryptographic Variables

3. The method of claim 2, wherein the cryptographic state variables comprise:
   3.1 independent variables that carry entropy associated with the cryptographic artifact,
   3.2 derived variables that are fully determined by the plurality of declarative cryptographic constraints, and
   3.3 fixed variables that are invariant under the post-quantum cryptographic algorithm;

   and wherein the degree-of-freedom vector encodes values only for the independent variables.

### Claim 4 – Types of Cryptographic Constraints

4. The method of claim 2 or claim 3, wherein the plurality of declarative cryptographic constraints comprise at least one of:
   4.1 modular arithmetic constraints enforcing ring relations,
   4.2 linear algebra constraints representing matrix–vector products,
   4.3 norm constraints bounding magnitudes of coefficients, and
   4.4 hash-based consistency constraints.

### Claim 5 – Deterministic Convergence Behavior

5. The method of any of claims 2–4, wherein the deterministic projection operation is configured such that, for a given degree-of-freedom vector and configuration, the projection operation either converges to the same valid cryptographic state or fails in the same manner across executions.

---

## 3. Dependent Claims – NIST-Specific PQC Embodiments

### Claim 6 – Module-Lattice-Based Digital Signature (ML-DSA / Dilithium)

6. The method of any of claims 2–5, wherein the post-quantum cryptographic algorithm is a module-lattice-based digital signature algorithm, and wherein the cryptographic state variables comprise:
   6.1 public-key entropy components,
   6.2 signature entropy components,
   6.3 message hash values,
   6.4 derived polynomial vectors and matrices, and
   6.5 derived challenge values;

   and wherein the plurality of declarative cryptographic constraints encode algebraic relations, norm bounds, and challenge consistency conditions of the module-lattice-based digital signature algorithm.

### Claim 7 – Stateless Hash-Based Digital Signature (SLH-DSA / SPHINCS+)

7. The method of any of claims 2–5, wherein the post-quantum cryptographic algorithm is a stateless hash-based digital signature algorithm, and wherein the cryptographic state variables comprise:
   7.1 message hash values,
   7.2 one-time signature entropy,
   7.3 Merkle tree path entropy, and
   7.4 derived hash tree nodes and root values;

   and wherein the plurality of declarative cryptographic constraints encode Merkle path correctness and root reconstruction relations.

### Claim 8 – Module-Lattice-Based Key-Encapsulation Mechanism (ML-KEM / Kyber)

8. The method of any of claims 2–5, wherein the post-quantum cryptographic algorithm is a module-lattice-based key-encapsulation mechanism, and wherein the cryptographic state variables comprise:
   8.1 public-key entropy components,
   8.2 ciphertext entropy components,
   8.3 encapsulated key material,
   8.4 derived shared secrets, and
   8.5 intermediate lattice products and reductions;

   and wherein the plurality of declarative cryptographic constraints encode encapsulation and decapsulation relations of the key-encapsulation mechanism.

---

## 4. Dependent Claims – Hardware and Software Embodiments

### Claim 9 – Software Projection Engine

9. The method of any of claims 2–8, wherein the deterministic projection operation is performed by software executing on a general-purpose processor.

### Claim 10 – Hardware Constraint Fabric

10. The method of any of claims 2–8, wherein the deterministic projection operation is performed by a hardware constraint fabric comprising:
    10.1 a plurality of state registers configured to store at least a portion of the cryptographic state variables,
    10.2 a plurality of parallel constraint evaluation units configured to evaluate the plurality of declarative cryptographic constraints, and
    10.3 commit logic configured to update the state registers at discrete commit boundaries;

    wherein the hardware constraint fabric is configured to perform cryptographic verification without executing an ordered sequence of instructions.

---

## 5. Dependent Claims – Compression-Coupled PQC State (CPAC)

### Claim 11 – Serialization of Cryptographic Degrees of Freedom

11. The method of any of claims 2–10, further comprising:
    11.1 serializing, prior to transmission or storage, only the degree-of-freedom vector and an identifier of a cryptographic constraint model; and
    11.2 upon receipt, reconstructing a full cryptographic state by:
         - decoding the degree-of-freedom vector,
         - initializing the cryptographic state using the degree-of-freedom vector and the cryptographic constraint model, and
         - applying the deterministic projection operation to reconstruct the derived cryptographic state variables;

    wherein the serialized representation omits deterministic cryptographic structure implied by the cryptographic constraint model.

### Claim 12 – Prediction and Entropy Coding over Cryptographic DoFs

12. The method of claim 11, further comprising:
    12.1 applying a prediction stage over the degree-of-freedom vector to obtain predicted degrees of freedom;
    12.2 forming residuals between actual and predicted degrees of freedom; and
    12.3 entropy coding at least the residuals to produce a compressed representation of the cryptographic artifact.

### Claim 13 – Projection-Based Integrity Check on Decompression

13. The method of any of claims 2–12, wherein any failure of the deterministic projection operation to converge under the cryptographic constraint model is treated as an indication that the compressed representation or reconstructed cryptographic artifact is invalid or corrupted.

---

## 6. Dependent Claims – Governance and Specification Binding

### Claim 14 – Versioned Cryptographic Constraint Models

14. The method of any of claims 2–13, further comprising:
    14.1 defining the plurality of declarative cryptographic constraints in a versioned cryptographic constraint model;
    14.2 associating an identifier of the cryptographic constraint model with the degree-of-freedom vector; and
    14.3 verifying, at a later time, that a deployed cryptographic implementation conforms to the cryptographic constraint model by observing whether its behavior corresponds to the deterministic projection operation applied under the cryptographic constraint model.

### Claim 15 – Cryptographic Verification Harness for Heterogeneous Implementations

15. The method of any of claims 2–14, wherein the cryptographic constraint model and the deterministic projection operation are used as a formal verification harness for a plurality of heterogeneous cryptographic implementations, and wherein correctness of each implementation is determined based on whether candidate cryptographic states produced by the implementation project to valid cryptographic states under the cryptographic constraint model.

---

## 7. Notes for Counsel

- These claims are **deliberately broad** and may need to be split across multiple independent/dependent claim sets depending on jurisdictional practice and examiner feedback.
- Counsel should consider:
  - whether Claim 1 (paradigm) remains in the anchor family while Claim 2+ moves to a Theme H continuation, or
  - whether Theme H should have its own independent paradigm-style claim referencing cryptographic state specifically.
- All algorithm names (ML-DSA, SLH-DSA, ML-KEM) are intended as examples and should be framed non-limitingly in any filed claim language.

---

**Claim Set Theme H Draft** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
