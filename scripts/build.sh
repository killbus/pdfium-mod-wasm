#!/usr/bin/env bash
set -euo pipefail
set -x

# GitHub Actions native build
# ROOT is set by the workflow, default to current directory if not set
ROOT=${ROOT:-$PWD}
SRC=$ROOT/packages/pdfium/pdfium-src
OUT=$SRC/out/wasm
PDFIUM=$ROOT/packages/pdfium

mkdir -p $OUT

export ROOT SRC OUT PDFIUM
export PATH="$HOME/.cargo/bin:$PATH"

###############################################################################
# step 0 – Verify dependencies exist
###############################################################################
if [[ ! -d "$SRC/third_party/llvm-build" ]]; then
  echo "❌ ERROR: PDFium dependencies not found!"
  echo "   Expected dependencies should be synced by workflow's gclient sync step"
  echo "   Please ensure the workflow completed gclient sync successfully"
  exit 1
fi

echo "✅ PDFium dependencies found"


if [[ ! -f "$OUT/args.gn" ]]; then
  # Note: Real gn binary has different parameter parsing than wrapper
  # Use --root first, then output directory, then --args
  cd "$SRC"
  gn gen "$OUT" \
    --root=. \
    --args='is_debug=false treat_warnings_as_errors=false pdf_use_skia=false pdf_enable_xfa=false pdf_enable_v8=false is_component_build=false clang_use_chrome_plugins=false pdf_is_standalone=true use_debug_fission=false use_custom_libcxx=false use_sysroot=false pdf_is_complete_lib=true pdf_use_partition_alloc=false is_clang=false symbol_level=0'
  { echo 'target_os="wasm"'; echo 'target_cpu="wasm"'; } >> "$OUT/args.gn"
  cd "$ROOT"
fi

###############################################################################
# 0.5 Apply our local build-system patches (always, they’re tiny)
###############################################################################
echo "🔧  Patching PDFium build files…"
cp -f "$PDFIUM/build/patch/build/config/BUILDCONFIG.gn" \
      "$SRC/build/config/BUILDCONFIG.gn"

cp -f "$PDFIUM/build/patch/build/toolchain/wasm/BUILD.gn" \
      "$SRC/build/toolchain/wasm/BUILD.gn"

###############################################################################
# helper – same exporter as in dev.sh
###############################################################################
gen_exports() {
  local WS=$ROOT/packages/pdfium/build/wasm
  rm -rf "$WS" && mkdir -p "$WS"

  ( cd "$SRC" &&
    find public -path public/cpp -prune -o -name '*.h' -print |
    sort | sed 's|^|#include "|;s|$|"|' ) > "$WS/all.h"

  echo '#include "../build/code/cpp/ext_api.h"' >> "$WS/all.h"

  clang -std=c11 -I"$SRC" -I"$ROOT/build/code/cpp" \
        -fsyntax-only -Xclang -ast-dump=json "$WS/all.h" > "$WS/ast.json"

  node "$PDFIUM/build/generate-functions.mjs"       "$WS/ast.json" "$WS"
  node "$PDFIUM/build/generate-runtime-methods.mjs" "$WS"
}

cd "$SRC"
###############################################################################
# real build (no watcher)
###############################################################################
echo "🛠  Building pdfium (once)…"
ninja -C "$OUT" pdfium -v
gen_exports

cd "$PDFIUM/build"
bash ./compile.esm.sh   # → pdfium.js runtime-methods.ts functions.ts
bash ./compile.sh       # → pdfium.cjs etc.

cp -f ./wasm/{runtime-methods.ts,functions.ts,pdfium.wasm,pdfium.js,pdfium.cjs} "$PDFIUM/src/vendor/"

echo "✅  pdfium.wasm (ESM + CJS) ready"
