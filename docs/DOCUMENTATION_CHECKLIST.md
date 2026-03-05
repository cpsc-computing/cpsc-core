# Documentation Standards Checklist
## .github Repository (CPSC Specifications)

This checklist provides quick-reference templates for copyright headers and footers specific to the `.github` canonical governance repository.

For complete documentation standards, see the canonical reference:
`C:\Users\trist\Development\BitConcepts\.github\docs\DOCUMENTATION_STANDARDS.md`

---

## Copyright Information

- **Copyright Year**: 2026 (NO year ranges)
- **Copyright Holder**: BitConcepts, LLC
- **License**: CPSC Research & Evaluation License v1.0
- **SPDX License Identifier**: LicenseRef-CPSC-Research-Evaluation-1.0
- **Project Name**: CPSC Specifications

---

## Copyright Header Templates

### Python Files (.py)

```python
#!/usr/bin/env python
# Copyright (c) 2026 BitConcepts, LLC
# SPDX-License-Identifier: LicenseRef-CPSC-Research-Evaluation-1.0
#
# This file is part of the CPSC Specifications.
# For full license terms, see LICENSE in the repository root.

"""Module docstring here."""
```

**Placement**: After shebang line (if present), before module docstring.

### PowerShell Scripts (.ps1)

```powershell
# Copyright (c) 2026 BitConcepts, LLC
# SPDX-License-Identifier: LicenseRef-CPSC-Research-Evaluation-1.0
#
# This file is part of the CPSC Specifications.
# For full license terms, see LICENSE in the repository root.

param(
    # parameters here
)
```

**Placement**: Before `param()` block at the top of the file.

---

## Copyright Footer Template

### Markdown Files (.md)

Add at the end of all markdown documentation files (except README.md and CONTRIBUTING.md which have specific custom footers):

```markdown
---

**[Document Title]** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
```

**Examples**:
- `**CPSC-Specification.md** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0`
- `**GLOSSARY.md** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0`
- `**Executive Summary** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0`

---

## File Categories

### Files Requiring Copyright Headers

**Scripts** (all have headers):
- `.py` files in `scripts/`
- `.ps1` files in `scripts/`

### Files Requiring Copyright Footers

**Documentation files** (all have footers):
- Root level: `CONTRIBUTING.md`, `README.md`
- `docs/*.md` (all markdown files)
- `docs/specification/*.md` (all specification files)
- `docs/public/*.md` (all public documentation)
- `docs/patents/*.md` (all patent materials)

### Files to Skip

- `.gitignore`, config files, data files
- Generated files in `docs-pdf/`
- Virtual environment files (`.venv/`, `.work/`)
- Repository metadata (`.git/`)

---

## Quick Checklist for New Files

When creating a new file in this repository:

- [ ] **Python script**: Add copyright header after shebang, before docstring
- [ ] **PowerShell script**: Add copyright header before `param()` block
- [ ] **Markdown doc**: Add copyright footer at end of file
- [ ] **Verify license**: Use CPSC Research & Evaluation License v1.0
- [ ] **Verify SPDX ID**: Use `LicenseRef-CPSC-Research-Evaluation-1.0`
- [ ] **Verify year**: Use 2026 (no ranges)
- [ ] **Verify project name**: "CPSC Specifications"

---

## Repository-Specific Rules

This repository is the **canonical governance repository** for CPSC specifications:

1. **Spec-First**: All work must follow WARP.md and AGENTS.md governance rules
2. **Normative vs Non-Normative**: 
   - Normative content: `docs/specification/`
   - Non-normative content: `docs/`, `docs/public/`, `docs/patents/`
3. **Agent Usage**: Agents must not introduce new semantics without approval
4. **Planning Required**: Multi-file or architectural changes require a plan

For complete governance rules, see:
- `WARP.md` - Workflow and repository rules
- `AGENTS.md` - Agent usage and governance

---

## Verification Commands

### Check Python files can be imported:
```powershell
python -c "import sys; sys.path.insert(0, 'scripts'); import render_markdown_to_pdf"
```

### Check for missing copyright headers (Python):
```powershell
Get-ChildItem -Recurse -Filter *.py -Exclude ".venv","__pycache__" | Where-Object { -not (Select-String -Path $_.FullName -Pattern "Copyright.*BitConcepts" -Quiet) }
```

### Check for missing copyright headers (PowerShell):
```powershell
Get-ChildItem -Recurse -Filter *.ps1 -Exclude ".venv" | Where-Object { -not (Select-String -Path $_.FullName -Pattern "Copyright.*BitConcepts" -Quiet) }
```

### Check for missing copyright footers (Markdown):
```powershell
Get-ChildItem docs -Recurse -Filter *.md | Where-Object { -not (Select-String -Path $_.FullName -Pattern "Licensed under CPAC Research" -Quiet) }
```

---

**DOCUMENTATION_CHECKLIST.md** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
