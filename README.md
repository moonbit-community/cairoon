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
- Python 3 for the repository verification scripts.

cairoon is native-only. It does not currently target WebAssembly or JavaScript
backends because the binding depends on Cairo C FFI.

The local release matrix compiles against exact Cairo 1.15.10 and 1.18.4
sources. APIs introduced after the lower bound are compile-time feature-gated;
availability still depends on the Cairo library installed by the consumer.

## Quick Start

For a local checkout:

```sh
scripts/configure-link-flags.sh
moon check --target native
moon test --target native
./scripts/check-downstream-consumer.sh
```

`moon.pkg` files store concrete native compiler and linker flags for the local
Cairo installation. Run `scripts/configure-link-flags.sh` after installing or
updating Cairo, and before testing on a new machine.

When using cairoon from another MoonBit package, import `CAIMEOX/cairoon` in the
consumer package's `moon.pkg` and make sure the consumer executable/test
package also links Cairo:

```moonbit
import {
  "CAIMEOX/cairoon",
}

options(
  link: {
    "native": {
      "cc-link-flags": "-lcairo",
    },
  },
)
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
- Native and ASan verification gates with direct C Cairo oracle tests for the
  migrated rendering slices.

## Current Stability

cairoon is suitable for light native use when the required inventory rows are
marked `Done`, the automated downstream consumer smoke test passes, and the
project is pinned. It is not yet a stable or complete pycairo replacement. The
portable API and all 20 pinned pycairo test-source families are covered, but one global
test/release-evidence row remains `Partial`, platform-specific backends are out
of scope, and no source-compatibility promise exists before `1.0`.

Linux ASan/LSan runs each MoonBit package in a separate process. Cairo 1.15.10
and 1.18.4 both have a reproducible SVG recording-surface snapshot leak in
upstream Cairo. The gate first reproduces it with a standalone pure-C program,
then applies a one-function LSan suppression only to the vector-oracle package;
all other packages remain unsuppressed. This does not change runtime behavior.

Platform-specific Xlib, XCB, and Win32 surfaces are outside the first portable
scope. Python-specific pycairo APIs such as `CAPI`, `get_include()`, Python
file objects, pickle behavior, and legacy uppercase enum aliases are not part
of the MoonBit API.

## Documentation

- `src/README.mbt.md`: executable package overview and smoke examples.
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

The gate checks formatting, Cairo link-flag drift, project layout, FFI
ownership annotations, API inventory coverage, the reliability ledger, native
type checking, all 20 pinned pycairo test-file families (288 upstream tests),
749 in-module MoonBit tests, one isolated downstream-module import/link/render
test against both the checkout and extracted publication zip,
publication-archive isolation, executable docs, direct C Cairo oracle tests,
`moon info`, and ASan/LSan when an ASan-capable compiler is available.
The parity gate rejects an unclaimed or multiply claimed upstream
`tests/test_*.py` file.

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
