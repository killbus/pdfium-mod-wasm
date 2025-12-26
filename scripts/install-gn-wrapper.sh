#!/usr/bin/env bash
set -euo pipefail

echo "Replacing depot_tools gn wrapper with real binary..."

# Backup original gn script
if [ ! -f "/opt/depot-tools/gn.original" ]; then
  mv /opt/depot-tools/gn /opt/depot-tools/gn.original
  echo "✅ Backed up original gn script"
fi

# Find real gn binary
REAL_GN="/opt/pdfium-bootstrap/pdfium/buildtools/linux64/gn"

if [ ! -f "$REAL_GN" ]; then
  echo "❌ ERROR: Real gn binary not found at $REAL_GN"
  exit 1
fi

# Copy real gn binary to depot_tools
cp "$REAL_GN" /opt/depot-tools/gn
chmod +x /opt/depot-tools/gn

echo "✅ Replaced gn wrapper with real binary"
echo "   Source: $REAL_GN"
echo "   Target: /opt/depot-tools/gn"

# Verify
echo ""
echo "Verification:"
file /opt/depot-tools/gn
/opt/depot-tools/gn --version 2>&1 || echo "Note: --version not supported"

echo ""
echo "Testing gn help:"
/opt/depot-tools/gn help gen | head -30

