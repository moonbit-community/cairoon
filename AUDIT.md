# cairoon Migration Audit

This file is the authoritative current audit. The former append-only report is
preserved without loss under `docs/audit/README.md`; historical counts there do
not override the current release ledger in `API_INVENTORY.md`.

## Audited Baseline

- Upstream pycairo is pinned to commit
  `80ea3348aff95e8441e6c3e2086371ea40528d81`. A fresh 2026-07-20 fetch found
  no newer mainline commit or public-stub drift.
- The pinned `cairo/__init__.pyi` SHA-256 is
  `d4a3d84a6652f0e4e525f5c1beda5c955b28071c247e89ec08f104f06b8e3260`.
- The executable inventory covers all 67 public top-level entries, 224
  top-level constants, 255 portable methods, four platform-specific method
  Decisions, 39 protocols/constructors, and 206 class attributes.
- All 288 upstream tests in 20 source families are mapped exactly once to
  runtime evidence, static API evidence, or an explicit product Decision.
- Production owns 349 local FFI symbols plus two deliberate direct libcairo
  symbols. All 12 raw external-object owners have allocator, finalizer,
  release-action, and 1000-iteration stress evidence.

## Architecture Audit

- The public MoonBit facade is in `src/`; raw handles and production externs
  live in responsibility-specific `src/internal/*` packages.
- Production C glue is split into 34 pycairo-style family stubs under
  `src/native`; 51 direct-C oracle stubs live separately under
  `src/tests/oracle/native`.
- External black-box tests live under `src/tests/*`, executable references
  under `src/docs`, and the independent downstream module under `integration`.
- All checked MoonBit, C, Python, and shell source files are capped at 600
  lines. Historical Markdown is split into bounded files under `docs/`.

## Product Audit

- Portable pycairo API families are `Done`; Python-runtime adapters and
  platform-native Cairo extensions are explicit `Decision` rows rather than
  silent omissions.
- All 579 published declarations have substantive `///` documentation with
  zero documentation debt. Eleven family references provide 63 executable
  examples.
- Errors map Cairo statuses into typed MoonBit `CairoError` suberrors. Object
  ownership, borrowed/owned returns, callbacks, stream state, finish/unmap
  cleanup, and finalizer fallbacks have package-local and sanitizer evidence.
- The release archive is reproduced from the checkout and verifies all 690
  members byte-for-byte, including build, audit, matrix, and test tooling.

## Latest Local Evidence

- `./scripts/verify.sh` passes 225 script tests, 841 native tests, 63 executable
  docs, all six downstream workflows in every source/archive mode, and every
  discovered package under ASan/LSan/UBSan.
- Exact Cairo 1.15.10 and Cairo 1.18.4 source lanes pass the same release gate.
- Ubuntu 24.04 system Cairo 1.18.0 passes on local arm64 and Rosetta-backed
  x86_64. The x86_64 recording signature is exactly 16 allocations/9216 bytes;
  arm64 is 16/9344. PDF suppressions remain exactly 10/2284 plus 4/68.
- The documentation-split candidate packages successfully and all 690 archive
  members match their verified source bytes.

## Gate Verdict

- API inventory: complete for portable pycairo scope, with explicit Decisions
  for nonportable or Python-runtime-only behavior.
- Behavioral parity: complete locally for all 20 upstream test families.
- Differential rendering: direct-C image, text, and PDF/PS/SVG oracle coverage
  is complete for the declared portable scope.
- Memory and lifetime: package-isolated ASan/LSan/UBSan, exact owner ledgers,
  callback-state tests, and finalizer stress all pass locally.
- Release evidence: `Partial`. GitHub run `29678818105` tested the older
  `6ecfc62` commit and failed two Ubuntu jobs whose concrete Cairo 1.18.0 and
  x86_64 signatures are fixed locally. The current candidate still requires
  passing Ubuntu/macOS native jobs and the Ubuntu sanitizer job on the shipped
  release commit.

## Known Limitations

- Mooncakes `0.1.0` is an obsolete preview. Candidate `0.2.0` must not be
  uploaded before the hosted release-commit evidence above is green.
- The native build uses MoonBit's experimental pre-build protocol and requires
  trusted Python 3 plus a `pkg-config`-discoverable Cairo installation.
- `CAIRO_VERSION*` and `HAS_*` are producer-header snapshots. Consumers must
  use `cairo_version()` and `cairo_version_string()` for runtime decisions.
- `Surface::copy_data` intentionally copies bytes; `Surface::get_data` is the
  retained mutable image view and no unscoped raw pixel pointer is exposed.
- Linux is authoritative for LSan/UBSan. macOS CI runs native verification;
  exact leak and undefined-behavior evidence comes from Linux lanes.
- This checkout was deliberately not pushed merely to trigger hosted CI.

## Historical Evidence

The complete migration narrative, old per-slice test counts, sanitizer
investigations, family audits, and prior verification transcripts are indexed
in [`docs/audit/README.md`](docs/audit/README.md).
