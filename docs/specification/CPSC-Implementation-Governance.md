# CPSC Implementation Governance (Informational)
## Recommended Workflow, Determinism Practices, and Tooling

**Version:** 0.1  
**Status:** Informational (Non-Normative)  
**Published:** January 17, 2026  

---

## 1. Purpose

This document provides **implementation governance guidance** for teams building systems on top of CPSC:

- it summarizes recommended development workflows,
- clarifies how specifications should be referenced during implementation,
- and describes best practices for agent-assisted development.

It does **not** define new technical semantics for CPSC, CAS-YAML, or the CPSC binary format.
Those semantics are defined normatively in:

- `CPSC-Specification.md`
- `CAS-YAML-Specification.md`
- `Binary-Format-Specification.md`
- `Binary-Format-RTL-Mapping.md`
- `CPSC-Engine-Modes-Specification.md`
- `CPSC-Adaptive-Engine-Specification.md`

---

## 2. Spec-First Development Workflow

Implementations SHOULD follow a spec-first workflow:

1. **Reference specifications**  
   Identify the relevant sections of the CPSC core, CAS-YAML, binary format, or RTL mapping specifications that apply to the change.

2. **Define or reference requirements**  
   Express the behavior in terms of explicit, testable requirements (e.g., "given X, projection MUST converge to Y under section N of the spec").

3. **Implement code**  
   Make the minimal change required to satisfy the stated requirements.

4. **Write tests**  
   Add or update tests that exercise the requirements and validate compliance with the normative specifications.

5. **Record results** (optional but recommended)  
   Maintain a local ledger or tracking document that links code changes, tests, and specification sections.

Implementations MUST stop and escalate when the specifications are ambiguous or appear to conflict.

---

## 3. Determinism and Explicit Configuration

The core CPSC specification requires deterministic convergence and explicit numeric behavior.
In practice, implementations SHOULD:

- make numeric modes and precision explicit in configuration,
- avoid hidden defaults when interpreting CAS-YAML or binary fields,
- document convergence criteria and bounds used by projection engines,
- ensure that software and hardware agree on numeric mode and precision.

Changes that weaken determinism or introduce implicit behavior SHOULD be treated as semantics changes and subjected to careful review.

### 3.1 Grid Topology Determinism

When implementing multi-topology grid support for the Cellular Engine:

- Grid dimensions (width, height) MUST be explicit in configuration
- Neighbor ordering MUST be consistent and documented
- For GraphGrid, edge list order defines neighbor iteration order
- Connectivity mode (4 vs 8) MUST be explicit for 2D grids
- Boundary conditions MUST be declared (no implicit defaults)

Changes to neighbor ordering or boundary handling MUST be treated as semantics changes.

---

## 4. Agent-Assisted Development (Optional)

Organizations MAY use AI agents to assist with implementation, documentation, and testing.

Recommended practices:

- **Roles**  
  Treat agents as code writers, test writers, and reviewers—not as specification authors or semantic authorities.

- **Spec referencing**  
  Require agents to point to specific specification sections when proposing behavior or test changes.

- **No invented semantics**  
  Prohibit agents from inventing new semantics or inferring behavior that is not clearly defined in the specifications.

- **Transparency**  
  All agent output MUST be reviewable by humans; there is no "magic".

Repository-local governance files (for example, `WARP.md` and `AGENTS.md`) may define more detailed rules tailored to specific projects. In some embodiments, teams may also define explicit constraint models for agentic development workflows using CAS-YAML or equivalent formats (for example, CPSC-governed agentic development, or CGAD, profiles for software and hardware projects), provided that such models remain informational and consistent with the normative CPSC and CAS-YAML specifications.

---

## 5. Relationship to Normative Specifications

This document is **informational only**.

If any statement in this document appears to conflict with:

- `CPSC-Specification.md`
- `CAS-YAML-Specification.md`
- `Binary-Format-Specification.md`
- `Binary-Format-RTL-Mapping.md`
- `CPSC-Engine-Modes-Specification.md`
- `CPSC-Adaptive-Engine-Specification.md`

then the normative specifications above take precedence

---

**CPSC-Implementation-Governance.md** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
