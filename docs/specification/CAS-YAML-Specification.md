# CAS-YAML Specification
## Constraint Architecture Specification for CPSC

**Version:** 1.0  
**Status:** Draft Specification  
**Published:** January 17, 2026  

---

## License Notice

This specification is released under the **CPSC Research & Evaluation License**.

It may be used, shared, and cited for non-commercial research, evaluation, and educational purposes.
Commercial use, production deployment, or implementation in commercial systems requires a separate license.

The technology described herein may be subject to patent protection.
All rights are reserved.

---

## Abstract

This document defines **CAS-YAML**, the declarative Constraint Architecture Specification format used by Constraint-Projected State Computing (CPSC). CAS-YAML provides a portable, deterministic, and implementation-agnostic way to describe system state, constraints, degrees of freedom, execution parameters, and composition rules. CAS-YAML is designed to support software execution, hardware synthesis, streaming operation, and layered specification through file inclusion and overrides.

---

## 1. Purpose and Scope

CAS-YAML defines **what a CPSC model is**, not how it is solved.

This specification:
- defines the structure and semantics of CAS-YAML documents
- defines how multiple CAS-YAML files are composed
- defines validation and determinism requirements
- enables reuse, specialization, and deployment-specific overlays

This document does **not** define:
- specific numerical solvers
- optimization algorithms
- learning mechanisms
- instruction-level execution semantics

---

## 2. Design Goals

CAS-YAML is designed to be:

- Declarative and human-readable
- Deterministic and reproducible
- Portable across implementations
- Suitable for hardware synthesis
- Layerable through composition
- Explicit about degrees of freedom

---

## 3. Document Structure

A CAS-YAML document consists of the following top-level sections:

- `version`
- `model_id`
- `includes` (optional)
- `state`
- `constraints`
- `degrees_of_freedom`
- `projection`
- `execution`

All fields not explicitly defined in this specification are invalid.

---

## 4. Versioning

### 4.1 Version Field

Every CAS-YAML document MUST declare a version:

```yaml
version: 1.0
```

The version refers to the CAS-YAML specification version, not the CPSC core specification.

---

## 5. Model Identity

### 5.1 Model Identifier

Each CAS-YAML document MUST define a unique model identifier:

```yaml
model_id: example_model_v1
```

The model identifier is used for:

* binary metadata
* reconstruction validation
* hardware binding
* compatibility checks

---

## 6. File Inclusion and Composition

### 6.1 Includes

CAS-YAML supports **explicit file inclusion** to enable layered models.

```yaml
includes:
  - base/core.yaml
  - domain/telemetry.yaml
  - override/device_a.yaml
```

Includes MUST be resolved:

* in listed order
* before validation
* prior to execution

---

### 6.2 Include Resolution Rules

* Included files are parsed as CAS-YAML documents
* Includes MAY themselves contain includes
* Cyclic includes are invalid and MUST be rejected
* Relative paths are resolved relative to the including file

---

### 6.3 Merge and Override Semantics

When multiple CAS-YAML files are composed, elements are merged as follows:

| Element              | Rule                       |
| -------------------- | -------------------------- |
| `state.variables`    | merged by variable name    |
| `constraints`        | merged by constraint id    |
| `degrees_of_freedom` | overridden by last include |
| `projection`         | overridden by last include |
| `execution`          | overridden by last include |

Conflicts MUST resolve deterministically or fail validation.

---

## 7. State Definition

### 7.1 State Section

The `state` section defines all variables in the system.

```yaml
state:
  variables:
    - name: x
      type: int
      domain: [0, 100]
```

---

### 7.2 Variable Fields

Each variable MUST define:

* `name` — unique identifier
* `type` — implementation-defined primitive type
* `domain` — allowed bounds or discrete set

Optional fields:

* `derived` — boolean, default false
* `description` — human-readable description

---

### 7.3 Variable Semantics

* All variables form the complete system state
* Variables may be referenced by constraints
* Derived variables MUST be fully determined by constraints

---

## 8. Constraints

### 8.1 Constraint Section

Constraints are declared as a list:

```yaml
constraints:
  - id: sum_limit
    expression: x + y <= 100
```

---

### 8.2 Constraint Fields

Each constraint MUST define:

* `id` — unique identifier
* `expression` — declarative constraint expression

Optional fields:

* `description`
* `scope` (informational only)

---

### 8.3 Constraint Semantics

* Constraints MUST be side-effect free
* Constraints MUST evaluate to satisfied or violated
* Constraint evaluation order is undefined
* All constraints are enforced simultaneously

---

## 9. Degrees of Freedom

### 9.1 DoF Section

The `degrees_of_freedom` section explicitly identifies free variables:

```yaml
degrees_of_freedom:
  free:
    - x
    - y
```

---

### 9.2 DoF Semantics

* Variables listed as free define the independent state parameters
* All other variables MUST be derived or fixed
* A valid state MUST be reconstructible from DoF alone

---

## 10. Projection Configuration

### 10.1 Projection Section

The `projection` section defines convergence parameters:

```yaml
projection:
  strategy: auto             # Engine selection strategy
  method: bounded_relaxation
  max_iterations: 32
  convergence_epsilon: 0
```

---

### 10.2 Projection Semantics

* Projection method names are symbolic
* Implementations MUST document supported methods
* Bounds MUST be explicit
* Failure to converge MUST be reported

---

### 10.3 Strategy Field

The optional `strategy` field controls engine selection for implementations supporting multiple projection engines (per CPSC-Engine-Modes-Specification.md §5):

| Value       | Behavior                                                                 |
| ----------- | ------------------------------------------------------------------------ |
| `auto`      | AdaptiveEngine selects based on constraint graph analysis (default)      |
| `iterative` | Force IterativeEngine regardless of constraint structure                 |
| `cellular`  | Force CellularEngine regardless of constraint structure                  |
| `hybrid`    | Staged execution: iterative then cellular (reserved for future use)      |

**Default:** `auto` (if `strategy` field is omitted)

**Priority chain:** When AdaptiveEngine is available:
1. API override (highest priority)
2. CAS-YAML `projection.strategy` field
3. Auto-detection from constraint graph analysis
4. Default fallback: iterative engine

Implementations not supporting AdaptiveEngine SHOULD ignore this field and use their default engine

---

## 11. Execution Configuration

### 11.1 Execution Section

The `execution` section defines determinism and numeric behavior:

```yaml
execution:
  deterministic: true
  numeric_mode: fixed_point
  precision_bits: 16
```

---

### 11.2 Execution Semantics

* Deterministic execution is REQUIRED
* Numeric modes MUST be explicit
* Precision MUST be declared
* Hardware and software MUST agree on semantics

---

## 12. Validation Rules

A CAS-YAML document is valid only if:

* All includes resolve successfully
* No cyclic includes exist
* All variables are uniquely named
* All constraint references are valid
* Degrees of freedom are consistent
* Projection and execution parameters are declared

Invalid documents MUST be rejected prior to execution.

---

## 13. Normative Examples

### 13.1 Synthetic Log Telemetry Model

A complete, conformant CAS-YAML model for telemetry and logging applications is provided as:

* **CAS-Example-Synthetic-Log.yaml** (this specification directory)

This model demonstrates:

* A simple 4-variable state (t_seconds, user, action, status)
* Explicit degrees of freedom declaration
* Time-bounds constraint
* Fixed-point numeric execution
* Integration with CPSC binary format

**Reference implementation**: The `cpsc-python` repository provides a canonical implementation of this model:

* Pipeline: `cpac/scripts/run_synthetic_log_cpsc_model.py`
* Binary format: `cpsc/binary_format_demo.py`
* Test suite: `cpsc/test/test_binary_format_synthetic_log.py`

This pipeline implements the Stage A/B/C pattern described in provisional patent embodiment E-11.8 (Telemetry, Logging, and Replay) and E-11.10 (CPAC Core Compression Pipeline).

---

## 14. Relationship to CPSC Core Specification

CAS-YAML defines the **declarative model** consumed by a CPSC execution engine.

The execution semantics, projection mechanics, and system behavior are defined in:

* **CPSC-Specification.md**

CAS-YAML does not redefine those semantics.

---

## 15. Design Rationale (Informational)

CAS-YAML is intentionally:

* not a programming language
* not a solver description
* not a scheduling format

It exists to describe **what must be true**, not how to compute it.

---

## 16. Summary

CAS-YAML provides a portable, deterministic, and composable way to describe constraint-based systems for CPSC. By separating declarative system definition from execution mechanics, CAS-YAML enables reuse across domains, implementations, and hardware targets.

This document is the authoritative specification for CAS-YAML.

---

**CAS-YAML-Specification.md** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
