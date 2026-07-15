# Enums

cairoon exposes Cairo enum parameters as typed MoonBit enums. Prefer these
constructors over the `*_raw` compatibility methods: the typed API rejects
unrelated enum families at compile time and keeps the Cairo name visible at
the call site.

The public enum families are grouped as follows:

- Drawing state: `Antialias`, `FillRule`, `LineCap`, `LineJoin`, and
  `Operator`.
- Surfaces and devices: `Content`, `Format`, `SurfaceType`, `DeviceType`, and
  `SurfaceObserverMode`.
- Patterns: `Extend`, `Filter`, and `Dither`.
- Fonts and text: `FontSlant`, `FontWeight`, `HintMetrics`, `HintStyle`,
  `SubpixelOrder`, `ColorMode`, and `TextClusterFlags`.
- Paths and regions: `PathDataType`, `PathSegment`, and `RegionOverlap`.
- Vector backends: `PDFVersion`, `PDFMetadata`, `PDFOutlineFlags`, `PSLevel`,
  `SVGVersion`, `SVGUnit`, and `ScriptMode`.
- Errors: `Status`, documented separately in
  `src/docs/status_and_version.mbt.md`.

## Drawing State

Typed setters and getters use the same enum family. Cairo stores the state on
the context, so a successful round trip is also a compact runtime check that
the enum's C integer value is correct.

```mbt check
///|
test "enum docs: typed context state round trips" {
  let surface = Surface::image(Argb32, 2, 2)
  let context = Context::new(surface)

  context.set_antialias(AntialiasBest)
  context.set_fill_rule(FillEvenOdd)
  context.set_line_cap(LineCapRound)
  context.set_line_join(LineJoinBevel)
  context.set_operator(OperatorSource)

  debug_inspect(context.get_antialias(), content="AntialiasBest")
  debug_inspect(context.get_fill_rule(), content="FillEvenOdd")
  debug_inspect(context.get_line_cap(), content="LineCapRound")
  debug_inspect(context.get_line_join(), content="LineJoinBevel")
  debug_inspect(context.get_operator(), content="OperatorSource")
}
```

## Surface Values

`Format::stride_for_width` delegates to Cairo. Surface queries return typed
values. `get_format_raw` and `get_content_raw` provide integer compatibility
when needed; `get_type` intentionally exposes only the typed result.

```mbt check
///|
test "enum docs: image surface format content and type" {
  let format : Format = Argb32
  inspect(format.stride_for_width(3), content="12")

  let surface = Surface::image(format, 3, 2)
  debug_inspect(surface.get_format(), content="Argb32")
  debug_inspect(surface.get_content(), content="ContentColorAlpha")
  debug_inspect(surface.get_type(), content="SurfaceTypeImage")
}
```

## Pattern State

Pattern extend and filter modes are portable across the supported Cairo
range. `Dither` is available with Cairo 1.18 or newer; on the 1.15.10
compatibility floor, checked dither methods raise `InvalidStatus`.

```mbt check
///|
test "enum docs: typed pattern state round trips" {
  let pattern = Pattern::linear(0.0, 0.0, 1.0, 0.0)
  pattern.set_extend(Repeat)
  pattern.set_filter(Nearest)

  debug_inspect(pattern.get_extend(), content="Repeat")
  debug_inspect(pattern.get_filter(), content="Nearest")

  if CAIRO_VERSION >= 11800 {
    pattern.set_dither(DitherGood)
    debug_inspect(pattern.get_dither(), content="DitherGood")
  } else {
    match run_cairo(() => pattern.set_dither(DitherGood)) {
      Err(CairoError(InvalidStatus, _)) => ()
      _ => @test.fail("expected InvalidStatus on Cairo before 1.18")
    }
  }
}
```

Backend-specific enums are exercised with their constructors in
`src/docs/backend_surfaces.mbt.md`; font enums are exercised in
`src/docs/font.mbt.md`; path and region enums are exercised in their
corresponding reference files.
