# Packaging And Release

`cairoon` is a native MoonBit package backed by Cairo C FFI. A releasable tree
must build against the local Cairo installation and must keep the generated
public interface, audit files, and reliability gate in sync.

The Mooncakes registry already contains the initial `0.1.0` preview. That
archive predates cairoon's dependency pre-build/link propagation and is not
recommended for downstream use. The current tree is the unreleased `0.2.0`
candidate. A dry run is allowed for validation; do not upload it until the
remaining hosted Ubuntu/macOS release evidence is green.

## Native Dependencies

Required:

- MoonBit toolchain with native target support.
- Cairo 1.15.10 or newer development headers and library. Cairo 1.18.4 is the
  recommended production version and the upper pinned release lane.
- `pkg-config` that can resolve `cairo`.
- Python 3 for MoonBit's Cairo pre-build configuration plus static FFI and
  API-inventory linting.

Optional but recommended:

- A sanitizer-capable `clang`; Linux is the authoritative LeakSanitizer and
  UndefinedBehaviorSanitizer platform, while Homebrew LLVM is preferred for
  macOS AddressSanitizer/UndefinedBehaviorSanitizer runs.

## Fresh Checkout Setup

From this directory:

```sh
moon check --target native
moon test --target native
```

`moon.mod` registers `scripts/build/cairo_config.py` through MoonBit's
experimental pre-build config protocol. On every native build it resolves the
local Cairo installation with `pkg-config`, supplies `${build.CAIRO_CFLAGS}` to
the two packages that compile C stubs, and propagates linker flags from
`CAIMEOX/cairoon/native` to all dependents. No `moon.pkg`, including a consumer,
may store concrete Cairo paths or `cc-link-flags`.

The pre-build script is included in the publication archive. It executes as
trusted dependency code, invokes `pkg-config` without a shell, emits only the
documented JSON protocol on stdout, and rejects Cairo older than 1.15.10. This
experimental MoonBit dependency mechanism is part of cairoon's temporary
instability contract and is covered by unit, extracted-archive, and exact-Cairo
matrix tests.

## Downstream Consumer Contract

Before relying on a local checkout from another MoonBit project, verify both
module resolution and native Cairo linking from the consumer package.

The repository carries an isolated consumer module under
`integration/consumer` and joins it to cairoon only through
`integration/moon.work`. Run the executable gate with:

```sh
./scripts/check-downstream-consumer.sh
```

The gate checks formatting and native compilation only for the consumer
contract package. Its six split workflows cover deterministic image/path/
pattern rendering, mapped-image scoped ownership, Matrix/Region values, typed
errors, PNG callback round-trip, and a finished PDF stream. It runs all 6/6
workflows first against the source checkout through the committed `moon.work`,
then against the exact zip emitted by `moon package --list` after extracting it
into a fresh temporary workspace. The zip is integrity-tested,
must exclude the entire integration fixture, and must contain everything
needed to compile and link the public module. Temporary files are always
removed. `scripts/check-publication-archive.py` checks every member's CRC,
rejects unsafe paths, and inspects the actual zip names for `integration/`.
The exact-Cairo Docker lanes pass the unmodified host-generated zip to
`scripts/check-downstream-consumer.sh --archive PATH`, proving that no release
artifact has captured the producer's include or library paths.

The archive portability guarantee covers C-stub compilation, linking, and the
runtime API. The uppercase `CAIRO_VERSION*` and `HAS_*` values are committed
MoonBit constants generated in the release source tree; they are not rewritten
inside a downstream dependency. When producer and consumer Cairo headers
differ, downstream code must use `cairo_version()` or
`cairo_version_string()` for runtime version decisions. Do not add a hidden
source-mutating build step to disguise this limitation; revisit it only when
MoonBit provides a documented dependency-safe generated-source mechanism.

To reproduce the same structure in another project, create a local workspace
that contains both modules:

```sh
moon work init
moon work use /path/to/cairoon /path/to/consumer
```

The consumer module must declare the versioned dependency in `moon.mod`:

```moonbit
import {
  "CAIMEOX/cairoon@0.2.0",
}
```

The consumer package that builds an executable or black-box tests imports
cairoon in `moon.pkg`. If only tests use the binding, keep the import
test-scoped:

```moonbit
import {
  "CAIMEOX/cairoon",
} for "test"
```

Do not repeat Cairo `cc-link-flags`; cairoon's native package propagates the
platform-specific result. A minimal black-box smoke test is:

```moonbit
///|
test "consumer can draw through cairoon" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 8, 8)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.flush()
  inspect(surface.status() == @cairoon.Success, content="true")
}
```

Run that consumer package itself. In this repository the broader six-workflow
package is `integration/consumer/src/contract`:

```sh
moon test src/contract --target native --deny-warn -v
```

In a workspace, plain `moon test --target native` may also run cairoon's own
test packages. That is useful for release verification, but it is not the
fastest downstream contract check.

## Local Reliability Gate

Use:

```sh
./scripts/verify.sh
```

The gate runs formatting, Cairo build-protocol and generated-constant checks,
static FFI ownership linting, exact external-owner/finalizer/stress evidence,
top-level pycairo API inventory linting, exact public doc-comment debt linting,
all 20 pinned pycairo test-file families (288 tests), the isolated downstream
six-workflow public consumer contract against both source and extracted
publication zip, archive integrity and fixture exclusion checks, native type
checking, targeted image/scaled-font/vector/pattern oracle tests, the full
native test suite,
`moon info --target native`, and package-isolated ASan/LSan/UBSan tests when a
sanitizer-capable `clang` is available. A detected pycairo checkout must have
exactly one ledger for every `tests/test_*.py` source file.

Set `CAIROON_VERIFY_ASAN=0` only when intentionally skipping the sanitizer
portion. Set `CAIROON_ASAN_CC` and `CAIROON_ASAN_AR` to force the compiler pair
used by that sanitizer pass without changing the ordinary native gate. Do not
set `ASAN_OPTIONS=detect_leaks=0` on Linux release evidence.

Run the exact local Cairo compatibility lanes before release:

```sh
./scripts/test-cairo-matrix.sh cairo-1.15.10
./scripts/test-cairo-matrix.sh cairo-1.18.4
```

Each lane builds Cairo from a pinned URL and SHA-256 in an isolated Docker
image, copies the checkout into disposable storage, runs the complete MoonBit
native suite, and tests each MoonBit package separately under ASan/LSan/UBSan. Exact
counts for the audited release state are recorded in `AUDIT.md` and
`TESTING.md`. The runner first proves UBSan is active with an intentional signed
overflow and LSan is active with an intentional leak. Clang's `function`
subcheck is disabled only in four non-inlined C helpers that dispatch already
type-checked MoonBit `FuncRef` values: stream read/write and raster-source
acquire/release. A script regression requires exactly those four annotations
and forbids a global `-fno-sanitize=function`; every other UBSan check and call
site remains instrumented.

Cairo's known SVG recording-snapshot leak is accepted only after
`scripts/sanitizers/probes/cairo_recording_snapshot_probe.c` reproduces the
exact two-allocation pure-C signature without suppressions. Its single-frame
suppression is enabled only for `src/tests/oracle/vector_backend`; source
builds match `_cairo_recording_surface_snapshot`, stripped distro builds use
`cairo_restore`, and the package must report exactly 16 allocations with the
byte count predicted by the probe. The reachable PDF/JBIG2 missing-global
error path is likewise accepted only after
`scripts/sanitizers/probes/cairo_pdf_jbig2_missing_probe.c` reproduces one of
the two pinned Cairo-version signatures. Its two-template suppression applies
only to `src/tests/backend/pdf`, and both suppression rows must exactly match
the probe's allocation counts and bytes. All other packages remain
unsuppressed.

## Release Checklist

1. Update `version` in `moon.mod`, the top release heading in `CHANGELOG.md`,
   both README `moon add` commands, and the integration consumer dependency.
   The publication validator must reject any mismatch.
2. Ensure `repository`, `license`, `keywords`, `description`, dependency
   import, experimental pre-build registration,
   `preferred_target = "native"`, and `supported_targets = "native"` are
   correct in `moon.mod`.
3. Confirm `COPYING`, `COPYING-LGPL-2.1`, and `COPYING-MPL-1.1` are present and
   match the SPDX expression in `moon.mod`; the publication validator must
   reject missing or mismatched legal metadata.
4. Run `python3 scripts/check-api-inventory.py` with the parent pycairo checkout
   present. If the pinned pycairo commit changes, regenerate
   `scripts/api/pycairo-api-snapshot.json` deliberately and review its source
   SHA, API sets, and product mappings before release.
5. Run `python3 scripts/check-external-owners.py`; every discovered raw owner
   must retain its structurally named C payload/finalizer, complete release
   actions, and an unconditional top-level 1000-iteration lifetime-package
   stress path in `scripts/lifetime/owners.json`.
6. Run `scripts/configure-cairo-constants.sh --check`, then confirm no
   `moon.pkg` contains concrete Cairo paths or `cc-link-flags`.
7. Run `./scripts/verify.sh`; the release cannot proceed if this fails.
8. Run `git diff -- pkg.generated.mbti` after `moon info --target native`.
   Public API changes must be intentional and documented.
9. Update `API_INVENTORY.md`, `AUDIT.md`, and `TESTING.md` with the exact API
   and verification state.
10. Confirm new public APIs have executable docs in the appropriate
   `*.mbt.md` reference file.
11. Run the Ubuntu 24.04 system-Cairo lane and both pinned source-built Cairo
   lanes, then record their exact versions and test counts in `AUDIT.md`.
12. Run `./scripts/check-downstream-consumer.sh`; all six workflows must pass
   against both the source checkout and extracted publication zip, and
   `integration/` must remain outside the archive.
13. Run `python3 scripts/check-publish-dry-run.py`. The wrapper internally fixes
    the command to `moon publish --dry-run` and requires both package checks,
    one complete exact registry status-202/no-change line, and matching package
    identity. Current Moon may return status 255 only with its exact trailing
    publish-failure banner; status 0 must have no error banner. No other nonzero
    status, separated response fragments, or incomplete response is accepted.
14. Commit the release state. Tag and upload it only from a clean worktree after
    the hosted Ubuntu/macOS release jobs pass on that exact commit.

## CI Guidance

The repository ships `.github/workflows/ci.yml`. It runs:

- Native verification on `ubuntu-latest` and `macos-latest` with ASan disabled.
- A dedicated Ubuntu job that invokes `scripts/sanitizers/run.py` directly
  with `CAIROON_ASAN_CC=clang`, `CAIROON_ASAN_AR=llvm-ar`, and Linux leak
  detection enabled. It runs ASan, LSan, and UBSan without repeating the
  ordinary full native gate, which keeps CI usage bounded.

Custom CI should install Cairo, `pkg-config`, and Python 3, then run:

```sh
scripts/configure-cairo-constants.sh
./scripts/verify.sh
```

If the CI image lacks a sanitizer-capable compiler, set `CAIROON_VERIFY_ASAN=0`
and run the sanitizer job separately on an image that provides `clang` plus
Cairo.

## Package Scope

- `preferred_target = "native"` and `supported_targets = "native"` are
  intentional module-level product metadata. Unsupported target checks must
  stop cleanly at the module boundary instead of reporting missing symbols
  from native-gated FFI files.
- Keep raw FFI files native-gated in their owning packages even though the
  module currently supports only native. File-level gates document the ABI
  boundary and remain necessary if the product later gains another backend.
- Keep C stubs split by Cairo API family. Test-only C helpers belong in
  `cairoon_test_*.c`, not in the runtime stub files.
- Standalone sanitizer probes belong in `scripts/sanitizers/probes/`, must end
  in `_probe.c`, and must never appear in a MoonBit `native-stub` list.
- Keep `pkg.generated.mbti` committed so reviewers can audit public API changes.
- Keep `integration/` excluded from publication; it is a local workspace and
  consumer contract test, not part of the distributed module.
