# @killbus/pdfium

PDFium WebAssembly for the web platform with **chunked save API support**.

> **Note**: This project's structure and build configuration are inspired by [@embedpdf/pdfium](https://github.com/embedpdf/embed-pdf-viewer), with modifications to use a custom PDFium fork that includes the chunked save API.

## Features

- 🚀 **High-quality PDF rendering** powered by Google's PDFium
- 💾 **Chunked Save API** for efficient incremental PDF updates
- 📦 **Multiple bundle formats**: ESM, CommonJS, and browser-specific builds
- 🔒 **Type-safe** with full TypeScript support
- 🌐 **Universal** works in Node.js and browsers
- ⚡ **Optimized** WASM binary with tree-shaking support

## Installation

### From GitHub Release (Recommended)

```bash
npm install github:killbus/pdfium-mod-wasm#v1.0.0-<commit>
```

Replace `<commit>` with the latest release tag from [releases](https://github.com/killbus/pdfium-mod-wasm/releases).

### From Tarball

Download the tarball from [releases](https://github.com/killbus/pdfium-mod-wasm/releases), extract it, and install:

```bash
tar -xzf pdfium-wasm-*.tar.gz
npm install ./pdfium-wasm-*
```

## Usage

### Basic Example

```typescript
import { createPdfium } from '@killbus/pdfium';

const pdfium = await createPdfium();

// Load a PDF document
const doc = await pdfium.loadDocument(pdfBytes);

// Render a page
const page = await doc.getPage(0);
const bitmap = await page.render({ scale: 2 });

// Use chunked save API
const saveSession = await doc.createSaveSession();
for await (const chunk of saveSession) {
  // Process each chunk incrementally
  console.log('Chunk size:', chunk.length);
}
```

### Browser Bundle

```html
<script type="module">
  import { createPdfium } from './node_modules/@killbus/pdfium/dist/index.browser.js';
  
  const pdfium = await createPdfium();
  // Use pdfium...
</script>
```

## API Highlights

### Chunked Save API

This package includes the chunked save API, allowing you to save PDF modifications incrementally:

```typescript
const doc = await pdfium.loadDocument(originalPdfBytes);

// Make modifications to the document
// ...

// Save incrementally
const saveSession = await doc.createSaveSession();
const chunks: Uint8Array[] = [];

for await (const chunk of saveSession) {
  chunks.push(chunk);
}

const modifiedPdf = new Uint8Array(
  chunks.reduce((acc, chunk) => acc + chunk.length, 0)
);
let offset = 0;
for (const chunk of chunks) {
  modifiedPdf.set(chunk, offset);
  offset += chunk.length;
}
```

## Building from Source

### Prerequisites

- Node.js 22+
- pnpm
- Docker (for PDFium WASM build)

### Build PDFium WASM

```bash
# Build using GitHub Actions workflow (recommended)
# Trigger the "PDFium WASM Build" workflow manually

# Or build locally with Docker
pnpm run wasm:build
```

### Build npm Package

```bash
# Install dependencies
pnpm install

# Build the package
pnpm run build
```

The built files will be in `dist/`:
- `index.js` - ESM entry point
- `index.browser.js` - Browser-optimized ESM
- `index.cjs` - CommonJS entry point
- `pdfium.wasm` - WASM binary
- Type definitions and source maps

## Project Structure

```
pdfium-mod-wasm/
├── src/
│   ├── index.esm.ts          # ESM entry
│   ├── index.cjs.ts          # CommonJS entry
│   ├── base.ts               # Core PDFium wrapper
│   └── vendor/               # Generated bindings
├── pdfium-src/               # PDFium source (submodule)
├── scripts/
│   ├── build.sh              # PDFium build script
│   └── dev.sh                # Development script
├── build/
│   ├── patch/                # PDFium patches
│   └── generate-*.mjs        # Code generation scripts
└── .github/workflows/
    ├── build.yml             # WASM build workflow
    └── release.yml           # Release workflow
```

## Upstream Sources

- **PDFium Fork**: [killbus/pdfium](https://github.com/killbus/pdfium) - Custom fork with chunked save API
- **Build Structure**: Inspired by [@embedpdf/pdfium](https://github.com/embedpdf/embed-pdf-viewer)
- **Upstream PDFium**: [Google PDFium](https://pdfium.googlesource.com/pdfium/)

## License

MIT

## Acknowledgments

- Google PDFium team for the excellent PDF library
- [@embedpdf/pdfium](https://github.com/embedpdf/embed-pdf-viewer) for the build structure and configuration inspiration
