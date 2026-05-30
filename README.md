# jq

Standalone build of [jq](https://jqlang.org/).

[![CI](https://github.com/unpins/jq/actions/workflows/jq.yml/badge.svg)](https://github.com/unpins/jq/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) project — native single-binary builds with no third-party runtime dependencies.

## Installation

Install with [unpin](https://github.com/unpins/unpin):

```bash
unpin jq
```

Or run without installing:

```bash
unpin run jq
```

## Build locally

```bash
nix build github:unpins/jq
./result/bin/jq
```

Or run directly:

```bash
nix run github:unpins/jq
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Man pages

`jq.1` is embedded in the binary — read with `unpin man jq`.

## Manual download

The [Releases](https://github.com/unpins/jq/releases) page has standalone binaries for manual download.

## Build notes

- **Windows uses mingw.** jq is small portable C (libm + oniguruma + stdio); no `readdir`-style code path exercises msvcrt's ANSI quirks, so the mingw cross is the natural fit (no need for Cosmopolitan's polyfill weight).
- **Embedded standard library.** jq compiles its built-in filter library (`src/builtin.jq` — `min`, `max`, `group_by`, `to_entries`, `unique_by`, `walk`, etc.) into `builtin.inc` at build time and links it into the binary. There's no companion `.jq` file to ship.
- **mingw-specific build tweaks** (auto-applied by the flake, see comments inline):
  - `windows.pthreads` added to `buildInputs` (jq's `#include <pthread.h>` against the mingw-w64 winpthreads split that nixpkgs's `jq.nix` doesn't list).
  - `LDFLAGS=-all-static` to force the static `.a` over `.dll.a` so no `libwinpthread.dll` is copied next to the `.exe`.
  - `postFixup` runs `remove-references-to` against `jq.exe` (upstream nixpkgs only does this for `jq`, not `jq.exe`).
- No upstream features are disabled; no platforms are excluded.
