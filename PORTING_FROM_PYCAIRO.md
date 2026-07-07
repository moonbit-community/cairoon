# Porting From pycairo

This document maps common pycairo patterns to `cairoon`. It is a migration
guide for the current MoonBit native binding, not a claim that every pycairo API
is complete. Use `API_INVENTORY.md` as the source of truth for coverage.

## Consumer Package Setup

Unlike pycairo, cairoon is not loaded from a process-wide Python extension
module. Every MoonBit executable or test package that imports cairoon must also
link the native Cairo library.

In `moon.mod`, declare the versioned dependency. For a local workspace checkout,
the same version string is still required; `moon.work` chooses the local member
instead of a registry download:

```moonbit
import {
  "CAIMEOX/cairoon@0.1.0",
}
```

When using a local checkout, create a workspace that contains both modules:

```sh
moon work init
moon work use /path/to/cairoon /path/to/consumer
```

In the package that uses cairoon, import `CAIMEOX/cairoon` and link Cairo. If
only tests import cairoon, make the import test-scoped with `for "test"`.

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

For a checkout of this repository, run `scripts/configure-link-flags.sh` to
write the platform-specific flags discovered from `pkg-config --libs cairo`.
For downstream projects, keep equivalent Cairo link flags in the consuming
package that builds the native executable or black-box tests.

After wiring the package, run a consumer-only smoke test with:

```sh
moon test . --target native --deny-warn -v
```

Plain `moon test --target native` from a workspace can run every workspace
member, including cairoon's full test suite. Use that when you want full local
verification, not just consumer integration.

## Core API Mapping

| pycairo | cairoon |
| --- | --- |
| `cairo.ImageSurface(format, width, height)` | `Surface::image(format, width, height)` |
| `cairo.ImageSurface.create_for_data(...)` | `Surface::image_for_data(data, format, width, height, stride=...)` |
| `cairo.ImageSurface.create_from_png(path)` | `Surface::image_from_png(path)` |
| `cairo.Context(surface)` | `Context::new(surface)` |
| `cairo.PDFSurface(path, width, height)` | `Surface::pdf(width, height, path=Some(path))` |
| `cairo.PDFSurface(None, width, height)` | `Surface::pdf(width, height)` |
| `cairo.PSSurface(path, width, height)` | `Surface::ps(width, height, path=Some(path))` |
| `cairo.SVGSurface(path, width, height)` | `Surface::svg(width, height, path=Some(path))` |
| stream surface write callback | `Surface::pdf_stream`, `Surface::ps_stream`, `Surface::svg_stream` |
| `cairo.Matrix(...)` | `Matrix::new(...)` |
| `cairo.Region(...)` | `Region::new`, `Region::from_rectangle`, `Region::from_rectangles` |
| `cairo.SolidPattern(...)` | `Pattern::solid_rgb` or `Pattern::solid_rgba` |
| `cairo.SurfacePattern(surface)` | `Pattern::for_surface(surface)` |
| `cairo.LinearGradient(...)` | `Pattern::linear(...)` |
| `cairo.RadialGradient(...)` | `Pattern::radial(...)` |

Most context methods keep pycairo's snake_case names, for example
`ctx.set_source_rgb`, `ctx.paint`, `ctx.stroke_preserve`, `ctx.show_text`, and
`ctx.copy_path`.

## Common Method Mapping

Surface and image operations:

| pycairo | cairoon |
| --- | --- |
| `surface.finish()` | `surface.finish()` |
| `surface.flush()` | `surface.flush()` |
| `surface.write_to_png(path)` | `surface.write_to_png(path)` |
| `surface.write_to_png(file_like)` | `surface.write_to_png_stream(fn(chunk) { ... })` |
| `surface.get_data()` | `surface.get_data()` for mutable `ImageData`, or `surface.copy_data()` for a copy |
| `surface.map_to_image(rect)` | `surface.map_to_image(extents=Some(rect))` |
| context manager cleanup | `with_finished` / `with_unmapped` helpers |

Pattern operations:

| pycairo | cairoon |
| --- | --- |
| `pattern.set_extend(cairo.Extend.REPEAT)` | `pattern.set_extend(ExtendRepeat)` |
| `pattern.set_filter(cairo.Filter.NEAREST)` | `pattern.set_filter(FilterNearest)` |
| `pattern.set_matrix(matrix)` | `pattern.set_matrix(matrix)` |
| `gradient.add_color_stop_rgba(...)` | `gradient.add_color_stop_rgba(...)` |
| `mesh.begin_patch()` / `mesh.end_patch()` | `mesh.mesh_begin_patch()` / `mesh.mesh_end_patch()` |

Font and text operations:

| pycairo | cairoon |
| --- | --- |
| `cairo.ToyFontFace(family, slant, weight)` | `FontFace::toy(family, slant=..., weight=...)` |
| `ctx.select_font_face("Sans")` | `ctx.select_font_face("Sans")` |
| `ctx.set_font_options(options)` | `ctx.set_font_options(options)` |
| `ctx.get_scaled_font()` | `ctx.get_scaled_font()` |
| `scaled.text_to_glyphs(x, y, text)` | `scaled.text_to_glyphs(x, y, text)` |
| `ctx.show_text_glyphs(text, glyphs, clusters, flags)` | `ctx.show_text_glyphs(text, glyphs, clusters, flags=flags)` |

Backend surface operations:

| pycairo | cairoon |
| --- | --- |
| `pdf.set_metadata(cairo.PDFMetadata.TITLE, text)` | `pdf.pdf_set_metadata(PDFMetadataTitle, text)` |
| `pdf.set_custom_metadata(name, value)` | `pdf.pdf_set_custom_metadata(name, value)` |
| `pdf.add_outline(...)` | `pdf.pdf_add_outline(...)` |
| `ps.set_eps(True)` | `ps.ps_set_eps(true)` |
| `ps.dsc_comment(text)` | `ps.ps_dsc_comment(text)` |
| `svg.set_document_unit(cairo.SVGUnit.PX)` | `svg.svg_set_document_unit(SVGUnitPx)` |
| `cairo.ScriptDevice(path)` | `Device::script(path)` |

## Errors

pycairo raises Python exceptions. `cairoon` functions that can fail are marked
`raise CairoError`.

```mbt check
///|
test {
  let result = run_cairo(fn() {
    let surface = Surface::image(InvalidFormat, 1, 1)
    surface.status()
  })
  inspect(result is Err(_), content="true")
}
```

Use `try`/`catch` for local handling, or `run_cairo` when a `Result` is more
convenient. `CairoError` has suberrors for memory, IO/PNG/read/write, and
invalid-argument statuses.

Typical translations:

| pycairo style | cairoon style |
| --- | --- |
| `with pytest.raises(cairo.Error): f()` | `match run_cairo(() => f()) { Err(_) => (), _ => fail(...) }` |
| inspect `err.status` | match `CairoError(status, _)` or a narrower suberror |
| invalid Python argument type | usually impossible at compile time in MoonBit |
| Cairo invalid enum/status | `CairoInvalidArgument(...)` or `CairoError(...)` depending on the status |

## Ownership And Lifetime

pycairo relies on Python reference counting. `cairoon` wraps Cairo handles as
MoonBit external objects with finalizers.

- Returned wrappers such as `Context::get_target`, `Context::get_source`,
  `Pattern::get_surface`, and Tee/script accessors keep the needed owner graph
  alive.
- `finish()` marks a surface/device finished but does not invalidate existing
  MoonBit wrappers. Later operations raise or report Cairo's finished status.
- `ImageData` and `MappedImageSurface` retain their owner wrappers. Use
  `with_finished` and `with_unmapped` helpers when a scope should enforce
  cleanup.
- MIME data is copied into C-owned storage on set and copied back into MoonBit
  `Bytes` on get. Python object identity for MIME data is not preserved.

When porting Python code that uses context managers, prefer explicit scoped
helpers in MoonBit:

```mbt check
///|
test {
  let surface = Surface::image(Argb32, 1, 1)
  surface.with_finished(() => {
    let ctx = Context::new(surface)
    ctx.paint()
  })
  debug_inspect(surface.status(), content="SurfaceFinished")
}
```

## Strings And Bytes

MoonBit `String` values are UTF-8 encoded before entering Cairo. Public APIs
reject embedded NUL bytes and map Cairo invalid-string statuses to
`CairoInvalidArgument`.

Use `Bytes` for binary payloads such as PNG streams, MIME data, and stream
writers. `Surface::copy_data()` returns a copy; `Surface::get_data()` returns a
mutable `ImageData` view for image surfaces.

## Callbacks

Stream writers return a Cairo `Status`:

```mbt check
///|
test {
  let chunks : Array[Bytes] = []
  let surface = Surface::pdf_stream(10.0, 10.0, fn(chunk) {
    chunks.push(chunk)
    Success
  })
  Context::new(surface).paint()
  surface.finish()
  inspect(chunks.length() > 0, content="true")
}
```

Raster-source patterns use MoonBit closures:

```mbt check
///|
test {
  let source = Surface::image(Argb32, 1, 1)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(fn(_, _) { source })
  inspect(pattern.raster_get_acquire() is Some(_), content="true")
}
```

If no user release callback is supplied, `cairoon` still installs its internal
release trampoline so retained acquired-surface wrappers are released.

## Porting Tests

1. Start with the public API and keep tests black-box unless private lifetime
   machinery is the target.
2. Convert Python exception assertions to `try`/`catch` or `run_cairo` checks.
3. Prefer pixel comparisons for image surfaces and normalized direct-C-oracle
   comparisons for PDF/PS/SVG.
4. Add output marker checks only for stable backend syntax. Dynamic SVG
   `source-*` ids and PS `CreationDate` are normalized in test helpers.
5. Run `./scripts/verify.sh` before considering a migrated slice complete.

## Known Differences

- The package is native-only.
- The project is temporarily unstable; pin exact versions or commits until a
  stable release is cut.
- `copy_data()` copies; mutable access is through `ImageData`.
- MIME payload identity differs from pycairo because data is copied.
- Python file-like objects are replaced by explicit MoonBit stream callbacks.
- Python `None` constructors map to explicit optional arguments or no-output
  constructors, for example `Surface::pdf(width, height)` for a no-output PDF.
- Python `int` enum passthrough is available only through documented raw helper
  methods such as `set_operator_raw`; prefer typed enums in new MoonBit code.
- Exact vector bytes are Cairo-version and backend dependent; current tests
  compare against direct Cairo C output and selected stable markers.
- The current implementation is still tracked in `API_INVENTORY.md`; do not
  assume unlisted pycairo APIs are available.
