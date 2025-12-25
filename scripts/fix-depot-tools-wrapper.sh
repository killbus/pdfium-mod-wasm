#!/bin/bash
# Fix depot_tools to avoid Python wrapper recursion
# Root cause: gn script calls wrapper, which modifies PATH, causing infinite loop
# Solution: Patch gn to directly call the bootstrapped Python binary

set -e

DEPOT_TOOLS="/opt/depot-tools"
GN_SCRIPT="$DEPOT_TOOLS/gn"
RELDIR_FILE="$DEPOT_TOOLS/python3_bin_reldir.txt"

if [ ! -f "$GN_SCRIPT" ]; then
    echo "ERROR: gn script not found at $GN_SCRIPT"
    exit 1
fi

if [ ! -f "$RELDIR_FILE" ]; then
    echo "ERROR: python3_bin_reldir.txt not found"
    exit 1
fi

# Read the bootstrap python path
PYTHON_RELDIR=$(cat "$RELDIR_FILE" | tr -d '[:space:]')
PYTHON_BIN="$DEPOT_TOOLS/$PYTHON_RELDIR/python3.11"

if [ ! -f "$PYTHON_BIN" ]; then
    echo "ERROR: Bootstrap Python not found at $PYTHON_BIN"
    exit 1
fi

echo "Patching gn script to use bootstrap Python directly..."
echo "Target Python: $PYTHON_BIN"

# Replace the wrapper call with direct Python call
sed -i "s|PYTHONDONTWRITEBYTECODE=1 \"\$base_dir/python-bin/python3\"|PYTHONDONTWRITEBYTECODE=1 \"$PYTHON_BIN\"|" "$GN_SCRIPT"

echo "Patch applied successfully."
echo "Modified gn script:"
tail -n 5 "$GN_SCRIPT"
