# cairoon

cairoon is a native MoonBit binding for the
[Cairo graphics library](https://cairographics.org/).

This project is temporarily unstable. The current version is useful for
experimentation and for light Cairo-dependent MoonBit projects, but the public
API, package layout, native link configuration, and release process may still
change before a stable release. Treat published versions before `1.0` as beta
releases and pin them deliberately.

cairoon is inspired by pycairo: it tries to stay close to Cairo's C API, while
using MoonBit-native value types, checked `CairoError` suberrors, explicit
stream callbacks, and GC-managed external objects for Cairo handles.

## Requirements

- MoonBit with native target support.
- Cairo development headers and library.
- `pkg-config` that can resolve `cairo`.
- Python 3 for the repository verification scripts.

cairoon is native-only. It does not currently target WebAssembly or JavaScript
backends because the binding depends on Cairo C FFI.

## Quick Start

For a local checkout:

```sh
scripts/configure-link-flags.sh
moon check --target native
moon test --target native
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

cairoon is reliable for the migrated slices that are marked `Done` in
`API_INVENTORY.md` and pass `./scripts/verify.sh` on your target platform. It
is not yet a full pycairo migration. The main remaining beta areas are broad
PDF/PS/SVG tag and metadata combinations, broader method-by-method context and
pattern parity, raster-source platform fuzzing, and release-platform coverage.

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
- `src/docs/context.mbt.md`: drawing state, transforms, paths, clips, groups, text,
  and glyphs.
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
type checking, pinned pycairo Context, Font, Matrix, Pattern, Region, and
Surface test parity, full MoonBit tests, executable docs, direct C Cairo oracle
tests, `moon info`, and targeted ASan runs when an ASan-capable compiler is
available.

## License

cairoon uses the same license expression as pycairo:

```text
LGPL-2.1-only OR MPL-1.1
```
