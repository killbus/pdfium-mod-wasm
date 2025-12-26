#!/usr/bin/env bash
set -euo pipefail

echo "Patching /opt/depot-tools/python-bin/python3 to prevent PATH accumulation..."

# Backup original
cp /opt/depot-tools/python-bin/python3 /opt/depot-tools/python-bin/python3.original

# Apply fix: Add PATH deduplication check
cat > /opt/depot-tools/python-bin/python3 << 'EOF'
#!/usr/bin/env bash

DEPOT_TOOLS=$(dirname "$0")/..

if [[ ! -f "$DEPOT_TOOLS/python3_bin_reldir.txt" ]]; then
  cat >&2 <<EOFMSG
python3_bin_reldir.txt not found. need to initialize depot_tools by
running gclient, update_depot_tools or ensure_bootstrap.
EOFMSG
  exit 1
fi

if [ "$OSTYPE" = "msys" ]
then
  PYTHON3_BIN_DIR="$DEPOT_TOOLS/$(sed -e 's-\\-/-g' $DEPOT_TOOLS/python3_bin_reldir.txt)"
else
  PYTHON3_BIN_DIR="$DEPOT_TOOLS/$(<"$DEPOT_TOOLS/python3_bin_reldir.txt")"
fi

# DEBUG: Show values
echo "[WRAPPER DEBUG] PYTHON3_BIN_DIR=$PYTHON3_BIN_DIR" >&2
echo "[WRAPPER DEBUG] Current PATH length: ${#PATH}" >&2
echo "[WRAPPER DEBUG] Checking if PATH contains PYTHON3_BIN_DIR..." >&2

# FIX: Only add to PATH if not already present
if [[ ":$PATH:" != *":$PYTHON3_BIN_DIR:"* ]]; then
  echo "[WRAPPER DEBUG] NOT FOUND - Adding to PATH" >&2
  PATH="$PYTHON3_BIN_DIR":"$PYTHON3_BIN_DIR/Scripts":"$PATH"
else
  echo "[WRAPPER DEBUG] FOUND - Skipping PATH addition" >&2
fi

"$PYTHON3_BIN_DIR/python3" "$@"
EOF

chmod +x /opt/depot-tools/python-bin/python3

echo "✅ Wrapper patched successfully"
echo "Showing diff:"
diff /opt/depot-tools/python-bin/python3.original /opt/depot-tools/python-bin/python3 || true
