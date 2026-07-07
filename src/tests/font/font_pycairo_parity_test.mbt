///|
fn pycairo_font_surface() -> @cairoon.Surface raise @cairoon.CairoError {
  @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
}

///|
fn pycairo_font_context() -> @cairoon.Context raise @cairoon.CairoError {
  @cairoon.Context::new(pycairo_font_surface())
}

///|
fn assert_pycairo_font_matrix_close(
  actual : @cairoon.Matrix,
  expected : @cairoon.Matrix,
) -> Unit raise {
  if !actual.xx.is_close(expected.xx, absolute_tolerance=0.000001) {
    @test.fail("unexpected xx")
  }
  if !actual.yx.is_close(expected.yx, absolute_tolerance=0.000001) {
    @test.fail("unexpected yx")
  }
  if !actual.xy.is_close(expected.xy, absolute_tolerance=0.000001) {
    @test.fail("unexpected xy")
  }
  if !actual.yy.is_close(expected.yy, absolute_tolerance=0.000001) {
    @test.fail("unexpected yy")
  }
  if !actual.x0.is_close(expected.x0, absolute_tolerance=0.000001) {
    @test.fail("unexpected x0")
  }
  if !actual.y0.is_close(expected.y0, absolute_tolerance=0.000001) {
    @test.fail("unexpected y0")
  }
}

///|
test "pycairo surface font options default getters fixture" {
  let options = pycairo_font_surface().get_font_options()
  debug_inspect(options.get_antialias(), content="AntialiasDefault")
  debug_inspect(options.get_subpixel_order(), content="SubpixelDefault")
  debug_inspect(options.get_hint_style(), content="HintStyleDefault")
  debug_inspect(options.get_hint_metrics(), content="HintMetricsOn")
}

///|
test "pycairo font options copy equality and merge fixture" {
  let options = @cairoon.Surface::image(@cairoon.Rgb24, 1, 1).get_font_options()
  options.set_hint_metrics(@cairoon.HintMetricsDefault)
  let copied = options.copy()
  inspect(options == copied, content="true")
  inspect(options != copied, content="false")
  inspect(options.equal(copied), content="true")
  inspect(Hash::hash(options) == Hash::hash(copied), content="true")
  debug_inspect(copied.get_hint_metrics(), content="HintMetricsDefault")

  options.set_hint_metrics(@cairoon.HintMetricsOn)
  inspect(options == copied, content="false")
  inspect(options != copied, content="true")
  inspect(options.equal(copied), content="false")
  debug_inspect(copied.get_hint_metrics(), content="HintMetricsDefault")

  copied.merge(options)
  debug_inspect(copied.get_hint_metrics(), content="HintMetricsOn")
}

///|
test "pycairo font options enum setter fixtures" {
  let options = pycairo_font_surface().get_font_options()

  options.set_antialias(@cairoon.AntialiasGray)
  debug_inspect(options.get_antialias(), content="AntialiasGray")

  options.set_hint_metrics(@cairoon.HintMetricsOff)
  debug_inspect(options.get_hint_metrics(), content="HintMetricsOff")

  options.set_hint_style(@cairoon.HintStyleSlight)
  debug_inspect(options.get_hint_style(), content="HintStyleSlight")

  options.set_subpixel_order(@cairoon.SubpixelVrgb)
  debug_inspect(options.get_subpixel_order(), content="SubpixelVrgb")
}

///|
test "pycairo font options color mode fixture" {
  let options = pycairo_font_surface().get_font_options()
  debug_inspect(options.get_color_mode(), content="ColorModeDefault")

  options.set_color_mode(@cairoon.ColorModeColor)
  debug_inspect(options.get_color_mode(), content="ColorModeColor")
}

///|
test "pycairo font options color palette fixture" {
  let options = pycairo_font_surface().get_font_options()
  inspect(
    options.get_color_palette() == @cairoon.COLOR_PALETTE_DEFAULT,
    content="true",
  )

  options.set_color_palette(42U)
  inspect(options.get_color_palette().reinterpret_as_int(), content="42")
}

///|
test "pycairo font options variations fixture" {
  let options = pycairo_font_surface().get_font_options()
  inspect(options.get_variations() is None, content="true")
  options.set_variations(Some("foo"))
  match options.get_variations() {
    Some(variations) => inspect(variations, content="foo")
    None => @test.fail("expected font variations")
  }
  options.set_variations(None)
  inspect(options.get_variations() is None, content="true")
}

///|
test "pycairo font options custom palette color fixture" {
  let options = pycairo_font_surface().get_font_options()
  let missing = @cairoon.run_cairo(() => {
    let _ = options.get_custom_palette_color(24U)
    ()
  })
  match missing {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex for missing palette color")
  }

  options.set_custom_palette_color(42U, 0.25, 0.5, 0.75, 1.0)
  let (red, green, blue, alpha) = options.get_custom_palette_color(42U)
  inspect(red, content="0.25")
  inspect(green, content="0.5")
  inspect(blue, content="0.75")
  inspect(alpha, content="1")
}

///|
test "pycairo font face and scaled font cmp hash fixture" {
  let ctx = pycairo_font_context()
  let font_face = ctx.get_font_face()
  let same_font_face = ctx.get_font_face()
  inspect(font_face == same_font_face, content="true")
  inspect(font_face != same_font_face, content="false")
  inspect(font_face.equal(same_font_face), content="true")
  inspect(Hash::hash(font_face) == Hash::hash(same_font_face), content="true")

  let scaled_font = ctx.get_scaled_font()
  let same_scaled_font = ctx.get_scaled_font()
  inspect(scaled_font == same_scaled_font, content="true")
  inspect(scaled_font != same_scaled_font, content="false")
  inspect(scaled_font.equal(same_scaled_font), content="true")
  inspect(
    Hash::hash(scaled_font) == Hash::hash(same_scaled_font),
    content="true",
  )
}

///|
test "pycairo scaled font metrics and matrix getter fixtures" {
  let scaled = pycairo_font_context().get_scaled_font()
  let extents = scaled.extents()
  inspect(extents.height > 0.0, content="true")
  inspect(extents.max_x_advance > 0.0, content="true")
  inspect(scaled.get_font_face().status().is_success(), content="true")
  inspect(scaled.get_font_options().status().is_success(), content="true")
  assert_pycairo_font_matrix_close(scaled.get_ctm(), @cairoon.Matrix::new())
  let font_matrix = scaled.get_font_matrix()
  inspect(font_matrix.xx > 0.0, content="true")
  inspect(font_matrix.yy > 0.0, content="true")
  inspect(font_matrix.x0, content="0")
  inspect(font_matrix.y0, content="0")
  let scale_matrix = scaled.get_scale_matrix()
  inspect(scale_matrix.xx > 0.0, content="true")
  inspect(scale_matrix.yy > 0.0, content="true")
  inspect(scale_matrix.x0, content="0")
  inspect(scale_matrix.y0, content="0")
}

///|
test "pycairo scaled font text and glyph extents fixtures" {
  let scaled = pycairo_font_context().get_scaled_font()

  let text = scaled.text_extents("foo")
  inspect(text.x_advance > 0.0, content="true")
  inspect(text.y_advance, content="0")

  let empty_text = scaled.text_extents("")
  inspect(empty_text.width, content="0")
  inspect(empty_text.height, content="0")
  inspect(empty_text.x_advance, content="0")
  inspect(empty_text.y_advance, content="0")

  let glyph = scaled.glyph_extents([@cairoon.Glyph::new(0UL, 0.5, 0.25)])
  inspect(glyph.x_advance >= 0.0, content="true")
  inspect(glyph.y_advance, content="0")

  let empty_glyphs = scaled.glyph_extents([])
  inspect(empty_glyphs.width, content="0")
  inspect(empty_glyphs.height, content="0")
  inspect(empty_glyphs.x_advance, content="0")
  inspect(empty_glyphs.y_advance, content="0")
}

///|
test "pycairo toy font face getter fixtures" {
  let empty = @cairoon.FontFace::toy("")
  inspect(empty.get_family(), content="Helvetica")
  debug_inspect(empty.get_slant(), content="FontSlantNormal")
  debug_inspect(empty.get_weight(), content="FontWeightNormal")

  let serif = @cairoon.FontFace::toy("serif")
  inspect(serif.get_family(), content="serif")
  debug_inspect(serif.get_slant(), content="FontSlantNormal")
  debug_inspect(serif.get_weight(), content="FontWeightNormal")

  let sans = @cairoon.FontFace::toy("sans-serif")
  inspect(sans.get_family(), content="sans-serif")
  debug_inspect(sans.get_slant(), content="FontSlantNormal")
  debug_inspect(sans.get_weight(), content="FontWeightNormal")
}

///|
test "pycairo scaled font getter and text_to_glyphs fixtures" {
  let ctx = pycairo_font_context()
  let scaled = ctx.get_scaled_font()
  inspect(scaled.get_font_face().status().is_success(), content="true")
  debug_inspect(
    scaled.get_font_options().get_hint_metrics(),
    content="HintMetricsOn",
  )
  assert_pycairo_font_matrix_close(scaled.get_ctm(), @cairoon.Matrix::new())
  let font_matrix = scaled.get_font_matrix()
  inspect(font_matrix.xx > 0.0, content="true")
  inspect(font_matrix.yy > 0.0, content="true")
  inspect(font_matrix.x0, content="0")
  inspect(font_matrix.y0, content="0")

  let empty = scaled.text_to_glyphs(0.0, 0.0, "")
  inspect(empty.glyphs.length(), content="0")
  inspect(empty.clusters.length(), content="0")
  debug_inspect(empty.flags, content="TextClusterNone")

  let single = scaled.text_to_glyphs(0.0, 0.0, "a")
  inspect(single.glyphs.length(), content="1")
  inspect(single.clusters.length(), content="1")
  debug_inspect(single.flags, content="TextClusterNone")
  inspect(
    scaled.text_to_glyphs_only(0.0, 0.0, "a") == single.glyphs,
    content="true",
  )

  let spaced = scaled.text_to_glyphs(0.0, 0.0, "a b")
  inspect(spaced.glyphs.length(), content="3")
  inspect(spaced.clusters.length(), content="3")
  inspect(spaced.glyphs[0] != spaced.glyphs[1], content="true")
}
