# Changelog

## [Unreleased]

### Changed

- The Windows binary is now built by the same compiler as the Linux and macOS
  ones (1.03 MB to 1.02 MB). Checked on Windows 10: `--version`, `jq -n '1+1'`,
  and an accented argument comes back through unchanged.

  It now uses the Universal C Runtime, which is part of Windows 10 and later.
  On Windows 7 or 8.1 that runtime has to be installed first — it comes through
  Windows Update. The previous binary did not need it.
