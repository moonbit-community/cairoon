///|
test "context font face round trips mirror pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.get_font_face().status().is_success(), content="true")

  ctx.set_font_face(None)
  inspect(ctx.get_font_face().status().is_success(), content="true")

  let face = @cairoon.FontFace::toy(
    "serif",
    slant=FontSlantItalic,
    weight=FontWeightBold,
  )
  ctx.set_font_face(Some(face))
  let returned = ctx.get_font_face()
  inspect(returned.equal(face), content="true")
  inspect(returned.get_family(), content="serif")
  debug_inspect(returned.get_slant(), content="FontSlantItalic")
  debug_inspect(returned.get_weight(), content="FontWeightBold")
}

///|
test "context set_font_matrix mirrors pycairo identity fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let matrix = @cairoon.Matrix::new()
  ctx.set_font_matrix(matrix)
  assert_pycairo_context_matrix_close(ctx.get_font_matrix(), matrix)
}

///|
test "context font options round trip mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let options = ctx.get_font_options()
  options.set_antialias(AntialiasGray)
  options.set_hint_style(HintStyleSlight)

  ctx.set_font_options(options)
  options.set_antialias(AntialiasNone)
  options.set_hint_style(HintStyleFull)
  let returned = ctx.get_font_options()
  debug_inspect(returned.get_antialias(), content="AntialiasGray")
  debug_inspect(returned.get_hint_style(), content="HintStyleSlight")

  returned.set_antialias(AntialiasNone)
  returned.set_hint_style(HintStyleFull)
  let stable = ctx.get_font_options()
  debug_inspect(stable.get_antialias(), content="AntialiasGray")
  debug_inspect(stable.get_hint_style(), content="HintStyleSlight")
}

///|
test "context scaled font round trip mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let scaled_font = ctx.get_scaled_font()
  ctx.set_scaled_font(scaled_font)
  let returned = ctx.get_scaled_font()
  inspect(returned.equal(scaled_font), content="true")
  assert_pycairo_context_matrix_close(
    returned.get_font_matrix(),
    scaled_font.get_font_matrix(),
  )
}

///|
test "context empty font family selection mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.select_font_face("")
  inspect(ctx.status().is_success(), content="true")
}

///|
test "context set_font_size mirrors pycairo font matrix fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.set_font_size(42.0)
  assert_pycairo_context_matrix_close(
    ctx.get_font_matrix(),
    @cairoon.Matrix::new(xx=42.0, yy=42.0),
  )
}

///|
test "context text methods mirror pycairo fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(64, 32))
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  let context_extents = ctx.font_extents()
  let scaled_extents = ctx.get_scaled_font().extents()
  inspect(context_extents == scaled_extents, content="true")
  inspect(context_extents.height > 0.0, content="true")

  let text_extents = ctx.text_extents("foo")
  inspect(text_extents.x_advance > 0.0, content="true")
  inspect(text_extents.height > 0.0, content="true")
  let empty_extents = ctx.text_extents("")
  inspect(empty_extents.width, content="0")
  inspect(empty_extents.height, content="0")
  inspect(empty_extents.x_advance, content="0")

  ctx.move_to(2.0, 18.0)
  ctx.show_text("foo")
  assert_pycairo_context_point_close(
    ctx.get_current_point(),
    (2.0 + text_extents.x_advance, 18.0),
  )

  let path_surface = @cairoon.Surface::image(Argb32, 64, 32)
  let path_ctx = @cairoon.Context::new(path_surface)
  path_ctx.select_font_face("serif")
  path_ctx.set_font_size(16.0)
  path_ctx.move_to(2.0, 22.0)
  path_ctx.text_path("foo")
  let (x1, y1, x2, y2) = path_ctx.path_extents()
  inspect(x2 > x1, content="true")
  inspect(y2 > y1, content="true")
  path_ctx.set_source_rgb(1.0, 0.0, 0.0)
  path_ctx.fill()
  inspect(
    pycairo_context_has_nonzero_byte(path_surface.copy_data()),
    content="true",
  )
}

///|
test "context glyph methods mirror pycairo fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(64, 32))
  ctx.select_font_face("Sans")
  ctx.set_font_size(16.0)
  let glyphs = [@cairoon.Glyph::new(0UL, 2.0, 22.0)]
  let context_extents = ctx.glyph_extents(glyphs)
  let scaled_extents = ctx.get_scaled_font().glyph_extents(glyphs)
  inspect(context_extents == scaled_extents, content="true")

  let empty_extents = ctx.glyph_extents([])
  inspect(empty_extents.width, content="0")
  inspect(empty_extents.height, content="0")
  inspect(empty_extents.x_advance, content="0")

  let show_surface = @cairoon.Surface::image(Argb32, 64, 32)
  let show_ctx = @cairoon.Context::new(show_surface)
  show_ctx.select_font_face("Sans")
  show_ctx.set_font_size(16.0)
  show_ctx.set_source_rgb(1.0, 0.0, 0.0)
  show_ctx.show_glyphs(glyphs)
  inspect(
    pycairo_context_has_nonzero_byte(show_surface.copy_data()),
    content="true",
  )
  inspect(show_ctx.has_current_point(), content="false")
  inspect(show_ctx.copy_path().length(), content="0")

  let path_ctx = @cairoon.Context::new(pycairo_context_surface(64, 32))
  path_ctx.select_font_face("Sans")
  path_ctx.set_font_size(16.0)
  path_ctx.glyph_path(glyphs)
  let (x1, y1, x2, y2) = path_ctx.path_extents()
  inspect(x2 > x1, content="true")
  inspect(y2 > y1, content="true")
}

///|
test "context show_text_glyphs mirrors pycairo pdf tuple fixture" {
  let surface = @cairoon.Surface::pdf(300.0, 300.0)
  let ctx = @cairoon.Context::new(surface)
  ctx.scale(300.0, 300.0)
  ctx.select_font_face("Sans")
  ctx.set_font_size(0.08)
  ctx.set_line_width(0.09)
  let scaled_font = ctx.get_scaled_font()

  let run = scaled_font.text_to_glyphs(0.5, 0.5, "foobar")
  inspect(run.glyphs.length() > 0, content="true")
  inspect(run.clusters.length() > 0, content="true")
  ctx.show_text_glyphs("foobar", run.glyphs, run.clusters, flags=run.flags)

  let empty = scaled_font.text_to_glyphs(0.5, 0.5, "")
  inspect(empty.glyphs.length(), content="0")
  inspect(empty.clusters.length(), content="0")
  ctx.show_text_glyphs("", empty.glyphs, empty.clusters, flags=empty.flags)
  inspect(ctx.status().is_success(), content="true")
}

///|
test "context simple smoke mirrors pycairo method fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))

  ctx.clip_preserve()
  ctx.copy_page()
  let flat_path = ctx.copy_path_flat()
  inspect(flat_path.status().is_success(), content="true")
  ctx.fill()
  ctx.fill_preserve()
  let font_extents = ctx.font_extents()
  inspect(font_extents.height > 0.0, content="true")
  ctx.identity_matrix()
  ctx.new_sub_path()
  ctx.show_page()
  ctx.stroke_preserve()

  inspect(ctx.get_dash_count(), content="0")
  let font_matrix = ctx.get_font_matrix()
  inspect(font_matrix.xx > 0.0, content="true")
  inspect(font_matrix.yy > 0.0, content="true")
  inspect(ctx.get_group_target().status().is_success(), content="true")
  inspect(ctx.get_line_width() > 0.0, content="true")
  let tolerance : Double = ctx.get_tolerance()
  let miter_limit : Double = ctx.get_miter_limit()
  inspect(tolerance > 0.0, content="true")
  inspect(miter_limit > 0.0, content="true")
  assert_pycairo_context_matrix_close(ctx.get_matrix(), @cairoon.Matrix::new())
  inspect(ctx.status().is_success(), content="true")
}
