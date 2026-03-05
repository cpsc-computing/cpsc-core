#!/usr/bin/env bash
# Copyright (c) 2026 BitConcepts, LLC
# SPDX-License-Identifier: LicenseRef-CPSC-Research-Evaluation-1.0
#
# This file is part of the CPSC Specifications.
# For full license terms, see LICENSE in the repository root.

# Setup development environment for CPSC specifications repository

set -e

# Parse arguments
RENDER_TOOLS=false
USPTO_MCP=false
PYTHON="python3"
ROOT_DIR="$HOME"
SKIP_CLONE=false
SKIP_SETUP=false
CONFIGURE_PATENT_MCP=false

show_help() {
    cat << EOF
Setup development environment for CPSC specifications repository.

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --render-tools          Install PDF rendering tools (md2pdf-mermaid, Playwright)
    --uspto-mcp             Install/update USPTO MCP servers
    --python EXECUTABLE     Python executable to use (default: python3)
    --root-dir DIRECTORY    Root directory for USPTO MCP repos (default: \$HOME)
    --skip-clone            Skip git clone/update step for USPTO MCP servers
    --skip-setup            Skip running setup scripts for USPTO MCP servers
    --configure-patent-mcp  Also configure patent_mcp_server with API keys
    -h, --help              Show this help message

EXAMPLES:
    # Install everything (default)
    ./setup.sh

    # Install only PDF rendering tools
    ./setup.sh --render-tools

    # Install only USPTO MCP servers
    ./setup.sh --uspto-mcp

    # Install USPTO MCPs with patent_mcp_server
    ./setup.sh --uspto-mcp --configure-patent-mcp
EOF
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --render-tools)
            RENDER_TOOLS=true
            shift
            ;;
        --uspto-mcp)
            USPTO_MCP=true
            shift
            ;;
        --python)
            PYTHON="$2"
            shift 2
            ;;
        --root-dir)
            ROOT_DIR="$2"
            shift 2
            ;;
        --skip-clone)
            SKIP_CLONE=true
            shift
            ;;
        --skip-setup)
            SKIP_SETUP=true
            shift
            ;;
        --configure-patent-mcp)
            CONFIGURE_PATENT_MCP=true
            shift
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

# If neither specified, install both
if [ "$RENDER_TOOLS" = false ] && [ "$USPTO_MCP" = false ]; then
    RENDER_TOOLS=true
    USPTO_MCP=true
fi

echo "=== CPSC Specifications Setup ==="
echo ""

#==============================================================================
# Part 1: PDF Rendering Tools
#==============================================================================

if [ "$RENDER_TOOLS" = true ]; then
    echo "[Render Tools] Installing PDF rendering tools..."
    echo "[Render Tools] Using Python executable: $PYTHON"
    
    if command -v "$PYTHON" &> /dev/null; then
        # Install md2pdf-mermaid and Playwright
        echo "[Render Tools] Installing md2pdf-mermaid and Playwright..."
        "$PYTHON" -m pip install --upgrade pip
        "$PYTHON" -m pip install md2pdf-mermaid playwright
        
        # Install Chromium browser
        echo "[Render Tools] Installing Chromium browser..."
        "$PYTHON" -m playwright install chromium
        
        echo "[Render Tools] ✓ PDF rendering tools installed successfully."
    else
        echo "[Render Tools] ✗ Python executable '$PYTHON' not found."
        echo "[Render Tools]   Use --python to specify a different Python executable."
        exit 1
    fi
    echo ""
fi

#==============================================================================
# Part 2: USPTO MCP Servers
#==============================================================================

if [ "$USPTO_MCP" = true ]; then
    echo "[USPTO MCP] Setting up USPTO MCP servers..."
    echo "[USPTO MCP] Root directory: $ROOT_DIR"
    echo ""
    
    declare -a servers=(
        "uspto_ptab_mcp:https://github.com/john-walkoe/uspto_ptab_mcp.git"
        "uspto_pfw_mcp:https://github.com/john-walkoe/uspto_pfw_mcp.git"
        "uspto_fpd_mcp:https://github.com/john-walkoe/uspto_fpd_mcp.git"
        "uspto_enriched_citation_mcp:https://github.com/john-walkoe/uspto_enriched_citation_mcp.git"
    )
    
    if ! command -v git &> /dev/null && [ "$SKIP_CLONE" = false ]; then
        echo "[USPTO MCP] ✗ 'git' not found on PATH."
        echo "[USPTO MCP]   Install git or clone repositories manually, then re-run with --skip-clone."
    fi
    
    # Process each USPTO MCP server
    for server_info in "${servers[@]}"; do
        IFS=':' read -r name url <<< "$server_info"
        repo_dir="$ROOT_DIR/$name"
        
        echo "[USPTO MCP] Processing $name..."
        
        # Clone or update repository
        if [ "$SKIP_CLONE" = false ]; then
            if [ ! -d "$repo_dir" ]; then
                if command -v git &> /dev/null; then
                    echo "[USPTO MCP]   Cloning $url..."
                    git clone "$url" "$repo_dir"
                else
                    echo "[USPTO MCP]   ✗ git not available; please clone $url into $repo_dir manually."
                fi
            else
                if command -v git &> /dev/null; then
                    echo "[USPTO MCP]   Repository exists; updating..."
                    (cd "$repo_dir" && git pull --ff-only)
                else
                    echo "[USPTO MCP]   Repository exists but git not available; skipping update."
                fi
            fi
        fi
        
        # Run upstream setup script (Linux/macOS versions use setup.sh, not windows_setup.ps1)
        if [ "$SKIP_SETUP" = true ]; then
            echo "[USPTO MCP]   SkipSetup specified; not running setup script."
            continue
        fi
        
        if [ ! -d "$repo_dir" ]; then
            echo "[USPTO MCP]   ✗ Repository directory $repo_dir does not exist; skipping setup."
            continue
        fi
        
        setup_script="$repo_dir/deploy/setup.sh"
        if [ ! -f "$setup_script" ]; then
            echo "[USPTO MCP]   Note: Setup script $setup_script not found (may not exist yet for Linux/macOS)."
            echo "[USPTO MCP]   Check upstream repository for Linux/macOS setup instructions."
            continue
        fi
        
        echo "[USPTO MCP]   Running $setup_script..."
        (cd "$repo_dir" && bash "$setup_script")
    done
    
    echo "[USPTO MCP] ✓ Completed processing USPTO MCP servers."
    echo ""
    
    # Handle patent_mcp_server (PPUBS/PatentsView)
    patent_repo="$ROOT_DIR/patent_mcp_server"
    should_handle_patent_mcp=false
    
    if [ "$CONFIGURE_PATENT_MCP" = true ] || [ -d "$patent_repo" ]; then
        should_handle_patent_mcp=true
    fi
    
    if [ "$should_handle_patent_mcp" = true ]; then
        echo "[Patent MCP] Processing patent_mcp_server..."
        
        if [ "$SKIP_CLONE" = false ]; then
            if [ ! -d "$patent_repo" ]; then
                if command -v git &> /dev/null; then
                    echo "[Patent MCP]   Cloning https://github.com/riemannzeta/patent_mcp_server.git..."
                    git clone https://github.com/riemannzeta/patent_mcp_server.git "$patent_repo"
                else
                    echo "[Patent MCP]   ✗ git not available; please clone manually."
                fi
            else
                if command -v git &> /dev/null; then
                    echo "[Patent MCP]   Repository exists; updating..."
                    (cd "$patent_repo" && git pull --ff-only)
                else
                    echo "[Patent MCP]   Repository exists but git not available; skipping update."
                fi
            fi
        fi
        
        if [ ! -d "$patent_repo" ]; then
            echo "[Patent MCP]   ✗ Repository directory $patent_repo does not exist; skipping setup."
        else
            (cd "$patent_repo" && uv sync)
            
            if [ $? -ne 0 ]; then
                echo "[Patent MCP]   ✗ 'uv sync' exited with code $?."
            else
                # Optional .env configuration
                env_path="$patent_repo/.env"
                echo "[Patent MCP]   Configure API keys for patent_mcp_server (.env)."
                echo -n "[Patent MCP]   Enter USPTO_API_KEY (leave blank to skip): "
                read -s uspto_key
                echo ""
                
                echo -n "[Patent MCP]   Enter PATENTSVIEW_API_KEY (optional, leave blank to skip): "
                read -s pv_key
                echo ""
                
                env_lines=()
                if [ -n "$uspto_key" ]; then
                    env_lines+=("USPTO_API_KEY=$uspto_key")
                fi
                if [ -n "$pv_key" ]; then
                    env_lines+=("PATENTSVIEW_API_KEY=$pv_key")
                fi
                
                if [ ${#env_lines[@]} -eq 0 ]; then
                    echo "[Patent MCP]   No keys entered; leaving .env unchanged."
                else
                    if [ -f "$env_path" ]; then
                        backup_path="$env_path.bak_$(date +%Y%m%d_%H%M%S)"
                        echo "[Patent MCP]   Backing up existing .env to $backup_path"
                        cp "$env_path" "$backup_path"
                    fi
                    printf "%s\n" "${env_lines[@]}" > "$env_path"
                    echo "[Patent MCP]   ✓ Wrote .env with ${#env_lines[@]} key(s)."
                fi
            fi
        fi
    fi
fi

echo ""
echo "=== Setup Complete ==="
