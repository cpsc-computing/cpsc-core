#!/usr/bin/env python
# Copyright (c) 2026 BitConcepts, LLC
# SPDX-License-Identifier: LicenseRef-CPSC-Research-Evaluation-1.0
#
# This file is part of the CPSC Specifications.
# For full license terms, see LICENSE in the repository root.

"""Render CPSC/CPAC provisional Markdown to PDF with Mermaid diagrams.

This is a thin, repo-local wrapper around the `md2pdf` CLI provided by the
`md2pdf-mermaid` package. It ensures that:

- Headless Chromium is used for HTML→PDF rendering.
- Mermaid fenced code blocks in the provisional render to SVG/graphics
  correctly inside the PDF.

Prerequisites (run once, from the repository root or any active venv):

    pip install md2pdf-mermaid playwright
    python -m playwright install chromium

Usage examples (from repo root):

    python scripts/render_markdown_to_pdf.py
    python scripts/render_markdown_to_pdf.py \
        --input patents/CPSC-CPAC-Provisional-2026-01.md \
        --output patents/CPSC-CPAC-Provisional-2026-01.pdf

You can also generate just an HTML preview:

    python scripts/render_markdown_to_pdf.py --html-out patents/provisional.html

This script does *not* change any patent semantics. It is tooling only.
"""

import argparse
import subprocess
import sys
import re
import tempfile
from pathlib import Path
import shutil


REPO_ROOT = Path(__file__).resolve().parents[1]


def convert_relative_to_absolute_image_paths(md_content: str, md_file_path: Path) -> str:
    """Convert relative image paths in markdown to absolute paths.
    
    This ensures images are found during PDF generation regardless of working directory.
    Handles both <img src="..."> tags and ![...](...) markdown syntax.
    """
    md_dir = md_file_path.parent
    
    # Pattern for <img> tags with relative src paths
    def replace_img_tag(match):
        before = match.group(1)
        rel_path = match.group(2)
        after = match.group(3)
        
        # Skip if already absolute (starts with / or drive letter or http)
        if rel_path.startswith(('/', 'http://', 'https://')) or (len(rel_path) > 1 and rel_path[1] == ':'):
            return match.group(0)
        
        abs_path = (md_dir / rel_path).resolve()
        # Use forward slashes and file:/// protocol for compatibility
        abs_path_str = abs_path.as_posix()
        if not abs_path_str.startswith('/'):
            abs_path_str = '/' + abs_path_str
        return f'{before}file://{abs_path_str}{after}'
    
    # Pattern for markdown image syntax ![alt](path)
    def replace_md_image(match):
        alt_text = match.group(1)
        rel_path = match.group(2)
        
        # Skip if already absolute
        if rel_path.startswith(('/', 'http://', 'https://')) or (len(rel_path) > 1 and rel_path[1] == ':'):
            return match.group(0)
        
        abs_path = (md_dir / rel_path).resolve()
        abs_path_str = abs_path.as_posix()
        if not abs_path_str.startswith('/'):
            abs_path_str = '/' + abs_path_str
        return f'![{alt_text}](file://{abs_path_str})'
    
    # Replace <img src="relative/path"> with absolute paths
    md_content = re.sub(
        r'(<img\s+[^>]*src=["\']{0,1})([^"\'\s>]+)(["\'][^>]*>)',
        replace_img_tag,
        md_content,
        flags=re.IGNORECASE
    )
    
    # Replace ![alt](relative/path) with absolute paths
    md_content = re.sub(
        r'!\[([^\]]*)\]\(([^)]+)\)',
        replace_md_image,
        md_content
    )
    
    return md_content


def run_md2pdf(input_md: Path, output_pdf: Path | None, html_out: Path | None) -> int:
    """Invoke the `md2pdf` console script from `md2pdf-mermaid`.

    We call the `md2pdf` entry point directly rather than using
    `python -m md2pdf`, because the package does not expose a
    `__main__` module. This assumes that the current environment's
    Python `Scripts`/`bin` directory (containing the `md2pdf` CLI)
    is on PATH.

    To ensure images are found, we create a temporary working copy of the
    markdown file with relative image paths converted to absolute paths.
    The PDF is generated in the same directory as the temp file,
    then copied to the final output location.
    """

    # Read original markdown content
    print(f"[render] Reading original markdown: {input_md}")
    original_content = input_md.read_text(encoding='utf-8')
    
    # Convert relative image paths to absolute
    print(f"[render] Converting relative image paths to absolute...")
    modified_content = convert_relative_to_absolute_image_paths(original_content, input_md)
    
    # Create temporary working file with absolute paths
    temp_md_fd, temp_md_path_str = tempfile.mkstemp(suffix='.md', prefix=f'{input_md.stem}_', text=True)
    temp_md_path = Path(temp_md_path_str)
    
    try:
        # Write modified content to temp file
        with open(temp_md_fd, 'w', encoding='utf-8') as f:
            f.write(modified_content)
        print(f"[render] Created temporary working file: {temp_md_path}")
        
        # Call the installed console script. Prefer PATH resolution but fall back to the
        # Scripts/ directory next to the current Python executable on Windows when
        # md2pdf is not on PATH.
        md2pdf_cmd = shutil.which("md2pdf")
        if md2pdf_cmd is None:
            # On Windows, pip typically installs console scripts into the Scripts/
            # directory next to the python executable. Derive that path and use it
            # directly if present.
            exe_path = Path(sys.executable)
            candidate = exe_path.with_name("Scripts") / "md2pdf.exe"
            if candidate.exists():
                md2pdf_cmd = str(candidate)
            else:
                raise FileNotFoundError(
                    "md2pdf executable not found on PATH or in the Python Scripts/ directory. "
                    "Ensure 'md2pdf-mermaid' is installed and that its console script is "
                    "available."
                )

        cmd: list[str] = [md2pdf_cmd]

        # Use the temp file with absolute paths
        local_name = temp_md_path.name
        cmd.append(local_name)

        # Generate PDF in the same directory as the temp MD file
        temp_pdf_name = temp_md_path.stem + ".pdf"
        cmd.extend(["-o", temp_pdf_name])
        
        # Use US Letter (8.5" x 11") page size
        cmd.extend(["--page-size", "letter"])

        # md2pdf-mermaid's CLI does not currently expose a separate HTML-output
        # flag; it renders directly to PDF. We keep `html_out` in the function
        # signature so the script interface is future-proof, but we do not pass
        # it through to the CLI.

        print(f"[render] Running: {' '.join(cmd)}")
        try:
            # Run md2pdf with CWD set to the temp markdown's parent directory
            workdir = str(temp_md_path.parent)
            temp_pdf_path = temp_md_path.parent / temp_pdf_name
            print(f"[render] Working directory: {workdir}")
            print(f"[render] Debug: temp md path       : {temp_md_path}")
            print(f"[render] Debug: original md path   : {input_md}")
            print(f"[render] Debug: expected image dir : {input_md.parent / 'images'}")
            print(f"[render] Debug: temp PDF path      : {temp_pdf_path}")
            print(f"[render] Debug: final output path  : {output_pdf}")
            result = subprocess.run(cmd, check=False, cwd=workdir)
        except FileNotFoundError as exc:
            print("error: failed to invoke md2pdf via Python module 'md2pdf'.", file=sys.stderr)
            print("       Ensure 'md2pdf-mermaid' is installed in this environment.", file=sys.stderr)
            print(f"       Details: {exc}", file=sys.stderr)
            return 1

        print(f"[render] md2pdf return code: {result.returncode}")
        if result.returncode != 0:
            print(f"error: md2pdf exited with status {result.returncode}", file=sys.stderr)
            return result.returncode

        # If generation succeeded and we have an output location, copy the PDF there
        if result.returncode == 0 and output_pdf is not None:
            if temp_pdf_path.exists():
                print(f"[render] Copying {temp_pdf_path} -> {output_pdf}")
                shutil.copy2(temp_pdf_path, output_pdf)
                # Clean up the temp PDF
                print(f"[render] Removing temporary PDF: {temp_pdf_path}")
                temp_pdf_path.unlink()
            else:
                print(f"error: expected temporary PDF not found: {temp_pdf_path}", file=sys.stderr)
                return 1

        return result.returncode
        
    finally:
        # Clean up temporary markdown file
        if temp_md_path.exists():
            print(f"[render] Removing temporary markdown: {temp_md_path}")
            temp_md_path.unlink()


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Render Markdown to PDF using md2pdf-mermaid (headless Chromium with "
            "Mermaid support). If no input/output is provided and no test flag "
            "is set, this script defaults to rendering all Markdown files under "
            "docs/ into a mirrored docs-pdf/ tree."
        )
    )

    parser.add_argument(
        "--input",
        type=Path,
        help=(
            "Input Markdown file (relative to repo root). If omitted and "
            "--all-docs is not set, no single-file render is performed."
        ),
    )

    parser.add_argument(
        "--output",
        type=Path,
        help=(
            "Output PDF file (relative to repo root). If omitted in single-file "
            "mode, the output path will mirror the docs/ hierarchy under "
            "docs-pdf/."
        ),
    )

    parser.add_argument(
        "--html-out",
        type=Path,
        default=None,
        help=(
            "Reserved for potential future use if md2pdf-mermaid adds a flag "
            "to emit intermediate HTML. Currently ignored."
        ),
    )

    parser.add_argument(
        "--test-diagrams",
        action="store_true",
        help=(
            "If set, render only a small, inline-mermaid test document to HTML/PDF "
            "to validate that Mermaid/Chromium are working, without touching other "
            "documents."
        ),
    )

    parser.add_argument(
        "--all-docs",
        action="store_true",
        help=(
            "If set (or if no other flags are provided), render all Markdown files "
            "under docs/ into a mirrored docs-pdf/ tree."
        ),
    )

    return parser.parse_args(argv)


def build_test_markdown() -> str:
    """Return a tiny Markdown string containing a few Mermaid diagrams.

    This exercises the same fenced code block style used in the provisional.
    """

    return """# Mermaid Test

This is a minimal test to confirm that md2pdf-mermaid can render flowcharts.

```mermaid
flowchart LR
    A[Start] --> B[Check]
    B -->|OK| C[Done]
    B -->|Fail| D[Error]
```

```mermaid
flowchart TD
    X[Input] --> Y[Projection Engine]
    Y --> Z[Valid State]
```
"""


def run_test_mode(html_out: Path | None, pdf_out: Path | None) -> int:
    """Write a temporary Markdown file and render it via md2pdf.

    The user can inspect the HTML/PDF to confirm diagrams look correct.
    """

    from tempfile import TemporaryDirectory

    with TemporaryDirectory() as tmpdir:
        tmpdir_path = Path(tmpdir)
        md_path = tmpdir_path / "mermaid-test.md"
        md_path.write_text(build_test_markdown(), encoding="utf-8")

        # Default output in a temp location if not overridden.
        if pdf_out is None:
            pdf_out = tmpdir_path / "mermaid-test.pdf"
        if html_out is None:
            html_out = tmpdir_path / "mermaid-test.html"

        print(f"[test] Writing temporary Markdown to {md_path}")
        print(f"[test] HTML out: {html_out}")
        print(f"[test] PDF out:  {pdf_out}")

        return run_md2pdf(md_path, pdf_out, html_out)


def main(argv: list[str]) -> int:
    args = parse_args(argv)

    # Default behavior: if no explicit input/output and no test flag was provided,
    # treat this as an "all docs" render under docs/.
    if not argv and not args.test_diagrams:
        args.all_docs = True

    if args.test_diagrams:
        return run_test_mode(args.html_out, args.output)

    # All-docs mode: mirror docs/ into docs-pdf/.
    if args.all_docs:
        docs_root = REPO_ROOT / "docs"
        docs_pdf_root = REPO_ROOT / "docs-pdf"

        if not docs_root.exists():
            print(f"error: docs directory not found at {docs_root}", file=sys.stderr)
            return 1

        docs_pdf_root.mkdir(parents=True, exist_ok=True)

        md_files = list(docs_root.rglob("*.md"))
        if not md_files:
            print(f"[render] No Markdown files found under {docs_root}")
            return 0

        for md in md_files:
            # Compute relative path under docs/.
            rel = md.relative_to(docs_root)
            out_dir = docs_pdf_root / rel.parent
            out_pdf = out_dir / (md.stem + ".pdf")

            out_dir.mkdir(parents=True, exist_ok=True)
            print(f"[render] Rendering {md} -> {out_pdf}")
            rc = run_md2pdf(md, out_pdf, html_out=None)
            if rc != 0:
                print(f"[render] WARNING: md2pdf exited with {rc} for {md}", file=sys.stderr)

        return 0

    # Single-file mode.
    input_md = args.input
    output_pdf = args.output

    if input_md is None:
        print("error: --input is required for single-file mode (when --all-docs is not used)", file=sys.stderr)
        return 1

    # Normalize to absolute paths based on repo root when a relative path is given.
    if not input_md.is_absolute():
        input_md = (REPO_ROOT / input_md).resolve()

    if output_pdf is None:
        # Mirror docs/ hierarchy under docs-pdf/ by default.
        docs_root = REPO_ROOT / "docs"
        docs_pdf_root = REPO_ROOT / "docs-pdf"
        try:
            rel = input_md.relative_to(docs_root)
        except ValueError:
            # If the input is not under docs/, fall back to placing the PDF next to it.
            output_pdf = input_md.with_suffix(".pdf")
        else:
            out_dir = docs_pdf_root / rel.parent
            out_dir.mkdir(parents=True, exist_ok=True)
            output_pdf = out_dir / (input_md.stem + ".pdf")

    if not output_pdf.is_absolute():
        output_pdf = (REPO_ROOT / output_pdf).resolve()

    html_out = args.html_out
    if html_out is not None and not html_out.is_absolute():
        html_out = (REPO_ROOT / html_out).resolve()

    if not input_md.exists():
        print(f"error: input Markdown does not exist: {input_md}", file=sys.stderr)
        return 1

    print(f"[render] Input : {input_md}")
    print(f"[render] Output: {output_pdf}")
    if html_out is not None:
        print(f"[render] HTML  : {html_out}")

    output_pdf.parent.mkdir(parents=True, exist_ok=True)
    if html_out is not None:
        html_out.parent.mkdir(parents=True, exist_ok=True)

    return run_md2pdf(input_md, output_pdf, html_out)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
