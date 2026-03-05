# Copyright (c) 2026 BitConcepts, LLC
# SPDX-License-Identifier: LicenseRef-CPSC-Research-Evaluation-1.0
#
# This file is part of the CPSC Specifications.
# For full license terms, see LICENSE in the repository root.

param(
    [Alias("Input")]
    [string]$Source,
    [string]$Output,
    [switch]$TestDiagrams,
    [switch]$AllDocs,
    [string]$Python = "python"
)

$ErrorActionPreference = "Stop"

# $PSScriptRoot points to .github\scripts.
# The .github directory (which contains the Python script) is its parent.
$githubRoot = Split-Path $PSScriptRoot -Parent

$scriptPath = Join-Path $githubRoot "scripts\render_markdown_to_pdf.py"
if (-not (Test-Path $scriptPath)) {
    throw "render_markdown_to_pdf.py not found at $scriptPath"
}

if ($TestDiagrams) {
    # Just exercise the renderer's built-in test mode.
    $args = @($scriptPath, "--test-diagrams")
    Write-Host "[render] Using Python executable: $Python"
    Write-Host "[render] Running: $Python $($args -join ' ')"
    & $Python @args
    return
}

if ($AllDocs) {
    # Render every Markdown file under docs/ into a mirrored docs-pdf/ tree.
    $docsRoot    = Join-Path $githubRoot "docs"
    $docsPdfRoot = Join-Path $githubRoot "docs-pdf"

    if (-not (Test-Path $docsRoot)) {
        throw "docs directory not found at $docsRoot"
    }

    if (-not (Test-Path $docsPdfRoot)) {
        Write-Host "[render] Creating docs-pdf directory at $docsPdfRoot"
        New-Item -ItemType Directory -Path $docsPdfRoot | Out-Null
    }

    $markdownFiles = Get-ChildItem -Path $docsRoot -Recurse -Filter "*.md" -File
    if (-not $markdownFiles) {
        Write-Host "[render] No Markdown files found under $docsRoot"
        return
    }

    foreach ($file in $markdownFiles) {
        # Skip certain docs that should not have auto-generated PDFs.
        if ($file.Name -ieq "LEDGER.md" -or $file.Name -ieq "SPEC-CHANGE-TEMPLATE.md") {
            Write-Host "[render] Skipping" $file.FullName "(per policy)"
            continue
        }
        $inputPath = $file.FullName

        # Compute relative path under docs/ and map it into docs-pdf/.
        Push-Location $docsRoot
        try {
            $relativePath = Resolve-Path $inputPath -Relative
        } finally {
            Pop-Location
        }
        # Normalize to use forward slashes (no leading .\).
        $relativePath = $relativePath -replace "^\.\\", ""

        $targetDir   = Join-Path $docsPdfRoot ([System.IO.Path]::GetDirectoryName($relativePath))
        $targetFile  = [System.IO.Path]::GetFileNameWithoutExtension($relativePath) + ".pdf"
        $outputPath  = Join-Path $targetDir $targetFile

        if (-not (Test-Path $targetDir)) {
            Write-Host "[render] Creating directory" $targetDir
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        Write-Host "[render] Rendering" $inputPath "->" $outputPath

        $args = @($scriptPath, "--input", $inputPath, "--output", $outputPath)

        Write-Host "[render] Using Python executable: $Python"
        Write-Host "[render] Running: $Python $($args -join ' ')"

        & $Python @args
    }

    return
}

# Single-input mode.
# If no input/source is provided, default to the provisional in docs/.
if (-not $Source) {
    $Source = "docs/patents/CPSC-CPAC-Provisional-2026-01.md"
}

# Normalize input path relative to repo root unless already absolute.
if ([System.IO.Path]::IsPathRooted($Source)) {
    $inputPath = $Source
} else {
    $inputPath = Join-Path $githubRoot $Source
}

# If no output is provided, mirror the docs/ structure into docs-pdf/.
if (-not $Output) {
    $docsRoot    = Join-Path $githubRoot "docs"
    $docsPdfRoot = Join-Path $githubRoot "docs-pdf"

    if (-not (Test-Path $docsPdfRoot)) {
        Write-Host "[render] Creating docs-pdf directory at $docsPdfRoot"
        New-Item -ItemType Directory -Path $docsPdfRoot | Out-Null
    }

    # Compute relative path under docs/ and map it into docs-pdf/.
    Push-Location $docsRoot
    try {
        $relativePath = Resolve-Path $inputPath -Relative
    } finally {
        Pop-Location
    }
    $relativePath = $relativePath -replace "^\.\\", ""

    $targetDir  = Join-Path $docsPdfRoot ([System.IO.Path]::GetDirectoryName($relativePath))
    $targetFile = [System.IO.Path]::GetFileNameWithoutExtension($relativePath) + ".pdf"
    $Output     = Join-Path $targetDir $targetFile
}

# Normalize output path similarly.
if ([System.IO.Path]::IsPathRooted($Output)) {
    $outputPath = $Output
} else {
    $outputPath = Join-Path $githubRoot $Output
}

if (-not (Test-Path (Split-Path $outputPath -Parent))) {
    New-Item -ItemType Directory -Path (Split-Path $outputPath -Parent) -Force | Out-Null
}

Write-Host "[render] Resolved input path : $inputPath"
Write-Host "[render] Resolved output path: $outputPath"

$args = @($scriptPath, "--input", $inputPath, "--output", $outputPath)

Write-Host "[render] Using Python executable: $Python"
Write-Host "[render] Running: $Python $($args -join ' ')"

& $Python @args
