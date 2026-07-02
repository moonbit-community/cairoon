///|
fn text_glyph_has_nonzero_byte(bytes : Bytes) -> Bool {
  for index in 0..<bytes.length() {
    if bytes[index].to_int() != 0 {
      return true
    }
  }
  false
}

///|
fn expect_text_glyph_invalid_string(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
}

///|
fn expect_text_glyph_invalid_matrix(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}

///|
test "scaled font text_to_glyphs handles empty and single text" {
  let ctx = Context::new(Surface::image(Argb32, 16, 16))
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  let scaled = ctx.get_scaled_font()

  let empty = scaled.text_to_glyphs(0.0, 0.0, "")
  inspect(empty.glyphs.length(), content="0")
  inspect(empty.clusters.length(), content="0")
  debug_inspect(empty.flags, content="TextClusterNone")

  let run = scaled.text_to_glyphs(2.0, 12.0, "a")
  inspect(run.glyphs.length(), content="1")
  inspect(run.clusters.length(), content="1")
  inspect(run.clusters[0].num_bytes, content="1")
  inspect(run.clusters[0].num_glyphs, content="1")
  debug_inspect(run.flags, content="TextClusterNone")
  inspect(run.glyphs[0].x, content="2")
  inspect(run.glyphs[0].y, content="12")
}

///|
test "context show_text_glyphs renders text_to_glyphs output" {
  let surface = Surface::image(Argb32, 32, 16)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  let run = ctx.get_scaled_font().text_to_glyphs(2.0, 12.0, "a")
  ctx.show_text_glyphs("a", run.glyphs, run.clusters, flags=run.flags)
  inspect(text_glyph_has_nonzero_byte(surface.copy_data()), content="true")
  inspect(ctx.copy_path().length(), content="0")
}

///|
test "text glyph APIs validate embedded nul strings" {
  let ctx = Context::new(Surface::image(Argb32, 8, 8))
  let scaled = ctx.get_scaled_font()
  expect_text_glyph_invalid_string(
    run_cairo(() => {
      let _ = scaled.text_to_glyphs(0.0, 0.0, "bad\u{0}text")
      ()
    }),
  )
  expect_text_glyph_invalid_string(
    run_cairo(() => ctx.show_text_glyphs("bad\u{0}text", [], [])),
  )
}

///|
test "context show_text_glyphs propagates existing context errors" {
  let ctx = Context::new(Surface::image(Argb32, 8, 8))
  let run = ctx.get_scaled_font().text_to_glyphs(0.0, 0.0, "a")
  let invalid_matrix = run_cairo(() => {
    ctx.set_matrix(Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(invalid_matrix is Err(_), content="true")
  expect_text_glyph_invalid_matrix(
    run_cairo(() => {
      ctx.show_text_glyphs("a", run.glyphs, run.clusters, flags=run.flags)
    }),
  )
}
