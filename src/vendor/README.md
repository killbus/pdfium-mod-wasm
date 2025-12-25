# PDFium WASM Vendor Files

This directory contains the compiled PDFium WASM binaries and generated TypeScript helpers.

## 📦 Contents

- `pdfium.wasm` - PDFium WebAssembly binary
- `pdfium.js` - Emscripten-generated ESM glue code
- `pdfium.cjs` - Emscripten-generated CommonJS glue code
- `functions.ts` - Auto-generated TypeScript function bindings
- `runtime-methods.ts` - Auto-generated runtime method declarations
- `pdfium.d.ts` / `pdfium.d.cts` - Type definitions

## 🔄 How These Files Are Generated

### In CI/CD (Production)
1. The `build.yml` workflow compiles PDFium from source
2. The `release.yml` workflow downloads build artifacts and copies them here
3. Rollup bundles the TypeScript wrapper with these WASM files

### For Local Development
If you need to work on the TypeScript wrapper without rebuilding WASM:

```bash
# Option 1: Download from latest release
npm install github:killbus/pdfium-mod-wasm#release
cp -r node_modules/@pdfium-mod-wasm/dist/* src/vendor/

# Option 2: Build WASM locally (requires environment setup)
bash scripts/build.sh
```

## ⚠️ Important Notes

- **These files are NOT committed to git** (see `.gitignore`)
- In CI/CD, they are dynamically generated from `build.yml` artifacts
- The `rollup.config.js` copies `pdfium.wasm` from here to the final `dist/` directory
- TypeScript wrapper code in `src/*.ts` uses these files during the build process

## 🏗️ Build Flow

```
build.yml (GitHub Actions)
  ↓ Compiles PDFium WASM
  ↓ Uploads artifacts
  ↓
release.yml
  ↓ Downloads artifacts
  ↓ Copies to src/vendor/  ← You are here
  ↓ Runs pnpm build (rollup)
  ↓
dist/
  ↓ Final npm package
```
