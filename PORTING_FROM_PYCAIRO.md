# Porting From pycairo

This document maps common pycairo patterns to `cairoon`. It is a migration
guide for the current MoonBit native binding, not a claim that every pycairo API
is complete. Use `API_INVENTORY.md` as the source of truth for coverage.

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
- `copy_data()` copies; mutable access is through `ImageData`.
- MIME payload identity differs from pycairo because data is copied.
- Exact vector bytes are Cairo-version and backend dependent; current tests
  compare against direct Cairo C output and selected stable markers.
- The current implementation is still tracked in `API_INVENTORY.md`; do not
  assume unlisted pycairo APIs are available.
