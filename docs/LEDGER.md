CPSC / CPAC Patent Work Ledger
===============================

This file records high-level steps completed and the next concrete action for Theme-based prior-art and claim-structuring work. It is non-normative and for internal coordination only.

---

Theme A – CPSC paradigm (Constraint-Structured Control Plane)
--------------------------------------------------------------

Completed so far:
- Defined Theme A and drafted proto independent claims (system, method, medium) for a constraint-structured control plane with:
  - explicit constraint structures (graph/lattice/hierarchy),
  - a generalized control plane orchestrating heterogeneous components (ML + non-ML),
  - constraint state tracking and constraint-centric justification artifacts,
  - governance behavior configurable by editing constraint programs without retraining models.
- Refined the Theme A system proto-claim to emphasize:
  - explicit representation of constraints and their relationships,
  - heterogeneous components under a single constraint program,
  - separation of constraint program from model weights/parameters.
- Analyzed one concrete comparator patent (ML-based clinician hazardous behavior + wasting station) and recorded a short prior-art note under `Theme A – recorded prior-art notes (non-normative)` in `patents/README.md`, including:
  - representative claim pattern,
  - overlaps with Theme A (ML-informed risk scoring, closed-loop actuation),
  - gaps relative to Theme A (no generalized constraint plane, no first-class constraint structure, no justification artifacts, no separable constraint program).
- Analyzed a second comparator in the automated-vehicle safety-controller family (US 10,234,871 B2 – distributed safety monitors for automated vehicles) and added a non-normative Theme A prior-art note in `patents/README.md` capturing its representative claim pattern, overlaps (safety monitors gating an automated control loop, ASIL-oriented architecture), and gaps relative to CPSC (no explicit constraint-structured control plane, no generalized constraint program, no constraint-centric state/justification artifacts).
- Integrated a concrete proto-cell / epoch-controller hardware fabric embodiment and the CAS-YAML → CPSC Binary → hardware configuration path into the CPSC specification under `docs/specification/`, and updated `docs/public/cpsc-overview.md` to use the proto-cell/epoch fabric as a canonical CPSC hardware example while fixing several stray encoding artifacts in that document.
- Later refined the public CPSC overview text to remove an obsolete reference to "ConvergeCore" while preserving the proto-cell / epoch-controller embodiment as an example linked to the Deterministic Developmental Fabric (DDF), and regenerated the corresponding `docs-pdf/public/cpsc-overview.pdf` artifact.

Next action for Theme A (resume point):
- Consolidate the Theme A differentiation story across the clinician hazardous-behavior controller and the distributed safety-monitor architecture into a short, internal claim-structuring note (non-normative) that identifies the key architectural axes where CPSC departs from traditional safety controllers (generalized constraint plane, explicit constraint structures, constraint-centric state/justification artifacts, separable constraint program).
- Defer any further Theme A claim edits until that note exists and has been reviewed alongside the current CPSC-CPAC provisional draft.

---

How to use this ledger when resuming work:
- For each Theme (A–G), there should be at most one "Next action" block that represents the current resume point.
- When you resume work on a Theme, read that Theme's "Next action" block, perform the action, then MOVE those bullets into the "Completed so far" list for that Theme and replace the "Next action" block with the *new* concrete next step (or remove it if that Theme is complete).
- Keep this file in sync with non-normative notes in `patents/README.md` and related Theme documentation, but do NOT move Theme content here; this file is for sequencing and coordination, not for substantive patent text.

Session note – USPTO PFW MCP proxy port conflict
------------------------------------------------
- Date: 2026-01-23
- Context: Local testing of `uspto_pfw_mcp` after merging async lifecycle fixes into `master`.
- Observation: MCP server initialized correctly, but HTTP proxy failed to bind on ports 8080 and 8081 with `WinError 10048` ("only one usage of each socket address...") indicating other processes were already holding those ports.
- Status: Treated as an environmental/temporary port conflict; no changes made to server code or default proxy port (kept at 8080). Future sessions should assume the implementation is good and resolve port usage at the OS level if the error recurs.

Session note – VLBI performance update and PDF rendering fixes
--------------------------------------------------------------
- Date: 2026-02-10
- Context: Updated CPAC embodiment performance claims and fixed image rendering in public documentation PDFs.
- Changes completed:
  - Updated CPAC VLBI performance claim from 1.51x to 3.0x-4.0x improvement with validation note "based on real-world VLBI observatory logs" in provisional patent (line 406).
  - Fixed image links in public overview documents (`cpsc-overview.md`, `pqc-overview.md`) to use relative paths (`images/...`) instead of absolute `file:///` paths for proper GitHub rendering.
  - Enhanced PDF generation script (`render_markdown_to_pdf.py`) to create temporary working files with absolute image paths, ensuring images are embedded in generated PDFs.
  - Removed obsolete `patents/figures/mermaid-test.pdf` and empty figures directory.
  - Regenerated all documentation PDFs (19 files) with properly embedded images, confirmed by increased file sizes (e.g., cpsc-overview.pdf: 101 KB → 1191.7 KB).
- Artifacts: Commit `71cd6ee` pushed to `main`.

Session note – Specification session complete (February 15, 2026)
-----------------------------------------------------------------
- Date: 2026-02-15
- Context: Session completing new engine specifications and documentation updates.
- Specifications added/updated:
  1. **CPSC-Engine-Modes-Specification.md** — Multi-topology expansion complete (Grid1D/2D, GraphGrid, Toroidal, MajorityRule, IdentityRule)
  2. **CPSC-Adaptive-Engine-Specification.md** — New meta-engine spec with auto-detection
- Cross-references updated: WARP.md, AGENTS.md, README.md, CPSC-Specification.md, CPSC-Implementation-Governance.md, cpsc-embodiments-overview.md
- Implementation: Deferred to `cpsc-engine-python` repository (not this spec repo)
- Outstanding prior-art work: Themes B–G remain placeholder; prior-art searches to be scheduled separately
- Status: Session saved.

---

Session note – CPSC Adaptive Engine Specification added (February 15, 2026)
---------------------------------------------------------------------------
- Date: 2026-02-15
- Context: New normative specification for unified meta-engine with auto-detection.
- New document: `docs/specification/CPSC-Adaptive-Engine-Specification.md` (v1.0, Draft)
- Summary: Defines **AdaptiveEngine** meta-engine that:
  - Analyzes CAS model constraint graph structure
  - Auto-detects optimal solving strategy (Iterative vs Cellular)
  - Introduces `projection.strategy` CAS-YAML field (`auto`, `iterative`, `cellular`, `hybrid`)
  - Respects priority: API override > CAS-YAML hint > auto-detection
  - Returns strategy selection reasoning in `ProjectionResult.details`
- Key components: ConstraintGraph analysis, detection heuristics (grid locality, sparse linear, global constraints)
- Cross-references: CPSC-Specification.md §5/§6, CAS-YAML-Specification.md §10, CPSC-Engine-Modes-Specification.md §3/§4
- Status: Draft specification, committed.

---

Session note – CPSC Engine Modes Specification expanded (February 15, 2026)
---------------------------------------------------------------------------
- Date: 2026-02-15
- Context: Major expansion of Engine Modes spec with multi-topology and multi-rule support.
- Updated document: `docs/specification/CPSC-Engine-Modes-Specification.md`
- Changes:
  - **Grid Protocol** (§4.2.2a): Topology-agnostic interface with `get_neighbors()` returning variable-length neighbor lists
  - **Grid Implementations** (§4.2.2b): Grid1D, Grid2D, GraphGrid, ToroidalGrid1D, ToroidalGrid2D
  - **New Local Rules**: MajorityRule (majority voting), IdentityRule (passthrough), in addition to PropagationRule
  - **Engine Configuration**: Extended with `grid_type`, `rule_type`, `connectivity` parameters
  - **Hardware Considerations** (§4.3.7): Multi-topology wiring, 2D neighbor routing, toroidal boundaries
  - **Test Vectors** (§9.3): Added Grid2D, GraphGrid, ToroidalGrid1D, Grid2D+MajorityRule scenarios
- Status: Draft specification, committed.

---

Session note – CPSC Engine Modes Specification added (February 15, 2026)
------------------------------------------------------------------------
- Date: 2026-02-15
- Context: New normative specification added for CPSC projection engine modes.
- New document: `docs/specification/CPSC-Engine-Modes-Specification.md` (v1.0, Draft)
- Summary: Defines two projection engine modes for CPSC:
  1. **Iterative Engine** — Global constraint evaluation with numerical iteration (gradient/Newton methods)
  2. **Cellular Engine** — Local rule evaluation with neighbor-based self-organization (proto-cell fabric)
  - Both software and hardware (RTL/VHDL) embodiments specified
  - Introduces **DLIF** (Degrees-of-freedom Line-In Format) as streaming element format for Cellular Engine
  - Includes reference local rule (PropagationRule) matching DDF ARCHITECTURE.md §4.4
  - Cross-references: CPSC-Specification.md §5/§6/§7/§12, CAS-YAML-Specification.md §7/§8/§10, Binary-Format-Specification.md, Binary-Format-RTL-Mapping.md
- Supporting artifact: `docs/specification/CAS-Example-Synthetic-Log.yaml` (reference CAS model for testing)
- Updates required: README.md, CPSC-Specification.md §15, CPSC-Implementation-Governance.md §1, cpsc-embodiments-overview.md
- Status: Draft specification, committed.

---

Session note – Documentation harmonization and repository reorganization (February 19, 2026)
-------------------------------------------------------------------------------------------------
- Date: 2026-02-19
- Context: Applied canonical documentation standards and consolidated repository setup scripts for cross-platform support.
- Changes completed:
  - **Documentation Standards Harmonization**: Applied copyright headers (SPDX ID: LicenseRef-CPSC-Research-Evaluation-1.0) to 6 scripts (2 Python, 4 PowerShell); added/fixed copyright footers on 31 documentation files across docs/, docs/specification/, docs/public/, and docs/patents/; created docs/DOCUMENTATION_CHECKLIST.md as quick reference.
  - **Repository Reorganization**: Moved scripts/.venv to .work/env for standardized location; removed unused files (scripts/__pycache__/, debug-patentsview.ps1, cgad_check.py, and JSON artifacts); consolidated setup-render-docs-env.ps1 and setup-ptab-mcp-for-warp.ps1 into unified setup.ps1 with parameters (-RenderTools, -UsptoMcp); moved setup.ps1 to repository root.
  - **Cross-Platform Support**: Created setup.sh (bash version for Linux/macOS); created scripts/render-docs-pdf.sh (bash version); fixed line endings (CRLF → LF) for bash scripts; updated documentation references in README.md, WARP.md, docs/patents/README.md.
  - **Enhanced .gitignore**: Added patterns for .work/, __pycache__/, *.pyc, venv/, and IDE artifacts.
  - **Testing**: Verified all scripts (PowerShell and bash) with syntax checks, help output, and Python import tests.
- Status: Complete. All changes committed and tested.
- Commits: 1d96f1a (documentation standards), 0393aae (headers/footers), be11059 (reorganization), fd12bc3 (cleanup/line endings)

---

Session note – Provisional patent filing preparation (February 11, 2026)
-----------------------------------------------------------------------
- Date: 2026-02-11
- Context: Final preparation and consistency check for CPSC-CPAC provisional patent filing.
- Changes completed:
  - Updated all provisional patent references across documentation to use consistent format: full title "Constraint-Projected State Computing Systems, Semantic System Specification, and Applications", Application No. 63/XXX,XXX, filing date February 2026.
  - Updated `docs/patents/non-provisional-outline.md` cross-reference with complete title and 2026-02-XX filing date placeholder.
  - Updated `docs/patents/executive-summary.md` to include explicit provisional reference with full metadata.
  - Updated `docs/patents/internal-ip-playbook.md` filename reference from YYYY-MM to 2026-01.
  - Updated `docs/patents/README.md` provisional title to include "Semantic System Specification, and" and changed filing date to February 2026.
  - Updated `docs/public/cpsc-embodiments-overview.md` to include full provisional citation.
  - Updated `docs/public/pqc-tech-overview-for-grants.md` with complete provisional reference.
  - Updated `docs/patents/CPSC-CPAC-Provisional-2026-01.md` filing date from "TBD" to "February 11, 2026".
  - Verified alignment between provisional Section 11.13.5 PQC embodiments and `docs/public/pqc-overview.md` (provisional explicitly references the three-layer architecture described in public overview).
  - Regenerated provisional PDF (897.0 KB) with embedded Mermaid diagrams and updated filing date.
  - Applied 6 comprehensive hardening passes addressing §101 risk, enablement vulnerabilities, indefiniteness, overstatement, and argumentative language (33 precision refinements total):
    * Pass 1 (commit c459c07): Formal convergence definition, canonical valid state rules, numeric precision declarations, SAT/SMT distinction, §101 structural improvements, CPAC performance qualifiers, quantum/neuromorphic examples, side-channel clarifications, marketing language removal.
    * Pass 2 (commit fc6d5e6): CPAC performance language softening, "Constraint-Enforced Under Declared Constraints" terminology, global architectural improvement qualifier.
    * Pass 3 (commit 56f06f3): Early CPAC performance conditioning, SAT/SMT embodiment qualifiers, malware false-positive softening, global scope clarifier in Section 12.
    * Pass 4 (commit 570723b): Section 12 typographical corrections, "higher compression ratios" softening, "fundamentally" removal, "avoidance" terminology, hardware embodiment conditioning.
    * Pass 5 (commit 721777a): Critical Section 12 encoding artifact fix (`\`n\`n` malformed text).
    * Pass 6 (commit 8a152fc): Ultra-conservative "reduced false-positive detection" language in Section 11.14.10.
  - Fixed PDF generator to enforce US Letter (8.5" x 11") page size via `--page-size letter` flag (commit b83e6a9).
  - Regenerated all 20 documentation PDFs with correct US Letter dimensions for USPTO EFS-Web compliance.
  - Final provisional PDF: 903.3 KB at US Letter format.
- Status: **FILED** - Provisional patent application submitted to USPTO via EFS-Web.
- Official Filing Metadata:
  - USPTO Application No.: **63/980,251**
  - Filing Date: **February 11, 2026**
  - Entity Status: **Small**
  - Filed PDF: `docs/patents/filing-records/CPSC-CPAC-Provisional-63-980251-FILED-2026-02-11.pdf`
  - PDF SHA-256 Hash: `A6D0754B370430DEADF2BC63D33E80E7D4BB3D15B86AFDE2E904C5B4E0FEA75D`
  - Git Commit SHA: `bec7622` (hardening completion)
- Next action: Monitor USPTO correspondence for official filing receipt and maintain 12-month non-provisional conversion deadline (February 11, 2027).

---

Theme B – CPAC representations / compression
-------------------------------------------

Completed so far:
- (placeholder) Theme B work not yet started in this ledger.

Next action for Theme B (resume point):
- Run an initial comparator search for CPAC-style structural / degree-of-freedom compression of signals or models (e.g., patents combining compression with explicit structure or constraints), pick one representative comparator, and record a short non-normative Theme B prior-art note in `patents/README.md`.

---

Theme C – Constraint-governed AI (governor / safety policy)
----------------------------------------------------------

Completed so far:
- (placeholder) Theme C work not yet started in this ledger.

Next action for Theme C (resume point):
- Identify one representative "AI safety governor" or "policy engine" patent (e.g., safety envelopes, runtime monitors for ML controllers), summarize its independent-claim pattern, and add a short non-normative Theme C prior-art note in `patents/README.md` focusing on how it does or does not treat constraints as first-class structures.

---

Theme D – Learned structure-induction & structural classes
---------------------------------------------------------

Completed so far:
- (placeholder) Theme D work not yet started in this ledger.

Next action for Theme D (resume point):
- Select one comparator in the "learned relational/graph structure" or "program synthesis / structure induction" family, and record a non-normative Theme D prior-art note in `patents/README.md` emphasizing how learned structure relates (or not) to explicit CPSC structural classes.

---

Theme E – Quantum / non-von-Neumann backends
--------------------------------------------

Completed so far:
- (placeholder) Theme E work not yet started in this ledger.

Next action for Theme E (resume point):
- Identify a representative quantum or non-von-Neumann accelerator/control architecture patent and record a short non-normative Theme E prior-art note in `patents/README.md` focusing on whether it exposes an explicit constraint or state-manifold model vs. hardware-centric pipelines.

---

Theme F – Cryptographic / PQC governance
----------------------------------------

Completed so far:
- (placeholder) Theme F work not yet started in this ledger.

Next action for Theme F (resume point):
- Use the existing `pqc-prior-art-notes.md` themes to pick one comparator for constraint-governed PQC posture/migration, and summarize it in a non-normative Theme F prior-art note in `patents/README.md` (separate from Theme H structural/compression work).

---

Theme G – Governance & validation harness
-----------------------------------------

Completed so far:
- (placeholder) Theme G work not yet started in this ledger.

Next action for Theme G (resume point):
- Define one comparator in the "validation harness / monitoring framework" space (e.g., safety-case or assurance-harness patents) and write a non-normative Theme G prior-art note in `patents/README.md` highlighting differences between ad hoc harnesses and a CPSC-style constraint-projected validation fabric.

---

**LEDGER.md** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
