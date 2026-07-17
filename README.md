# cairoon

cairoon is a native MoonBit binding for the
[Cairo graphics library](https://cairographics.org/).

**cairoon is temporarily unstable.** The current `0.x` series is intended for
experimentation and light Cairo-dependent MoonBit projects. The public API,
package layout, native link configuration, and release process may change
before `1.0`; pin the exact cairoon version or commit in downstream projects.

cairoon is inspired by pycairo: it tries to stay close to Cairo's C API, while
using MoonBit-native value types, checked `CairoError` suberrors, explicit
stream callbacks, and GC-managed external objects for Cairo handles.

## Requirements

- MoonBit with native target support.
- Cairo 1.15.10 or newer development headers and library. Cairo 1.18.4 is the
  recommended production version.
- `pkg-config` that can resolve `cairo`.
- Python 3 for cairoon's MoonBit pre-build configuration and repository checks.

cairoon is native-only. It does not currently target WebAssembly or JavaScript
backends because the binding depends on Cairo C FFI.

The local release matrix compiles against exact Cairo 1.15.10 and 1.18.4
sources. APIs introduced after the lower bound are compile-time feature-gated;
availability still depends on the Cairo library installed by the consumer.

## Quick Start

For a local checkout:

```sh
moon check --target native
moon test --target native
./scripts/check-downstream-consumer.sh
```

`moon.mod` runs `scripts/build/cairo_config.py` before native builds. It asks
`pkg-config` for this machine's Cairo headers and library, supplies C-stub flags
to the native package, and propagates linker flags to downstream packages.
This uses MoonBit's experimental pre-build config protocol, which is one reason
the project remains unstable; depend only on trusted cairoon releases.

`CAIRO_VERSION*` and `HAS_*` are generated release-source snapshots because
MoonBit does not currently provide dependency-side generated MoonBit source.
An unchanged archive can therefore retain the producer's constant values when
compiled against different Cairo headers. Use `cairo_version()` and
`cairo_version_string()` for runtime version decisions.

When using cairoon from another MoonBit package, import `CAIMEOX/cairoon` in the
consumer package's `moon.pkg`. Do not repeat Cairo compiler or linker flags in
the consumer; the native package propagates them:

```moonbit
import {
  "CAIMEOX/cairoon",
}
```

Example:

```moonbit
fn draw_example() -> Unit raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 200, 200)
  let ctx = @cairoon.Context::new(surface)
  ctx.scale(200.0, 200.0)
  ctx.set_line_width(0.04)
  ctx.move_to(0.1, 0.5)
  ctx.curve_to(0.4, 0.9, 0.6, 0.1, 0.9, 0.5)
  ctx.stroke()
  ctx.set_source_rgba(1.0, 0.2, 0.2, 0.6)
  ctx.set_line_width(0.02)
  ctx.move_to(0.1, 0.5)
  ctx.line_to(0.4, 0.9)
  ctx.move_to(0.6, 0.1)
  ctx.line_to(0.9, 0.5)
  ctx.stroke()
  surface.write_to_png("example.png")
}
```

## Features

- Object-oriented MoonBit wrappers for Cairo surfaces, contexts, patterns,
  paths, fonts, regions, and devices.
- Checked status handling through `Status` and `CairoError` suberrors instead
  of unchecked integer status returns.
- Image surfaces, buffer-backed image surfaces, PNG file/stream I/O, MIME data,
  mapped images, and mutable image-data views.
- PDF, PS, SVG, recording, tee, and script backend helpers for portable Cairo
  builds.
- Solid, surface, gradient, mesh, and raster-source patterns.
- Toy font faces, font options, scaled fonts, text extents, glyph extents,
  `text_to_glyphs`, and `show_text_glyphs`.
- Executable MoonBit reference examples in `src/README.mbt.md` and
  `src/docs/*.mbt.md`.
- Native and ASan/LSan/UBSan verification gates with direct C Cairo oracle
  tests for the migrated rendering slices.

## Current Stability

cairoon is suitable for light native use when the required inventory rows are
marked `Done`, the automated downstream consumer smoke test passes, and the
project is pinned. The complete portable API scope and all 20 pinned pycairo
test-source families are covered, and all 579 published declarations have
substantive API documentation. The sole global `Partial` inventory row is
test/release-platform evidence: local verification is extensive, but the
release commit still needs passing GitHub Actions evidence from the Ubuntu and
macOS native jobs plus the Ubuntu ASan/LSan/UBSan job. Platform-specific backends
remain out of scope, and no source-compatibility promise exists before `1.0`.

Linux ASan/LSan/UBSan runs each MoonBit package in a separate process. Cairo
1.15.10 and 1.18.4 both have two reproducible upstream error-path leaks covered
by this suite: an SVG recording-surface snapshot and PDF finalization after a
missing JBIG2 global segment. Standalone pure-C probes must reproduce exact
allocation signatures before the gate enables narrow LSan suppressions for
only the vector oracle and PDF backend test packages. Suppression counts and
bytes must match the probes exactly; every other package remains unsuppressed.
This does not change runtime behavior.

Platform-specific Xlib, XCB, and Win32 surfaces are outside the first portable
scope. Python-specific pycairo APIs such as `CAPI`, `get_include()`, Python
file objects, pickle behavior, and legacy uppercase enum aliases are not part
of the MoonBit API.

## Documentation

- `src/README.mbt.md`: executable package overview and smoke examples.
- `src/docs/status_and_version.mbt.md`: Cairo versions, feature constants,
  statuses, and checked suberror mapping.
- `src/docs/enums.mbt.md`: typed enum families, raw compatibility boundaries,
  and state round trips.
- `src/docs/value_types.mbt.md`: rectangles, glyphs, text clusters, and
  extents.
- `src/docs/matrix.mbt.md`: affine transforms.
- `src/docs/surface.mbt.md`: image surfaces, PNG, MIME, mapped images, and surface
  errors.
- `src/docs/backend_surfaces.mbt.md`: PDF, PS, SVG, recording, tee, and script
  backends.
- `src/docs/context.mbt.md`: drawing state, transforms, paths, clips, groups,
  text, glyphs, PDF tags, links, destinations, and content references.
- `src/docs/font.mbt.md`: font options, toy font faces, scaled fonts, and text
  conversion.
- `src/docs/path.mbt.md`, `src/docs/pattern.mbt.md`, and
  `src/docs/region.mbt.md`: the remaining public API families.
- `PORTING_FROM_PYCAIRO.md`: pycairo migration notes.
- `TESTING.md`: reliability strategy and test tiers.
- `PACKAGING.md`: native dependency and release checklist.

## Testing

Run the local reliability gate before depending on a checkout or cutting a
release:

```sh
./scripts/verify.sh
```

The gate checks formatting, generated Cairo-constant drift, the pre-build
configuration protocol, project layout, FFI
ownership annotations, API inventory and public-documentation coverage, the
reliability and public-coverage ledgers, native type checking, all 20 pinned
pycairo test-file families (288 upstream tests), the complete in-module MoonBit
native suite, one
isolated downstream-module import/link/render test against both the checkout
and extracted publication zip, publication-archive isolation, executable docs,
direct C Cairo oracle tests, `moon info`, and ASan/LSan/UBSan when a
sanitizer-capable compiler is available. Exact counts for the current audited revision are
recorded in `API_INVENTORY.md`, `AUDIT.md`, and `TESTING.md`.
The parity gate rejects an unclaimed or multiply claimed upstream
`tests/test_*.py` file.

Run the instrumented public-package coverage audit after implementation or
test changes and before a release candidate:

```sh
python3 ./scripts/check-public-coverage.py --analyze
```

It queries the linked Cairo version, selects exact semver-scoped exceptions,
and rejects newly uncovered public-facade branches or stale exceptions. Every
remaining linked-version, platform, native-invariant, and defensive branch
requires an exact entry in `scripts/public-coverage-exceptions.tsv`. Both
pinned local Cairo lanes below run this instrumented analysis automatically.
Each lane also consumes the same unmodified host-generated publication zip, so
host-specific include or library paths cannot hide in a release artifact.

Before a release candidate, run both pinned Linux compatibility lanes locally:

```sh
./scripts/test-cairo-matrix.sh cairo-1.15.10
./scripts/test-cairo-matrix.sh cairo-1.18.4
```

## License

cairoon uses the same license expression as pycairo:

```text
LGPL-2.1-only OR MPL-1.1
```
