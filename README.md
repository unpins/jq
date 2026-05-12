# jq

Standalone build of [jq](https://jqlang.org/). Runs on any Linux, macOS or Windows without external dependencies.

## Installation

You can install this package instantly using the [unpin](https://github.com/unpins/unpin) package manager:

```bash
unpin jq
```

Or run it without installing:

```bash
unpin run jq
```

## Build locally

```bash
nix build github:unpins/jq
./result/bin/jq
```

Or, in one shot:

```bash
nix run github:unpins/jq
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual Download

Standalone binaries and data packages are available on the [Releases](https://github.com/unpins/jq/releases) page.
