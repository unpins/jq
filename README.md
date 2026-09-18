# jq

[jq](https://jqlang.org/) as a single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/jq/actions/workflows/jq.yml/badge.svg)](https://github.com/unpins/jq/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install jq`.

## Usage

Run the `jq` program with [unpin](https://github.com/unpins/unpin):

```bash
unpin jq '.name' data.json
```

To install it onto your PATH:

```bash
unpin install jq
```

## Man pages

`jq.1` is embedded in the binary — read with `unpin man jq`.

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

The [Releases](https://github.com/unpins/jq/releases) page has standalone binaries for manual download.

## Build notes

- **Windows** uses mingw.
- **Embedded standard library.** jq compiles its built-in filter library (`src/builtin.jq` — `min`, `max`, `group_by`, `to_entries`, `unique_by`, `walk`, etc.) into `builtin.inc` at build time and links it into the binary. There's no companion `.jq` file to ship.
- No upstream features are disabled; no platforms are excluded.
