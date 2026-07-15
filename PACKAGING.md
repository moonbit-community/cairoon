# Packaging And Release

`cairoon` is a native MoonBit package backed by Cairo C FFI. A releasable tree
must build against the local Cairo installation and must keep the generated
public interface, audit files, and reliability gate in sync.

## Native Dependencies

Required:

- MoonBit toolchain with native target support.
- Cairo 1.15.10 or newer development headers and library. Cairo 1.18.4 is the
  recommended production version and the upper pinned release lane.
- `pkg-config` that can resolve `cairo`.
- Python 3 for static FFI ownership and API-inventory linting.

Optional but recommended:

- An ASan-capable `clang`; Linux is the authoritative LeakSanitizer platform,
  while Homebrew LLVM is preferred for macOS AddressSanitizer runs.

## Fresh Checkout Setup

From this directory:

```sh
scripts/configure-link-flags.sh
moon check --target native
moon test --target native
```

`moon.pkg` stores concrete native link flags because MoonBit native stubs need
real compiler and linker flags. On another machine, run
`scripts/configure-link-flags.sh` before local testing. Commit `moon.pkg` flag
changes only when intentionally refreshing the package for the release host.

## Downstream Consumer Smoke Test

Before relying on a local checkout from another MoonBit project, verify both
module resolution and native Cairo linking from the consumer package.

The repository carries an isolated consumer module under
`integration/consumer` and joins it to cairoon only through
`integration/moon.work`. Run the executable gate with:

```sh
./scripts/check-downstream-consumer.sh
```

The gate checks formatting and native compilation only for the consumer smoke
package and renders and reads back a 2x2 image through the published API. It
runs that test twice: first against the source checkout through the committed
`moon.work`, then against the exact zip emitted by `moon package --list` after
extracting it into a fresh temporary workspace. The zip is integrity-tested,
must exclude the entire integration fixture, and must contain everything
needed to compile and link the public module. Temporary files are always
removed. `scripts/check-publication-archive.py` checks every member's CRC,
rejects unsafe paths, and inspects the actual zip names for `integration/`.
`scripts/configure-link-flags.sh` updates the fixture's
platform-specific Cairo link flags together with every repository test
package.

To reproduce the same structure in another project, create a local workspace
that contains both modules:

```sh
moon work init
moon work use /path/to/cairoon /path/to/consumer
```

The consumer module must declare the versioned dependency in `moon.mod`:

```moonbit
import {
  "CAIMEOX/cairoon@0.1.0",
}
```

The consumer package that builds an executable or black-box tests must import
cairoon in `moon.pkg` and carry native Cairo link flags. If only tests use the
binding, keep the import test-scoped:

```moonbit
import {
  "CAIMEOX/cairoon",
} for "test"

options(
  link: {
    "native": {
      "cc-link-flags": "-lcairo",
    },
  },
)
```

Use the platform-specific `cc-link-flags` reported by `pkg-config --libs
cairo` when `-lcairo` is not enough. A minimal black-box smoke test is:

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

Run that consumer package itself. In this repository the equivalent package is
`integration/consumer/src/smoke`:

```sh
moon test . --target native --deny-warn -v
```

In a workspace, plain `moon test --target native` may also run cairoon's own
test packages. That is useful for release verification, but it is not the
fastest downstream smoke test.

## Local Reliability Gate

Use:

```sh
./scripts/verify.sh
```

The gate runs formatting, link-flag drift checks, static FFI ownership linting,
top-level pycairo API inventory linting, all 20 pinned pycairo test-file
families (288 tests), the isolated downstream import/link/render test against
both source and extracted publication zip, archive integrity and fixture
exclusion checks, native type checking, targeted
image/scaled-font/vector/pattern oracle tests, the full native test suite,
`moon info --target native`, and package-isolated ASan/LSan tests when an
ASan-capable `clang` is available. A detected pycairo checkout must have
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
image, copies the checkout into disposable storage, checks all 765 MoonBit
tests, and runs each MoonBit package separately under ASan/LSan. Cairo's known
SVG recording-snapshot leak is accepted only after
`scripts/sanitizers/probes/cairo_recording_snapshot_probe.c` reproduces the
exact two-allocation pure-C signature without suppressions. The resulting
single-frame suppression is enabled only for
`src/tests/oracle/vector_backend`; every other package remains unsuppressed.
Source builds match `_cairo_recording_surface_snapshot`; stripped distro builds
use `cairo_restore`, with the vector package required to report exactly 16
suppressed allocations and the byte count predicted by the probe.

## Release Checklist

1. Update `version` in `moon.mod`.
2. Ensure `repository`, `license`, `keywords`, and `description` are correct in
   `moon.mod`.
3. Run `scripts/configure-link-flags.sh` on the release host, then inspect the
   `moon.pkg` link flags.
4. Run `./scripts/verify.sh`; the release cannot proceed if this fails.
5. Run `git diff -- pkg.generated.mbti` after `moon info --target native`.
   Public API changes must be intentional and documented.
6. Update `API_INVENTORY.md`, `AUDIT.md`, and `TESTING.md` with the exact API
   and verification state.
7. Confirm new public APIs have executable docs in the appropriate
   `*.mbt.md` reference file.
8. Run both pinned Cairo matrix lanes and record their exact versions and test
   counts in `AUDIT.md`.
9. Run `./scripts/check-downstream-consumer.sh`; it must pass against both the
   source checkout and extracted publication zip, and keep `integration/` out
   of the archive.
10. Commit the release state and tag it from a clean worktree.

## CI Guidance

The repository ships `.github/workflows/ci.yml`. It runs:

- Native verification on `ubuntu-latest` and `macos-latest` with ASan disabled.
- A dedicated Ubuntu job that invokes `scripts/sanitizers/run.py` directly
  with `CAIROON_ASAN_CC=clang`, `CAIROON_ASAN_AR=llvm-ar`, and Linux leak
  detection enabled. It does not repeat the ordinary full native gate, which
  keeps CI usage bounded.

Custom CI should install Cairo and `pkg-config`, then run:

```sh
scripts/configure-link-flags.sh
./scripts/verify.sh
```

If the CI image lacks an ASan-capable compiler, set `CAIROON_VERIFY_ASAN=0` and
run the ASan job separately on an image that provides `clang` plus Cairo.

## Package Scope

- `preferred_target = "native"` is intentional.
- Do not add package-wide `supported-targets = ["native"]`; gate FFI-only files
  with package targets instead.
- Keep C stubs split by Cairo API family. Test-only C helpers belong in
  `cairoon_test_*.c`, not in the runtime stub files.
- Standalone sanitizer probes belong in `scripts/sanitizers/probes/`, must end
  in `_probe.c`, and must never appear in a MoonBit `native-stub` list.
- Keep `pkg.generated.mbti` committed so reviewers can audit public API changes.
- Keep `integration/` excluded from publication; it is a local workspace and
  consumer contract test, not part of the distributed module.
