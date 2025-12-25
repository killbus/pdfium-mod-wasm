# PDFium WASM Builder

[![Build PDFium WASM](https://github.com/killbus/pdfium-mod-wasm/actions/workflows/build.yml/badge.svg)](https://github.com/killbus/pdfium-mod-wasm/actions/workflows/build.yml)
[![Latest Release](https://img.shields.io/github/v/release/killbus/pdfium-mod-wasm)](https://github.com/killbus/pdfium-mod-wasm/releases)

This repository automatically builds the WebAssembly (WASM) version of Google's [PDFium](https://pdfium.googlesource.com/pdfium/) with **chunked save API** modifications. It provides a simple way to use `pdfium.js` as a package dependency in modern web projects directly from GitHub.

Builds are automatically triggered **weekly** and published as versioned **[GitHub Releases](https://github.com/killbus/pdfium-mod-wasm/releases)**.

## Installation & Usage

You can install this package using `pnpm`, `npm`, or `yarn`. We recommend using the `pdfium` alias for cleaner imports.

### 1. Stable Release (Recommended)

For production environments, use the latest stable version.

```bash
# Install specific version (Recommended for stability)
pnpm add pdfium@github:killbus/pdfium-mod-wasm#v6500.0.0

# OR Install from the rolling stable branch
pnpm add pdfium@github:killbus/pdfium-mod-wasm#release
```

### 2. Nightly Build

To use the absolute latest code from the upstream `main` branch (updated weekly).

```bash
# Install specific nightly build
pnpm add pdfium@github:killbus/pdfium-mod-wasm#nightly-2025.12.25-abc123

# OR Install from the rolling nightly branch
pnpm add pdfium@github:killbus/pdfium-mod-wasm#release-nightly
```

### Importing in Your Code

```javascript
import * as pdfium from 'pdfium';

// Your code to use the pdfium library...
```

---

## How It Works

This repository uses a sophisticated GitHub Actions pipeline to automate the build and release process.

### Automated Weekly Builds (`cron`)
Every Sunday, the workflow automatically:
1.  Checks upstream [killbus/pdfium](https://github.com/killbus/pdfium) for updates.
2.  Builds **two variants** in parallel:
    *   **Stable**: Latest official Chromium stable release.
    *   **Latest**: The current HEAD of the `main` branch.
3.  Publishes artifacts to separate release channels.

### Release Channels

| Channel | Branch | Tag Pattern | Description |
| :--- | :--- | :--- | :--- |
| **Stable** | `release` | `v6500.0.0` | Use for Production. |
| **Nightly** | `release-nightly` | `nightly-yyyy.mm.dd-hash` | Bleeding edge from main. |

---

## Manual Builds

You can manually trigger a build at any time via the **Actions** tab:

1.  Select **"Build PDFium WASM"** workflow.
2.  Click **"Run workflow"**.
3.  Choose a **Build Type**:
    *   `stable` / `latest`: Builds a single specific variant.
    *   `all`: Builds ALL variants immediately.
4.  (Optional) **Version Override**:
    *   Enter a specific Chromium version (e.g., `120.0.6099.109`) to build exactly that version.
    *   Leave empty to auto-resolve based on the Build Type.

## Modifications

This build includes **chunked save API** for memory-efficient streaming PDF generation.

Source code: [killbus/pdfium](https://github.com/killbus/pdfium)

## Source and License

This project builds source code from a modified PDFium repository ([killbus/pdfium](https://github.com/killbus/pdfium)). PDFium is licensed under the **BSD 3-Clause License**. Consequently, any build artifacts produced by this repository are also subject to the terms of the BSD-3-Clause License.
