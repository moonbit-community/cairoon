# Changelog

All notable changes to cairoon are recorded here. cairoon follows semantic
versioning for release identifiers, but the `0.x` series remains unstable and
does not promise source compatibility before `1.0`.

## 0.2.0 - Unreleased

This release candidate supersedes the initial Mooncakes preview and is the
first version intended for light downstream Cairo use.

### Added

- Complete portable pycairo API and test-source inventories, with explicit
  decisions for Python-runtime and platform-only APIs.
- Native PDF, PS, SVG, recording, tee, script, PNG, MIME, mapped-image,
  raster-source, font, path, pattern, region, and device workflows.
- Executable documentation for every public API family and substantive API
  comments for all published declarations.
- Source, extracted-package, and cross-host downstream contracts covering six
  public-only rendering, lifetime, value, error, PNG, and PDF-stream workflows.
- Exact Cairo 1.15.10, Ubuntu system Cairo 1.18.0, and Cairo 1.18.4 local
  compatibility lanes with package-isolated ASan, LSan, and UBSan checks.
- A strict non-uploading publish dry-run gate that validates both package
  checks, the registry's exact 202/no-change response, and package identity.

### Changed

- Reorganized the MoonBit package tree and C glue by object family while
  preserving `CAIMEOX/cairoon` as the public import path.
- Added indexing aliases and multiplication for `Matrix`, indexing aliases for
  tuple-like value types, and `Hash` for immutable extent/value records.
- Removed `Hash` from mutable `FontOptions`; hashing an object whose equality
  changes after setters violates the MoonBit hash contract.
- Declared native as the sole supported target and raised the documented Cairo
  compatibility floor to 1.15.10.

### Fixed

- Added dependency-side `pkg-config` discovery through MoonBit's experimental
  pre-build protocol, including propagated native linker flags.
- Corrected callback reference balancing, external-object cleanup, mapped-image
  unmapping, stream-constructor error cleanup, and surface buffer release.
- Made the publication archive self-contained, license-complete, independently
  consumable, and reproducible across the supported Cairo matrix.
- Hardened Ubuntu Cairo 1.18.0 compatibility and sanitizer classification for
  known upstream Cairo recording/PDF error-path leaks.

### Release status

- This version has not been uploaded to Mooncakes.
- Full local release-candidate verification passes. Hosted Ubuntu/macOS release
  evidence remains required before claiming full-product release status.

## 0.1.0 - 2026-07-06

- Published the initial unstable Mooncakes preview.
- That archive predates dependency pre-build/link propagation and the completed
  ownership, documentation, parity, packaging, and sanitizer work above. It is
  retained for provenance but is not recommended for downstream use.
