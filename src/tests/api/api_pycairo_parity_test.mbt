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
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 300, 300)
  let ctx = @cairoon.Context::new(surface)
  ctx.scale(300.0, 300.0)
  ctx.set_line_width(0.04)
  ctx.select_font_face(
    "Sans",
    slant=@cairoon.FontSlantNormal,
    weight=@cairoon.FontWeightNormal,
  )
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
    @cairoon.Success
  })
  @cairoon.Context::new(surface)
}

///|
fn make_ps_context_with_local_surface(
  chunks : Array[Bytes],
) -> @cairoon.Context raise {
  let surface = @cairoon.Surface::ps_stream(1.0, 1.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  @cairoon.Context::new(surface)
}

///|
fn make_pdf_pattern_with_local_surface(
  chunks : Array[Bytes],
) -> @cairoon.Pattern raise {
  let surface = @cairoon.Surface::pdf_stream(1.0, 1.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
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
test "pycairo unicode show_text smoke fixture" {
  let surface = paint_unicode_text_surface("ēxāmple.")
  inspect(has_nonzero_byte(surface.copy_data()), content="true")
}

///|
test "pycairo unicode png filename roundtrip fixture" {
  let path = "/tmp/cairoon_pycairo_unicode_ēxāmple.png"
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
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
