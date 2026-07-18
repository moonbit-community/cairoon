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
fn bytes_all_value(bytes : Bytes, value : Int) -> Bool {
  for index in 0..<bytes.length() {
    if bytes[index].to_int() != value {
      return false
    }
  }
  true
}

///|
fn chunks_to_string(chunks : Array[Bytes]) -> String {
  let builder = StringBuilder()
  for chunk in chunks {
    builder.write_string(@utf8.decode_lossy(chunk))
  }
  builder.to_string()
}

///|
fn chunks_contain_marker(chunks : Array[Bytes], marker : String) -> Bool {
  chunks_to_string(chunks).contains(marker)
}

///|
fn paint_unicode_text_surface(text : String) -> @cairoon.Surface raise {
  let surface = @cairoon.Surface::image(Argb32, 300, 300)
  let ctx = @cairoon.Context::new(surface)
  ctx.scale(300.0, 300.0)
  ctx.set_line_width(0.04)
  ctx.select_font_face("Sans", slant=FontSlantNormal, weight=FontWeightNormal)
  ctx.set_font_size(0.20)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.move_to(0.05, 0.5)
  let extents = ctx.text_extents(text)
  inspect(extents.x_advance > 0.0, content="true")
  ctx.show_text(text)
  surface
}

///|
fn make_pdf_context_with_local_surface(
  chunks : Array[Bytes],
) -> @cairoon.Context raise {
  let surface = @cairoon.Surface::pdf_stream(1.0, 1.0, fn(chunk) {
    chunks.push(chunk)
    Success
  })
  @cairoon.Context::new(surface)
}

///|
fn make_ps_context_with_local_surface(
  chunks : Array[Bytes],
) -> @cairoon.Context raise {
  let surface = @cairoon.Surface::ps_stream(1.0, 1.0, fn(chunk) {
    chunks.push(chunk)
    Success
  })
  @cairoon.Context::new(surface)
}

///|
fn make_pdf_pattern_with_local_surface(
  chunks : Array[Bytes],
) -> @cairoon.Pattern raise {
  let surface = @cairoon.Surface::pdf_stream(1.0, 1.0, fn(chunk) {
    chunks.push(chunk)
    Success
  })
  @cairoon.Pattern::for_surface(surface)
}

///|
fn paint_and_finish_target(ctx : @cairoon.Context) -> Unit raise {
  ctx.paint()
  ctx.show_page()
  ctx.get_target().finish()
}

///|
fn expect_pycairo_surface_file_obj_error(
  surface : @cairoon.Surface,
) -> Unit raise {
  let result = @cairoon.run_cairo(() => surface.finish())
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError from failing stream writer")
  }
}

///|
test "pycairo unicode show_text smoke fixture" {
  let surface = paint_unicode_text_surface("ēxāmple.")
  inspect(has_nonzero_byte(surface.copy_data()), content="true")
}

///|
test "pycairo unicode png filename roundtrip fixture" {
  let path = "/tmp/cairoon_pycairo_unicode_ēxāmple.png"
  let surface = @cairoon.Surface::image(Argb32, 10, 10)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgba(0.0, 0.25, 1.0, 1.0)
  ctx.paint()
  surface.write_to_png(path)

  let loaded = @cairoon.Surface::image_from_png(path)
  inspect(loaded.get_width(), content="10")
  inspect(loaded.get_height(), content="10")
  inspect(loaded.copy_data() == surface.copy_data(), content="true")
}

///|
test "pycairo surface destroy before context fixture" {
  let pdf_chunks : Array[Bytes] = []
  let pdf_ctx = make_pdf_context_with_local_surface(pdf_chunks)
  paint_and_finish_target(pdf_ctx)
  inspect(chunks_contain_marker(pdf_chunks, "%PDF-1."), content="true")
  inspect(chunks_contain_marker(pdf_chunks, "%%EOF"), content="true")

  let ps_chunks : Array[Bytes] = []
  let ps_ctx = make_ps_context_with_local_surface(ps_chunks)
  paint_and_finish_target(ps_ctx)
  inspect(chunks_contain_marker(ps_chunks, "%!PS-Adobe-3.0"), content="true")
  inspect(chunks_contain_marker(ps_chunks, "%%EOF"), content="true")
}

///|
test "pycairo surface destroy before surface pattern fixture" {
  let chunks : Array[Bytes] = []
  let pattern = make_pdf_pattern_with_local_surface(chunks)
  let ctx = @cairoon.Context::new(pattern.get_surface())
  paint_and_finish_target(ctx)
  inspect(chunks_contain_marker(chunks, "%PDF-1."), content="true")
  inspect(chunks_contain_marker(chunks, "%%EOF"), content="true")
}

///|
test "pycairo surface file object error fixture" {
  expect_pycairo_surface_file_obj_error(
    @cairoon.Surface::pdf_stream(100.0, 100.0, fn(_) { WriteError }),
  )
  expect_pycairo_surface_file_obj_error(
    @cairoon.Surface::ps_stream(100.0, 100.0, fn(_) { WriteError }),
  )
}

///|
test "pycairo surface has_show_text_glyphs fixture" {
  let surface = @cairoon.Surface::image(Argb32, 100, 100)
  inspect(surface.has_show_text_glyphs(), content="false")
  surface.finish()
  match @cairoon.run_cairo(() => surface.has_show_text_glyphs()) {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
test "pycairo context paint smoke fixture" {
  let surface = @cairoon.Surface::image(Argb32, 100, 100)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(1.0, 1.0, 1.0)
  ctx.set_operator(OperatorSource)
  ctx.paint()
  inspect(bytes_all_value(surface.copy_data(), 255), content="true")
}

///|
test "pycairo surface constructor smoke fixture" {
  let image = @cairoon.Surface::image(Argb32, 100, 100)
  debug_inspect(image.get_type(), content="SurfaceTypeImage")
  debug_inspect(image.get_format(), content="Argb32")
  inspect(image.get_width(), content="100")
  inspect(image.get_height(), content="100")

  let pdf_chunks : Array[Bytes] = []
  let pdf = @cairoon.Surface::pdf_stream(100.0, 100.0, fn(chunk) {
    pdf_chunks.push(chunk)
    Success
  })
  debug_inspect(pdf.get_type(), content="SurfaceTypePdf")
  pdf.finish()
  inspect(chunks_contain_marker(pdf_chunks, "%PDF-1."), content="true")
  inspect(chunks_contain_marker(pdf_chunks, "%%EOF"), content="true")

  let ps_chunks : Array[Bytes] = []
  let ps = @cairoon.Surface::ps_stream(100.0, 100.0, fn(chunk) {
    ps_chunks.push(chunk)
    Success
  })
  debug_inspect(ps.get_type(), content="SurfaceTypePs")
  ps.finish()
  inspect(chunks_contain_marker(ps_chunks, "%!PS-Adobe-3.0"), content="true")
  inspect(chunks_contain_marker(ps_chunks, "%%EOF"), content="true")

  let unbounded = @cairoon.Surface::recording(ContentColor)
  debug_inspect(unbounded.get_type(), content="SurfaceTypeRecording")
  inspect(unbounded.recording_get_extents() is None, content="true")
  let bounds = @cairoon.Rectangle::new(1.0, 1.0, 10.0, 10.0)
  let bounded = @cairoon.Surface::recording(ContentColor, extents=Some(bounds))
  match bounded.recording_get_extents() {
    Some(rect) => debug_inspect(rect.components(), content="(1, 1, 10, 10)")
    None => @test.fail("expected recording surface extents")
  }

  let svg_chunks : Array[Bytes] = []
  let svg = @cairoon.Surface::svg_stream(100.0, 100.0, fn(chunk) {
    svg_chunks.push(chunk)
    Success
  })
  debug_inspect(svg.get_type(), content="SurfaceTypeSvg")
  svg.finish()
  inspect(chunks_contain_marker(svg_chunks, "<svg"), content="true")
}

///|
test "pycairo recording surface get_extents fixture" {
  let unbounded = @cairoon.Surface::recording(ContentColor)
  inspect(unbounded.recording_get_extents() is None, content="true")

  let bounds = @cairoon.Rectangle::new(1.0, 2.0, 3.0, 4.0)
  let bounded = @cairoon.Surface::recording(ContentColor, extents=Some(bounds))
  match bounded.recording_get_extents() {
    Some(rect) => debug_inspect(rect.components(), content="(1, 2, 3, 4)")
    None => @test.fail("expected recording surface extents")
  }

  bounded.finish()
  match bounded.recording_get_extents() {
    Some(rect) => debug_inspect(rect.components(), content="(1, 2, 3, 4)")
    None => @test.fail("expected recording surface extents after finish")
  }
}
