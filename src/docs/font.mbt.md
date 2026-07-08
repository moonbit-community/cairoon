# Fonts

cairoon exposes Cairo's portable font API through three owner types:
`FontOptions`, `FontFace`, and `ScaledFont`. Toy font faces are the pycairo
portable font-face surface; FreeType and user-font backends are intentionally
outside the pycairo-migration product scope unless a later extension layer is
designed.

Font and text APIs encode MoonBit `String` values to UTF-8 before calling Cairo
and reject embedded NUL bytes with `CairoInvalidArgument(InvalidString, _)`.

## Font Options

`FontOptions` owns a `cairo_font_options_t *`. State setters mutate the option
object, `copy` creates an independent Cairo object, and `merge` follows Cairo's
field merge behavior. Raw C-int enum methods are compatibility APIs for
pycairo's C glue; prefer typed methods unless porting code that intentionally
passes or observes raw Cairo enum values.

```mbt check
///|
test "font docs: font options state copy and merge" {
  let options = FontOptions::new()
  debug_inspect(options.get_antialias(), content="AntialiasDefault")
  inspect(options.get_variations() is None, content="true")

  options.set_antialias(AntialiasGray)
  options.set_subpixel_order(SubpixelVrgb)
  options.set_hint_style(HintStyleSlight)
  options.set_hint_metrics(HintMetricsOff)
  options.set_color_mode(ColorModeColor)
  options.set_color_palette(42U)
  options.set_variations(Some("wght=200,wdth=140.5"))

  let copied = options.copy()
  inspect(options.equal(copied), content="true")
  debug_inspect(copied.get_antialias(), content="AntialiasGray")
  debug_inspect(copied.get_subpixel_order(), content="SubpixelVrgb")
  debug_inspect(copied.get_hint_style(), content="HintStyleSlight")
  debug_inspect(copied.get_hint_metrics(), content="HintMetricsOff")
  debug_inspect(copied.get_color_mode(), content="ColorModeColor")
  inspect(copied.get_color_palette().reinterpret_as_int(), content="42")
  match copied.get_variations() {
    Some(variations) => inspect(variations, content="wght=200,wdth=140.5")
    None => fail("expected variations")
  }

  copied.set_hint_style_raw(42)
  inspect(copied.get_hint_style_raw(), content="42")
  match run_cairo(() => copied.get_hint_style()) {
    Err(CairoInvalidArgument(InvalidStatus, _)) => ()
    _ => @test.fail("expected unknown raw hint style to stay outside typed API")
  }
  copied.set_hint_style_raw(0)

  let target = FontOptions::new()
  target.merge(options)
  debug_inspect(target.get_antialias(), content="AntialiasGray")
}
```

## Color Palettes

Cairo 1.18 font color options are represented by typed enums and unsigned
palette indexes.

```mbt check
///|
test "font docs: color palette custom colors" {
  let options = FontOptions::new()
  inspect(options.get_color_palette() == COLOR_PALETTE_DEFAULT, content="true")
  options.set_custom_palette_color(7U, 0.25, 0.5, 0.75, 1.0)
  debug_inspect(
    options.get_custom_palette_color(7U),
    content="(0.25, 0.5, 0.75, 1)",
  )
}
```

## Toy Font Faces

`FontFace::toy` maps pycairo's `ToyFontFace`. `toy_raw` and
`select_font_face_raw` are compatibility helpers for pycairo's C-int slant and
weight parsing; known raw values round trip through raw getters, while invalid
values map to Cairo's `InvalidSlant`/`InvalidWeight` status. Context setters
retain and return referenced wrappers for the same Cairo font-face pointer.

```mbt check
///|
test "font docs: toy font face and context round trip" {
  let face = FontFace::toy(
    "serif",
    slant=FontSlantItalic,
    weight=FontWeightBold,
  )
  inspect(face.get_family(), content="serif")
  debug_inspect(face.get_slant(), content="FontSlantItalic")
  debug_inspect(face.get_weight(), content="FontWeightBold")
  inspect(face.get_slant_raw(), content="1")
  inspect(face.get_weight_raw(), content="1")

  let raw_face = FontFace::toy_raw("serif", slant=2, weight=1)
  inspect(raw_face.get_slant_raw(), content="2")
  inspect(raw_face.get_weight_raw(), content="1")
  match
    run_cairo(() => {
      let _ = FontFace::toy_raw("serif", slant=42)
      ()
    }) {
    Err(CairoError(InvalidSlant, _)) => ()
    _ => @test.fail("expected invalid raw slant to fail")
  }

  let ctx = Context::new(Surface::image(Rgb24, 8, 8))
  ctx.set_font_face(Some(face))
  let returned = ctx.get_font_face()
  inspect(returned.equal(face), content="true")
  inspect(returned.get_family(), content="serif")
  ctx.select_font_face_raw("serif", slant=2, weight=1)
  debug_inspect(ctx.get_font_face().get_slant(), content="FontSlantOblique")
  ctx.set_font_face(None)
  inspect(ctx.get_font_face().status().is_success(), content="true")
}
```

## Context Font Options

Surfaces and contexts expose font options wrappers. A context returns a copied
font-options object for inspection after `set_font_options`.

```mbt check
///|
test "font docs: surface and context font options" {
  let surface = Surface::image(Rgb24, 4, 4)
  inspect(surface.get_font_options().status().is_success(), content="true")

  let options = FontOptions::new()
  options.set_antialias(AntialiasGray)
  options.set_hint_style(HintStyleMedium)

  let ctx = Context::new(surface)
  ctx.set_font_options(options)
  let returned = ctx.get_font_options()
  debug_inspect(returned.get_antialias(), content="AntialiasGray")
  debug_inspect(returned.get_hint_style(), content="HintStyleMedium")
}
```

## Scaled Fonts

`ScaledFont` owns a `cairo_scaled_font_t *`. The scale matrix is the Cairo
combination of the font matrix and CTM with translation removed.

```mbt check
///|
test "font docs: scaled font matrices and metrics" {
  let face = FontFace::toy("serif", weight=FontWeightBold)
  let options = FontOptions::new()
  options.set_antialias(AntialiasGray)
  let font_matrix = Matrix::new(xx=12.0, yy=12.0)
  let ctm = Matrix::new(xx=2.0, yy=3.0, x0=5.0, y0=7.0)
  let scaled = ScaledFont::new(face, font_matrix, ctm, options)

  debug_inspect(
    scaled.get_font_matrix(),
    content="{ xx: 12, yx: 0, xy: 0, yy: 12, x0: 0, y0: 0 }",
  )
  debug_inspect(
    scaled.get_ctm(),
    content="{ xx: 2, yx: 0, xy: 0, yy: 3, x0: 0, y0: 0 }",
  )
  debug_inspect(
    scaled.get_scale_matrix(),
    content="{ xx: 24, yx: 0, xy: 0, yy: 36, x0: 0, y0: 0 }",
  )

  let extents = scaled.extents()
  inspect(extents.height > 0.0, content="true")
  inspect(extents.ascent >= 0.0, content="true")
  let text = scaled.text_extents("foo")
  inspect(text.x_advance > 0.0, content="true")
  inspect(text.y_advance, content="0")
}
```

## Text To Glyphs

`ScaledFont::text_to_glyphs` returns copied pure MoonBit values: glyphs,
clusters, and cluster flags. `text_to_glyphs_only` maps pycairo's
`with_clusters=False` behavior.

```mbt check
///|
test "font docs: text to glyphs and glyph extents" {
  let ctx = Context::new(Surface::image(Argb32, 32, 16))
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  let scaled = ctx.get_scaled_font()
  let run = scaled.text_to_glyphs(2.0, 12.0, "a")
  inspect(run.glyphs.length(), content="1")
  inspect(run.clusters.length(), content="1")
  inspect(run.clusters[0].num_bytes, content="1")
  inspect(run.clusters[0].num_glyphs, content="1")
  debug_inspect(run.flags, content="TextClusterNone")
  inspect(scaled.text_to_glyphs_only(2.0, 12.0, "a").length(), content="1")

  let extents = scaled.glyph_extents(run.glyphs)
  inspect(extents.x_advance > 0.0, content="true")
}
```

## Checked Errors

Font APIs surface invalid strings and invalid indexes through checked
`CairoError` variants.

```mbt check
///|
test "font docs: invalid font inputs are checked errors" {
  let options = FontOptions::new()
  match
    run_cairo(() => {
      let _ = options.get_custom_palette_color(99U)
      ()
    }) {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }

  match run_cairo(() => FontFace::toy("bad\u{0}family")) {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }

  let scaled = Context::new(Surface::image(Argb32, 8, 8)).get_scaled_font()
  match
    run_cairo(() => {
      let _ = scaled.text_to_glyphs(0.0, 0.0, "bad\u{0}text")
      ()
    }) {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
}
```
