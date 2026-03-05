# Constraint-Projected State Computing (CPSC)

**Core specifications for the CPSC computing model**

Constraint-Projected State Computing (CPSC) is a declarative computing model in which
computation is performed by projecting system state onto explicit constraints,
rather than executing ordered instructions.

CPSC provides a foundation for deterministic, constraint-driven systems across
software, compression, control systems, and hardware (FPGA / ASIC).

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/cpsc-computing/cpsc-core)
[![License](https://img.shields.io/badge/license-Research%20%26%20Evaluation-orange.svg)](LICENSE)

> ⚠️ **Status:** Research & Evaluation | **License:** CPSC Research & Evaluation License v1.0  
> This repository is released for non-commercial research, evaluation, and educational purposes only. Commercial use requires a separate license. See LICENSE for full terms.

---

## What This Organization Hosts

This organization contains:

- The **CPSC technical specification**
- Declarative constraint models (CAS-YAML)
- Reference documentation and examples
- Licensing and governance materials
- Future reference implementations

The specification is the primary source of truth.

---

## Why CPSC Exists

Many real-world systems are governed by strong rules:
- physical limits
- protocol invariants
- safety constraints
- structural relationships

Traditional instruction-based computing handles these indirectly,
often resulting in complex control logic, tuning, and fragile edge cases.

CPSC makes **constraints the primary abstraction**.

---

## Core Concepts

- **State** — the full configuration of a system
- **Constraints** — rules defining valid states
- **Projection** — resolving state into validity
- **Degrees of Freedom** — minimal independent information
- **Constraint Fabric** — parallel enforcement of rules

---

## Applications

CPSC is applicable to:

- Semantic and structure-aware compression
- Streaming and edge data reduction
- Power electronics and control systems
- Deterministic AI inference pipelines
- FPGA and ASIC acceleration
- Secure state reconstruction
- Protocol enforcement and validation

---

## Status

CPSC is currently in the **specification and early reference phase**.

The specification is released for research and evaluation.
Reference implementations will follow.

---

## Patent and prior-art research

This organization maintains a separate `docs/patents/` directory for non-normative patent and IP materials related to Constraint-Projected State Computing (CPSC) and Constraint-Projected Adaptive Compression (CPAC).

- Documents under `docs/patents/` are **legal disclosure and planning artifacts**, not specifications.
- A non-normative **prior-art search protocol** for CPSC/CPAC Themes A and B (paradigm-level computing model and DoF-based compression) is maintained there, together with a simple ledger structure for recording what has been searched and when.
- Contributors using Warp and the local `patent_mcp_server` MCP backend MAY follow this protocol to run reproducible prior-art and landscape searches using USPTO-backed APIs (PPUBS, PatentSearch/PatentsView), but results remain informational only.
- Standard chat commands beginning with `prior-art protocol:` (documented in `WARP.md` and `AGENTS.md`) provide a repeatable way to ask agents to execute or summarize these searches; they do **not** change the meaning of any specification.

### Patent draft rendering helpers

For local draft PDFs of the CPSC/CPAC provisional (including Mermaid figures),
this repository provides:

- A Python wrapper script: `scripts/render_markdown_to_pdf.py`
- PowerShell helper: `scripts/render-docs-pdf.ps1`
- Bash helper: `scripts/render-docs-pdf.sh` (Linux/macOS)

To install PDF rendering tools, run `./setup.ps1 -RenderTools` (Windows) or `./setup.sh --render-tools` (Linux/macOS).

These are convenience tools around the `md2pdf` CLI from the `md2pdf-mermaid`
package and use a headless Chromium engine to render Markdown (with Mermaid
blocks) to PDF. They do not change the legal status or semantics of any
document; they only control local formatting for review.

### USPTO / PatentSearch API keys and environment variables

To use the MCP-backed patent tools with live USPTO data, contributors MUST obtain and configure API keys outside this repository:

1. **USPTO Open Data Portal API key (`USPTO_API_KEY`)**
   - Create or sign in to a MyUSPTO account at `https://my.uspto.gov/`.
   - Visit the USPTO Open Data Portal at `https://data.uspto.gov/home`.
   - Use the key management page at `https://data.uspto.gov/myodp/key-reveal` to generate or reveal your Open Data Portal API key.
   - Store the key as a user-level environment variable so it is available as `$env:USPTO_API_KEY` (for example, using the PowerShell instructions in `WARP.md` §14.2), or in a local `.env` file consumed by `patent_mcp_server`.

2. **PatentsView / PatentSearch API key (`PATENTSVIEW_API_KEY`)**
   - Request a PatentsView PatentSearch API key via the official support portal at `https://patentsview-support.atlassian.net/servicedesk/customer/portal/1/group/1/create/18`.
   - General PatentsView information is available at `https://patentsview.org/home`.
   - Once issued, store the key so it is available to tools as `$env:PATENTSVIEW_API_KEY` (for example, as a user-level environment variable or in a local `.env` file that `patent_mcp_server` reads).

3. **Security and repository hygiene**
   - API keys MUST NOT be committed to this repository in any form (no checked-in `.env` files, scripts, or JSON containing secrets).
   - MCP configuration examples in `WARP.md` and related scripts are designed to read keys from the environment (`USPTO_API_KEY`, `PATENTSVIEW_API_KEY`) rather than from tracked files.

All patent-related work must respect the repository’s licensing and IP reservations. Patent rights are governed solely by filed applications and issued patents, not by this repository or any MCP-backed tooling.

---

## Licensing

The CPSC specification and related documents are released under the
**CPSC Research & Evaluation License**.

- Non-commercial research, evaluation, and educational use is permitted
- Commercial use requires a separate license

For a plain-language explanation, see `LEGAL-FAQ.md`.

---

## Getting Started

1. Read `docs/specification/CPSC-Specification.md` (core computation model)
2. Read `docs/specification/CPSC-Engine-Modes-Specification.md` (Iterative and Cellular projection engines)
3. Read `docs/specification/CPSC-Adaptive-Engine-Specification.md` (auto-detecting meta-engine)
4. Review CAS-YAML examples under `docs/specification/`
5. Consult `docs/LEGAL-FAQ.md` for licensing guidance

---

## Agent Quick Start

This repository supports AI agent workflows with session commands.

When starting a new conversation with an AI agent (Warp, Claude, etc.) in this
repository, use the following prompt to establish context:

```
You are in the cpsc-core repository (CPSC specification). First read AGENTS.md
and WARP.md, then execute the load session command as defined in AGENTS.md.
```

On startup, an agent SHOULD:
1. Execute `load session` (read `AGENTS.md`, `WARP.md`, `docs/LEDGER.md`)
2. Show context summary and current TODO list
3. Wait for user to confirm or choose a task

For full agent conventions and session behavior, see `AGENTS.md`.

---

## Contact

For research questions, discussion, or licensing inquiries,
contact BitConcepts, LLC.

---

**CPSC Specifications v1.0.0** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
