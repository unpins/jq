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

## Manual download

The [Releases](https://github.com/unpins/jq/releases) page has standalone binaries and a `.tar.zst` data archive (man pages and completions) for manual download.
