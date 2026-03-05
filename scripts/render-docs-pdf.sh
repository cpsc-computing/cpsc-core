#!/usr/bin/env bash
# Copyright (c) 2026 BitConcepts, LLC
# SPDX-License-Identifier: LicenseRef-CPSC-Research-Evaluation-1.0
#
# This file is part of the CPSC Specifications.
# For full license terms, see LICENSE in the repository root.

# Render CPSC/CPAC Markdown documents to PDF with Mermaid diagrams

set -e

# Script directory (scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Repository root (.github/)
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

PYTHON="python3"
SOURCE=""
OUTPUT=""
TEST_DIAGRAMS=false
ALL_DOCS=false

show_help() {
    cat << EOF
Render CPSC/CPAC Markdown documents to PDF with Mermaid diagrams.

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -i, --input FILE        Input Markdown file
    -o, --output FILE       Output PDF file
    --test-diagrams         Test Mermaid rendering (no actual PDF generation)
    --all-docs              Render all docs/ Markdown files to docs-pdf/
    --python EXECUTABLE     Python executable to use (default: python3)
    -h, --help              Show this help message

EXAMPLES:
    # Render default provisional
    ./render-docs-pdf.sh

    # Render specific file
    ./render-docs-pdf.sh --input docs/patents/CPSC-CPAC-Provisional-2026-01.md

    # Render all docs
    ./render-docs-pdf.sh --all-docs

    # Test Mermaid rendering
    ./render-docs-pdf.sh --test-diagrams
EOF
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            SOURCE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        --test-diagrams)
            TEST_DIAGRAMS=true
            shift
            ;;
        --all-docs)
            ALL_DOCS=true
            shift
            ;;
        --python)
            PYTHON="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

RENDER_SCRIPT="$SCRIPT_DIR/render_markdown_to_pdf.py"
if [ ! -f "$RENDER_SCRIPT" ]; then
    echo "[render] ✗ render_markdown_to_pdf.py not found at $RENDER_SCRIPT"
    exit 1
fi

# Test diagrams mode
if [ "$TEST_DIAGRAMS" = true ]; then
    echo "[render] Using Python executable: $PYTHON"
    echo "[render] Running: $PYTHON $RENDER_SCRIPT --test-diagrams"
    "$PYTHON" "$RENDER_SCRIPT" --test-diagrams
    exit 0
fi

# All docs mode
if [ "$ALL_DOCS" = true ]; then
    DOCS_ROOT="$REPO_ROOT/docs"
    DOCS_PDF_ROOT="$REPO_ROOT/docs-pdf"
    
    if [ ! -d "$DOCS_ROOT" ]; then
        echo "[render] ✗ docs directory not found at $DOCS_ROOT"
        exit 1
    fi
    
    if [ ! -d "$DOCS_PDF_ROOT" ]; then
        echo "[render] Creating docs-pdf directory at $DOCS_PDF_ROOT"
        mkdir -p "$DOCS_PDF_ROOT"
    fi
    
    # Find all markdown files
    while IFS= read -r -d '' md_file; do
        filename=$(basename "$md_file")
        
        # Skip certain docs
        if [ "$filename" = "LEDGER.md" ] || [ "$filename" = "SPEC-CHANGE-TEMPLATE.md" ]; then
            echo "[render] Skipping $md_file (per policy)"
            continue
        fi
        
        # Compute relative path under docs/
        rel_path="${md_file#$DOCS_ROOT/}"
        
        # Map to docs-pdf/
        target_dir="$DOCS_PDF_ROOT/$(dirname "$rel_path")"
        target_file="$(basename "$rel_path" .md).pdf"
        output_path="$target_dir/$target_file"
        
        if [ ! -d "$target_dir" ]; then
            echo "[render] Creating directory $target_dir"
            mkdir -p "$target_dir"
        fi
        
        echo "[render] Rendering $md_file -> $output_path"
        "$PYTHON" "$RENDER_SCRIPT" --input "$md_file" --output "$output_path"
        
    done < <(find "$DOCS_ROOT" -name "*.md" -type f -print0)
    
    exit 0
fi

# Single-input mode
# Default to provisional if no source specified
if [ -z "$SOURCE" ]; then
    SOURCE="docs/patents/CPSC-CPAC-Provisional-2026-01.md"
fi

# Normalize input path
if [[ "$SOURCE" = /* ]]; then
    INPUT_PATH="$SOURCE"
else
    INPUT_PATH="$REPO_ROOT/$SOURCE"
fi

if [ ! -f "$INPUT_PATH" ]; then
    echo "[render] ✗ Input file not found: $INPUT_PATH"
    exit 1
fi

# If no output specified, mirror docs/ structure into docs-pdf/
if [ -z "$OUTPUT" ]; then
    DOCS_ROOT="$REPO_ROOT/docs"
    DOCS_PDF_ROOT="$REPO_ROOT/docs-pdf"
    
    if [ ! -d "$DOCS_PDF_ROOT" ]; then
        echo "[render] Creating docs-pdf directory at $DOCS_PDF_ROOT"
        mkdir -p "$DOCS_PDF_ROOT"
    fi
    
    # Compute relative path under docs/
    rel_path="${INPUT_PATH#$DOCS_ROOT/}"
    
    # Map to docs-pdf/
    target_dir="$DOCS_PDF_ROOT/$(dirname "$rel_path")"
    target_file="$(basename "$rel_path" .md).pdf"
    OUTPUT="$target_dir/$target_file"
fi

# Normalize output path
if [[ "$OUTPUT" = /* ]]; then
    OUTPUT_PATH="$OUTPUT"
else
    OUTPUT_PATH="$REPO_ROOT/$OUTPUT"
fi

# Ensure output directory exists
output_dir="$(dirname "$OUTPUT_PATH")"
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

echo "[render] Resolved input path : $INPUT_PATH"
echo "[render] Resolved output path: $OUTPUT_PATH"
echo "[render] Using Python executable: $PYTHON"
echo "[render] Running: $PYTHON $RENDER_SCRIPT --input $INPUT_PATH --output $OUTPUT_PATH"

"$PYTHON" "$RENDER_SCRIPT" --input "$INPUT_PATH" --output "$OUTPUT_PATH"
