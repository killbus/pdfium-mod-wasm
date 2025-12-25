#!/bin/bash
set -e

echo "================================================================================"
echo "                           BUILD ENVIRONMENT DEBUG                              "
echo "================================================================================"

echo ">>> User & System"
echo "User: $(whoami) (UID: $(id -u), GID: $(id -g))"
echo "Hostname: $(hostname)"
echo "PWD: $(pwd)"
echo "TZ: ${TZ:-unset}"

echo -e "\n>>> Environment Variables"
echo "PATH: $PATH"
echo "DEPOT_TOOLS_UPDATE: ${DEPOT_TOOLS_UPDATE:-<unset>}"
echo "ROOT: ${ROOT:-<unset>}"
echo "SRC: ${SRC:-<unset>}"

echo -e "\n>>> Python Configuration"
echo "which python3: $(which python3)"
if command -v python3 &>/dev/null; then
    python3 --version
    echo "python3 sys.path:"
    python3 -c "import sys; print(sys.path)"
fi

echo -e "\n>>> depot_tools Inspection"
DEPOT_TOOLS_DIR="/opt/depot-tools"
if [ -d "$DEPOT_TOOLS_DIR" ]; then
    echo "depot_tools exists at $DEPOT_TOOLS_DIR"
    WRAPPER="$DEPOT_TOOLS_DIR/python-bin/python3"
    ls -la "$WRAPPER" 2>/dev/null || echo "  ! python-bin/python3 not found"
    if [ -f "$WRAPPER" ]; then
        echo "  - Wrapper Content:"
        head -n 20 "$WRAPPER"
        echo "  ... (truncated)"
    fi
    
    RELDIR_FILE="$DEPOT_TOOLS_DIR/python3_bin_reldir.txt"
    if [ -f "$RELDIR_FILE" ]; then
        REL_DIR=$(cat "$RELDIR_FILE" | tr -d '[:space:]')
        echo "  - python3_bin_reldir.txt content: [$REL_DIR]"
        TARGET_PYTHON="$DEPOT_TOOLS_DIR/$REL_DIR/python3"
        echo "  - Checking target python: $TARGET_PYTHON"
        if [ -f "$TARGET_PYTHON" ]; then
             echo "    [OK] Target python exists."
             ls -la "$TARGET_PYTHON"
             REAL_PYTHON=$(readlink -f "$TARGET_PYTHON")
             echo "    Real path: $REAL_PYTHON"
             file "$REAL_PYTHON"
             "$TARGET_PYTHON" --version
             
             echo -e "\n>>> Inspecting GN entry point"
             if [ -f "$DEPOT_TOOLS_DIR/gn" ]; then
                 ls -la "$DEPOT_TOOLS_DIR/gn"
                 head -n 20 "$DEPOT_TOOLS_DIR/gn"
             else
                 echo "    gn not found in depot_tools"
             fi
             
             echo -e "\n>>> Testing Wrapper Explicitly"
             "$WRAPPER" -c "print('Wrapper test success')" || echo "Wrapper test FAILED"
             
             echo -e "\n>>> Testing GN with minimal args"
             bash -x "$DEPOT_TOOLS_DIR/gn" --version 2>&1 | head -n 50 || echo "GN test FAILED"
        else
             echo "    [FAIL] Target python MISSING!"
             echo "    Contents of $DEPOT_TOOLS_DIR:"
             ls -F "$DEPOT_TOOLS_DIR" | grep "bootstrap" || echo "    No bootstrap dirs found"
        fi
    else
        echo "  ! python3_bin_reldir.txt NOT FOUND"
    fi
else
    echo "! /opt/depot-tools NOT FOUND"
fi

echo -e "\n>>> Git Configuration"
git --version
git config --list --show-origin || echo "Failed to list git config"
echo "Current File Permissions:"
ls -la /workspace/packages/pdfium/scripts/build.sh

echo "================================================================================"
echo "                       END DEBUG INFO - STARTING BUILD                          "
echo "================================================================================"
