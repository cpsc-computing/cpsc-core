# Patents – CPSC / CPAC

This directory contains **legal disclosure documents** related to patent protection
for the Constraint-Projected State Computing (CPSC) paradigm and its applications,
including Constraint-Projected Adaptive Compression (CPAC).

⚠️ **IMPORTANT**
- Documents in this directory are **not specifications**
- They are **not normative**
- They must **not** be treated as implementation requirements
- Specifications live under `docs/specification/`

Patent documents exist solely to:
- establish priority dates,
- disclose inventions for patent protection,
- support future non-provisional and continuation filings.

---

## Current Filings

### CPSC-CPAC-Provisional-2026-01

**Status:** FILED  
**Jurisdiction:** United States  
**Type:** Provisional Utility Patent Application  

**Title:**  
Constraint-Projected State Computing Systems, Semantic System Specification, and Applications

**Scope (High-Level):**
- CPSC as a new computing paradigm
- CPAC as a structural compression and enforcement layer
- Semantic system specification and deterministic lowering into constraint architectures
- Deterministic constraint projection
- Hardware and software embodiments
- Security, control, AI governance, and mission-critical systems
- Constraint-projected execution, verification, and governance of post-quantum cryptographic algorithms, including NIST-selected ML-DSA, SLH-DSA, and ML-KEM, using minimal degree-of-freedom representations of cryptographic state
- Quantum resource governance, validation, migration, and hybrid compression embodiments
- Validation-only recursion-stability

**Filing Artifacts:**
- Markdown source: `CPSC-CPAC-Provisional-2026-01.md`
- Filed PDF: `filing-records/CPSC-CPAC-Provisional-63-980251-FILED-2026-02-11.pdf` (authoritative)
- Draft PDF: `docs-pdf/patents/CPSC-CPAC-Provisional-2026-01.pdf` (working copy)

**Official Filing Metadata:**
- **USPTO Application No.:** `63/980,251`
- **Filing Date:** February 11, 2026
- **Entity Status:** Small
- **PDF SHA-256 Hash:** `A6D0754B370430DEADF2BC63D33E80E7D4BB3D15B86AFDE2E904C5B4E0FEA75D`
- **Git Commit SHA:** `bec7622`

The Markdown and filed PDF corresponding to this provisional are now **immutable**.
Any corrections or extensions require a new provisional or non-provisional filing.

---

## Versioning and Immutability Policy

- Filed patent documents are **frozen**
- No edits after filing
- Corrections or extensions require:
  - a new provisional, or
  - a non-provisional / continuation filing

New ideas discovered after filing must be recorded in:
- a new provisional document, or
- internal notes awaiting future filings

---

## Relationship to Repository License

The repository license governs:
- source code
- specifications
- documentation

The license does **not** grant patent rights.

Patent rights are governed solely by filed patent applications
and any issued patents.

---

## Internal Use Only

This directory is intended for:
- IP tracking
- internal planning
- legal coordination

It should remain **private** unless and until disclosure is required.

---

## MCP-Backed Prior Art and Background Tools

For non-normative background research, contributors MAY use external MCP servers
backed by USPTO data, in particular:

- the `patents` MCP server (`patent_mcp_server` from riemannzeta) for PPUBS full-text
  search and PatentsView/ODP/Office Action/Litigation tooling; and
- the John Walkoe USPTO MCP servers described in `WARP.md` §14 (PTAB, Patent
  File Wrapper, Final Petition Decisions, and Enriched Citations).

These tools are intended to support:
- prior-art and background searches over PPUBS full-text patents/applications,
- prior-art and background searches over PTAB decisions and appeals,
- review of prosecution history and office actions via the Patent File Wrapper API,
- analysis of petition outcomes via the Final Petition Decisions API,
- citation-based landscape and relationship analysis via the Enriched Citation API.

### Theme A – recorded prior-art notes (non-normative)

The following notes record non-normative observations about adjacent art for Theme A (CPSC paradigm). They are for internal reasoning only and are not part of any claim set.

- **ML-based safety / governance controllers (example: clinician hazardous behavior + wasting station)**
  - Representative independent claim pattern:
    - Use a machine-learning model with on-duty/off-duty states over transaction logs to identify a clinician shift.
    - Determine, based on the shift, that a clinician is a candidate for hazardous behavior.
    - Configure a physical control system (e.g., a wasting station) to behave differently (isolate returned substance) for flagged clinicians.
  - Overlaps with Theme A:
    - ML-informed risk scoring and domain-specific safety control.
    - Closed-loop actuation from model inference to physical system behavior.
  - Gaps relative to Theme A / CPSC:
    - No explicit constraint-structured control plane orchestrating multiple heterogeneous components under a shared constraint program.
    - No first-class constraint structure (graph/lattice/hierarchy) or multi-constraint reasoning; only an implicit rule of the form "if risk, then isolate." 
    - No constraint-centric state model (active/satisfied/violated constraints) or constraint-based justification artifacts.
    - No separation between a configurable constraint program/policy layer and the underlying ML model/infrastructure.

- **Safety controllers for automated vehicles (example: US 10,234,871 B2 – distributed safety monitors for automated vehicles)**
  - Representative independent claim pattern (informal):
    - Provide a vehicle controller that generates vehicle control commands for at least partially automated driving (e.g., platooning), based on sensor information.
    - Provide one or more safety monitoring algorithms (implemented on separate safety hardware) that, during automated driving, verify selected vehicle control commands against safety criteria using sensor data from the host and/or a second vehicle.
    - Gate or override the application of those vehicle control commands to vehicle actuators (braking, torque, etc.) based on the safety-monitor outcomes.
    - Implement an ASIL-oriented controller architecture that partitions the main controller, safety monitors, and vehicle interface hardware.
  - Overlaps with Theme A:
    - Explicit separation between a "primary" control stack and a safety-monitoring layer that can block or override unsafe commands.
    - Use of multiple heterogeneous signals (sensors, vehicle state, possibly partner-vehicle state) to enforce safety properties over an automated control loop.
    - Architecture intended for high-integrity, mission-critical vehicle control rather than a narrow consumer app.
  - Gaps relative to Theme A / CPSC:
    - Safety monitors are engineered controllers and algorithms, not first-class **constraint structures** (graphs/lattices/hierarchies) that define a generalized constraint plane over heterogeneous systems.
    - No single, semantic constraint program governing multiple components; the design is specific to platooning / vehicle longitudinal control rather than a generalized CPSC-style control plane.
    - No constraint-centric state model (e.g., active/satisfied/violated constraints) or canonical justification artifacts that explain why a command is accepted or rejected in a constraint language.
    - No separation between an abstract constraint program and the underlying control implementation (vehicle controllers, ECUs, ASIL hardware) in the way CPSC treats constraint programs as independent from model weights and infrastructure.

These gaps are candidates for strengthening Theme A independent claims along the axes of (i) explicit constraint structures and constraint-structured control planes that can subsume safety-monitor architectures, (ii) a generalized, heterogeneous control plane rather than a single-domain controller, and (iii) constraint-centric justification artifacts and state models that go beyond "monitor and block unsafe commands" patterns.

### Theme H – recorded prior-art notes (non-normative)

The following notes are reserved for Theme H (Constraint-Projected Cryptographic State and Post-Quantum Verification). They are intended to capture non-normative observations about adjacent art where:

- post-quantum cryptographic artifacts (for example, signatures or ciphertexts) are compressed or reduced in size;
- only randomness or entropy associated with such artifacts is stored or transmitted, with full artifacts reconstructed later; or
- cryptographic verification is expressed as constraint satisfaction or satisfiability over an explicit cryptographic state, rather than as purely procedural verifier code.

Theme H notes SHOULD emphasize whether prior art does or does not:

- define an explicit cryptographic state manifold with independent vs. derived variables;
- define deterministic projection onto that manifold as the locus of cryptographic correctness; or
- couple cryptographic state with compression or transport via degree-of-freedom representations.

They MUST NOT be treated as authoritative or complete. Any search results should
be validated against official USPTO search tools or commercial equivalents, and
legal conclusions MUST be made by a qualified practitioner.

See `WARP.md` §14 for setup details and MCP JSON configuration examples.

---

## Preparing draft PDFs

For local preparation of draft PDFs (for example, generating a PDF version of
`CPSC-CPAC-Provisional-2026-01.md` before filing), contributors SHOULD use the
Python-based `md2pdf` CLI provided by the `md2pdf-mermaid` package. This tool
renders Markdown to PDF using an HTML/Chromium engine and includes built-in
support for Mermaid diagrams.

You can either call `md2pdf` directly or use the helper scripts in the `scripts/` directory.

### 1. One-time setup (Python environment)

From the repository root (or any Python environment you prefer):

- Install the renderer and its browser dependency:

  - `pip install md2pdf-mermaid playwright`
  - `python -m playwright install chromium`

This installs the `md2pdf` command and downloads a local Chromium build used for
HTML-to-PDF conversion.

You MAY instead run:

- Windows: `pwsh -File setup.ps1 -RenderTools`
- Linux/macOS: `bash setup.sh --render-tools`

This installs `md2pdf-mermaid` and the required Playwright Chromium runtime into the selected Python environment (`python` by default).

### 2. Rendering the provisional to PDF

From the repository root, you MAY run `md2pdf` directly:

- `md2pdf docs/patents/CPSC-CPAC-Provisional-2026-01.md -o docs-pdf/patents/CPSC-CPAC-Provisional-2026-01.pdf`

or use the helper scripts:

- Windows: `pwsh -File scripts/render-docs-pdf.ps1`
- Linux/macOS: `bash scripts/render-docs-pdf.sh`

This will:

- parse the Markdown provisional,
- render Mermaid diagrams (including the figures at the end of the document), and
- produce a PDF at `docs-pdf/patents/CPSC-CPAC-Provisional-2026-01.pdf`.

The render scripts also support a test mode to verify Mermaid rendering without touching the provisional:

- Windows: `pwsh -File scripts/render-docs-pdf.ps1 -TestDiagrams`
- Linux/macOS: `bash scripts/render-docs-pdf.sh --test-diagrams`

### 3. Notes

- This tooling is provided for convenience only and does not modify the legal
  status of any document. The filed PDF and associated USPTO records remain the
  authoritative artifacts.
- The choice of renderer (md2pdf-mermaid vs. other tools) does not affect the
  semantics or priority date of the filing; it only affects the local draft
  formatting used for review.

---

**Patents Documentation README** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
