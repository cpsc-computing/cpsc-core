# CPSC Binary Format to RTL Mapping
## Hardware Signal-Level Interpretation

**Version:** 1.0  
**Status:** Normative Implementation Guidance  
**Published:** January 17, 2026  

---

## License Notice

This document is released under the CPSC Research & Evaluation License.

It may be used, shared, and cited for non-commercial research, evaluation, and educational purposes.
Commercial use, production deployment, or implementation in commercial systems requires a separate license.

The technology described herein may be subject to patent protection.
All rights are reserved.

---

## 1. Purpose

This document defines a **direct, unambiguous mapping** between the CPSC Binary Format
and RTL-level hardware signals.

Its purpose is to allow an engineer to implement:
- a CPSC binary decoder,
- a hardware reconstruction pipeline,
- and a constraint projection interface

using only this document and the core specifications.

This document does not define constraint logic internals.

---

## 2. Architectural Overview

A hardware implementation of the CPSC binary decoder naturally forms a linear pipeline:

```

Byte Stream In
↓
Header Parser
↓
Metadata Loader
↓
Stage Table Decoder
↓
Degree-of-Freedom Loader
↓
Residual Decoder (optional)
↓
CPSC Constraint Fabric

```

All stages operate without instruction sequencing or a general-purpose controller.

---

## 3. Header Mapping

### 3.1 Binary Header Fields

| Field | Size | RTL Signal | Width |
|-----|-----|-----------|------|
| Magic | 4 bytes | hdr_magic | 32 |
| Format Version | 2 bytes | hdr_version | 16 |
| Flags | 2 bytes | hdr_flags | 16 |
| Endianness | 1 byte | hdr_endian | 1 |
| Numeric Mode | 1 byte | hdr_numeric_mode | 8 |
| Reserved | 6 bytes | hdr_reserved | 48 |

### 3.2 RTL Semantics

- Header is parsed using a fixed-length shift register
- Validation occurs before downstream stages are enabled

```

header_valid =
(hdr_magic == 0x43505343) &&
(hdr_version <= SUPPORTED_VERSION) &&
(hdr_reserved == 0)

```

---

## 4. Model Metadata Mapping

| Binary Field | Size | RTL Signal | Width |
|-------------|------|-----------|------|
| Model ID Hash | 32 bytes | model_id_hash | 256 |
| CAS Hash | 32 bytes | cas_hash | 256 |
| DoF Count | 4 bytes | dof_count | 32 |
| Precision Bits | 2 bytes | precision_bits | 16 |
| Reserved | 2 bytes | meta_reserved | 16 |

These fields are loaded into static registers and used for:
- compatibility checks
- configuration of downstream arithmetic
- validation prior to projection

---

## 5. Stage Table Mapping

Each stage entry is reduced in hardware to a bitmask:

```

stage_enable[STAGE_ID] = 1

```

| Field | Size |
|-----|-----|
| Stage ID | 2 bytes |
| Stage Flags | 2 bytes |
| Reserved | 4 bytes |

The stage table enables:
- static datapath selection
- bypass of unused blocks
- forward compatibility

---

## 6. Degree-of-Freedom Vector Mapping

### 6.1 RTL Representation

```

reg signed [PRECISION-1:0] dof_regs [0:N_DOF-1];

```

### 6.2 Semantics

- Order is defined by CAS-YAML
- Width is defined by `precision_bits`
- Numeric interpretation is defined by `hdr_numeric_mode`
- Registers directly drive the constraint fabric

This section is fixed-size once the model is known.

---

## 7. Residual Stream Mapping

Residuals are optional and streamable.

```

residual_valid
residual_value[PRECISION-1:0]

```

Residuals are:
- applied before projection
- bounded by constraints
- injected additively or via declared method

Residual decoding MUST NOT violate constraints.

---

## 8. Constraint Fabric Interface

### Inputs

- `dof_regs[]`
- `residual_value`
- `stage_enable`
- `precision_bits`
- `numeric_mode`

### Outputs

- `state_valid`
- `state_regs[]`

The constraint fabric may be:
- combinational
- iterative
- pipelined

As long as determinism is preserved.

---

## 9. FSM Requirements

Only a single linear FSM is required:

```

IDLE
→ READ_HEADER
→ READ_METADATA
→ READ_STAGE_TABLE
→ READ_DOF
→ READ_RESIDUAL (optional)
→ PROJECT
→ DONE

```

No nested FSMs or dynamic branching are required.

---

## 10. Hardware Properties

- No dynamic memory allocation
- No recursion
- No instruction decoding
- Fixed control paths
- Fully synthesizable
- Stream-friendly

---

## 11. Summary

The CPSC binary format maps directly to RTL as a sequence of fixed-width registers and simple FSM-controlled loaders feeding a constraint projection fabric. This design enables deterministic, low-latency, and hardware-native reconstruction of CPSC state without a CPU.

---

**Binary-Format-RTL-Mapping.md** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
