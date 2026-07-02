///|
fn expect_glyph_invalid_matrix(result : Result[Unit, CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}

///|
fn has_nonzero_byte(bytes : Bytes) -> Bool {
  for index in 0..<bytes.length() {
    if bytes[index].to_int() != 0 {
      return true
    }
  }
  false
}

///|
test "context and scaled font glyph_extents match" {
  let ctx = Context::new(Surface::image(Argb32, 32, 32))
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  let glyphs = [Glyph::new(0U, 2.0, 12.0)]
  let context_extents = ctx.glyph_extents(glyphs)
  let scaled_extents = ctx.get_scaled_font().glyph_extents(glyphs)
  inspect(context_extents == scaled_extents, content="true")

  let empty_context = ctx.glyph_extents([])
  let empty_scaled = ctx.get_scaled_font().glyph_extents([])
  inspect(empty_context == empty_scaled, content="true")
  inspect(empty_context.width, content="0")
  inspect(empty_context.height, content="0")
  inspect(empty_context.x_advance, content="0")
}

///|
test "context show_glyphs renders without changing the path" {
  let surface = Surface::image(Argb32, 32, 32)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  let glyphs = [Glyph::new(0U, 2.0, 12.0)]
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.show_glyphs(glyphs)
  inspect(has_nonzero_byte(surface.copy_data()), content="true")
  inspect(ctx.has_current_point(), content="false")
  inspect(ctx.copy_path().length(), content="0")
}

///|
test "context glyph_path creates fillable glyph path" {
  let surface = Surface::image(Argb32, 48, 24)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(16.0)
  let glyphs = [Glyph::new(0U, 2.0, 18.0)]
  ctx.glyph_path(glyphs)
  let (x1, y1, x2, y2) = ctx.path_extents()
  inspect(x2 > x1, content="true")
  inspect(y2 > y1, content="true")
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.fill()
  inspect(surface.copy_data().length() > 0, content="true")
}

///|
test "empty glyph arrays are accepted" {
  let ctx = Context::new(Surface::image(Argb32, 8, 8))
  ctx.show_glyphs([])
  ctx.glyph_path([])
  inspect(ctx.copy_path().length(), content="0")
  let extents = ctx.glyph_extents([])
  inspect(extents.width, content="0")
  inspect(extents.height, content="0")
}

///|
test "context glyph methods propagate existing context errors" {
  let ctx = Context::new(Surface::image(Argb32, 8, 8))
  let glyphs = [Glyph::new(0U, 0.0, 0.0)]
  let invalid_matrix = run_cairo(() => {
    ctx.set_matrix(Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(invalid_matrix is Err(_), content="true")
  expect_glyph_invalid_matrix(
    run_cairo(() => {
      let _ = ctx.glyph_extents(glyphs)
      ()
    }),
  )
  expect_glyph_invalid_matrix(run_cairo(() => ctx.glyph_path(glyphs)))
  expect_glyph_invalid_matrix(run_cairo(() => ctx.show_glyphs(glyphs)))
}
