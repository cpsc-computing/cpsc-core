# Copyright (c) 2026 BitConcepts, LLC
# SPDX-License-Identifier: LicenseRef-CPSC-Research-Evaluation-1.0
#
# This file is part of the CPSC Specifications.
# For full license terms, see LICENSE in the repository root.

param(
    [switch]$RenderTools,
    [switch]$UsptoMcp,
    [string]$Python = "python",
    [string]$RootDir = "$env:USERPROFILE",
    [switch]$SkipClone,
    [switch]$SkipSetup,
    [switch]$ConfigurePatentMcp
)

<#
.SYNOPSIS
    Setup development environment for CPSC specifications repository.

.DESCRIPTION
    This script sets up tools needed for working with the CPSC specifications:
    
    1. PDF Rendering Tools (-RenderTools):
       - Installs md2pdf-mermaid and Playwright for rendering Markdown to PDF
       - Installs Chromium browser via Playwright
    
    2. USPTO MCP Servers (-UsptoMcp):
       - Clones/updates John Walkoe's USPTO MCP servers (PTAB, PFW, FPD, Enriched Citation)
       - Optionally clones/updates patent_mcp_server (PPUBS/PatentsView)
       - Runs upstream setup scripts for each MCP server
    
    If neither -RenderTools nor -UsptoMcp is specified, both will be installed.

.PARAMETER RenderTools
    Install PDF rendering tools (md2pdf-mermaid, Playwright, Chromium).

.PARAMETER UsptoMcp
    Install/update USPTO MCP servers.

.PARAMETER Python
    Python executable to use for PDF rendering tools (default: "python").

.PARAMETER RootDir
    Root directory for cloning USPTO MCP repositories (default: $env:USERPROFILE).

.PARAMETER SkipClone
    Skip git clone/update step for USPTO MCP servers.

.PARAMETER SkipSetup
    Skip running setup scripts for USPTO MCP servers.

.PARAMETER ConfigurePatentMcp
    Also configure patent_mcp_server (PPUBS/PatentsView) with API keys.

.EXAMPLE
    # Install everything (default)
    .\setup.ps1

.EXAMPLE
    # Install only PDF rendering tools
    .\setup.ps1 -RenderTools

.EXAMPLE
    # Install only USPTO MCP servers
    .\setup.ps1 -UsptoMcp

.EXAMPLE
    # Install USPTO MCPs with patent_mcp_server
    .\setup.ps1 -UsptoMcp -ConfigurePatentMcp
#>

$ErrorActionPreference = "Stop"

# Determine what to install
$installRenderTools = $RenderTools -or (-not $UsptoMcp)
$installUsptoMcp = $UsptoMcp -or (-not $RenderTools)

Write-Host "=== CPSC Specifications Setup ===" -ForegroundColor Cyan
Write-Host ""

#==============================================================================
# Part 1: PDF Rendering Tools
#==============================================================================

if ($installRenderTools) {
    Write-Host "[Render Tools] Installing PDF rendering tools..." -ForegroundColor Cyan
    Write-Host "[Render Tools] Using Python executable: $Python" -ForegroundColor Cyan
    
    try {
        # Install md2pdf-mermaid and Playwright
        Write-Host "[Render Tools] Installing md2pdf-mermaid and Playwright..." -ForegroundColor Cyan
        & $Python -m pip install --upgrade pip
        & $Python -m pip install md2pdf-mermaid playwright
        
        # Install Chromium browser
        Write-Host "[Render Tools] Installing Chromium browser..." -ForegroundColor Cyan
        & $Python -m playwright install chromium
        
        Write-Host "[Render Tools] ✓ PDF rendering tools installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Warning "[Render Tools] Failed to install PDF rendering tools: $_"
    }
    Write-Host ""
}

#==============================================================================
# Part 2: USPTO MCP Servers
#==============================================================================

if ($installUsptoMcp) {
    Write-Host "[USPTO MCP] Setting up USPTO MCP servers..." -ForegroundColor Cyan
    Write-Host "[USPTO MCP] Root directory: $RootDir" -ForegroundColor Cyan
    Write-Host ""
    
    $servers = @(
        @{ Name = "uspto_ptab_mcp";              Url = "https://github.com/john-walkoe/uspto_ptab_mcp.git" },
        @{ Name = "uspto_pfw_mcp";               Url = "https://github.com/john-walkoe/uspto_pfw_mcp.git" },
        @{ Name = "uspto_fpd_mcp";               Url = "https://github.com/john-walkoe/uspto_fpd_mcp.git" },
        @{ Name = "uspto_enriched_citation_mcp"; Url = "https://github.com/john-walkoe/uspto_enriched_citation_mcp.git" }
    )
    
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git -and -not $SkipClone) {
        Write-Warning "[USPTO MCP] 'git' not found on PATH. Install git or clone repositories manually, then re-run with -SkipClone."
    }
    
    # Process each USPTO MCP server
    foreach ($server in $servers) {
        $name = $server.Name
        $url  = $server.Url
        $repoDir = Join-Path $RootDir $name
        
        Write-Host "[USPTO MCP] Processing $name..." -ForegroundColor Cyan
        
        # Clone or update repository
        if (-not $SkipClone) {
            if (-not (Test-Path -LiteralPath $repoDir)) {
                if ($git) {
                    Write-Host "[USPTO MCP]   Cloning $url..." -ForegroundColor Cyan
                    git clone $url $repoDir
                }
                else {
                    Write-Warning "[USPTO MCP]   git not available; please clone $url into $repoDir manually."
                }
            }
            else {
                if ($git) {
                    Write-Host "[USPTO MCP]   Repository exists; updating..." -ForegroundColor Cyan
                    Push-Location $repoDir
                    try {
                        git pull --ff-only
                    }
                    finally {
                        Pop-Location
                    }
                }
                else {
                    Write-Host "[USPTO MCP]   Repository exists but git not available; skipping update." -ForegroundColor Yellow
                }
            }
        }
        
        # Run upstream setup script
        if ($SkipSetup) {
            Write-Host "[USPTO MCP]   SkipSetup specified; not running setup script." -ForegroundColor Yellow
            continue
        }
        
        if (-not (Test-Path -LiteralPath $repoDir)) {
            Write-Warning "[USPTO MCP]   Repository directory $repoDir does not exist; skipping setup."
            continue
        }
        
        $setupScript = Join-Path $repoDir "deploy\windows_setup.ps1"
        if (-not (Test-Path -LiteralPath $setupScript)) {
            Write-Warning "[USPTO MCP]   Setup script not found: $setupScript"
            continue
        }
        
        Write-Host "[USPTO MCP]   Running $setupScript..." -ForegroundColor Cyan
        Push-Location $repoDir
        try {
            Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
            & $setupScript
        }
        finally {
            Pop-Location
        }
    }
    
    Write-Host "[USPTO MCP] ✓ Completed processing USPTO MCP servers." -ForegroundColor Green
    Write-Host ""
    
    # Handle patent_mcp_server (PPUBS/PatentsView)
    $patentRepo = Join-Path $RootDir "patent_mcp_server"
    $shouldHandlePatentMcp = $ConfigurePatentMcp -or (Test-Path -LiteralPath $patentRepo)
    
    if ($shouldHandlePatentMcp) {
        Write-Host "[Patent MCP] Processing patent_mcp_server..." -ForegroundColor Cyan
        
        if (-not $SkipClone) {
            if (-not (Test-Path -LiteralPath $patentRepo)) {
                if ($git) {
                    Write-Host "[Patent MCP]   Cloning https://github.com/riemannzeta/patent_mcp_server.git..." -ForegroundColor Cyan
                    git clone https://github.com/riemannzeta/patent_mcp_server.git $patentRepo
                }
                else {
                    Write-Warning "[Patent MCP]   git not available; please clone manually."
                }
            }
            else {
                if ($git) {
                    Write-Host "[Patent MCP]   Repository exists; updating..." -ForegroundColor Cyan
                    Push-Location $patentRepo
                    try {
                        git pull --ff-only
                    }
                    finally {
                        Pop-Location
                    }
                }
                else {
                    Write-Host "[Patent MCP]   Repository exists but git not available; skipping update." -ForegroundColor Yellow
                }
            }
        }
        
        if (-not (Test-Path -LiteralPath $patentRepo)) {
            Write-Warning "[Patent MCP]   Repository directory $patentRepo does not exist; skipping setup."
        }
        else {
            Push-Location $patentRepo
            try {
                Write-Host "[Patent MCP]   Running 'uv sync'..." -ForegroundColor Cyan
                uv sync
            }
            finally {
                Pop-Location
            }
            
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "[Patent MCP]   'uv sync' exited with code $LASTEXITCODE."
            }
            else {
                # Optional .env configuration
                $envPath = Join-Path $patentRepo ".env"
                Write-Host "[Patent MCP]   Configure API keys for patent_mcp_server (.env)." -ForegroundColor Yellow
                Write-Host "[Patent MCP]   Enter USPTO_API_KEY (leave blank to skip):" -ForegroundColor Cyan
                $usptoSecure = Read-Host -AsSecureString
                $usptoPlain = if ($usptoSecure.Length -gt 0) { [System.Net.NetworkCredential]::new("", $usptoSecure).Password } else { "" }
                
                Write-Host "[Patent MCP]   Enter PATENTSVIEW_API_KEY (optional, leave blank to skip):" -ForegroundColor Cyan
                $pvSecure = Read-Host -AsSecureString
                $pvPlain = if ($pvSecure.Length -gt 0) { [System.Net.NetworkCredential]::new("", $pvSecure).Password } else { "" }
                
                $lines = @()
                if ($usptoPlain -ne "") { $lines += "USPTO_API_KEY=$usptoPlain" }
                if ($pvPlain   -ne "") { $lines += "PATENTSVIEW_API_KEY=$pvPlain" }
                
                if ($lines.Count -eq 0) {
                    Write-Host "[Patent MCP]   No keys entered; leaving .env unchanged." -ForegroundColor Yellow
                }
                else {
                    if (Test-Path -LiteralPath $envPath) {
                        $backupPath = "$envPath.bak_" + (Get-Date -Format "yyyyMMdd_HHmmss")
                        Write-Host "[Patent MCP]   Backing up existing .env to $backupPath" -ForegroundColor Yellow
                        Copy-Item -LiteralPath $envPath -Destination $backupPath -Force
                    }
                    $content = ($lines -join "`r`n") + "`r`n"
                    Set-Content -LiteralPath $envPath -Value $content -Encoding UTF8 -Force
                    Write-Host "[Patent MCP]   ✓ Wrote .env with $(($lines).Count) key(s)." -ForegroundColor Green
                }
            }
        }
    }
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
