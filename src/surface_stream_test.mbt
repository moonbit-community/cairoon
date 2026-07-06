///|
fn chunks_to_string(chunks : Array[Bytes]) -> String {
  let builder = StringBuilder()
  for chunk in chunks {
    builder.write_string(@utf8.decode_lossy(chunk))
  }
  builder.to_string()
}

///|
fn stream_chunks_contain(chunks : Array[Bytes], marker : String) -> Bool {
  chunks_to_string(chunks).contains(marker)
}

///|
fn chunks_to_bytes(chunks : Array[Bytes]) -> Bytes {
  let mut bytes = Bytes::default()
  for chunk in chunks {
    bytes = bytes + chunk
  }
  bytes
}

///|
fn pressure_stream_chunk_storage() -> Int {
  let mut total = 0
  for _ in 0..<256 {
    total += Bytes::makei(257, fn(index) { index.to_byte() }).length()
  }
  total
}

///|
fn bytes_slice(bytes : Bytes, offset : Int, length : Int) -> Bytes {
  Bytes::makei(length, fn(i) { bytes[offset + i] })
}

///|
fn make_png_bytes() -> Bytes raise CairoError {
  let chunks : Array[Bytes] = []
  let surface = Surface::image(Argb32, 2, 2)
  let ctx = Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.write_to_png_stream(fn(chunk) {
    chunks.push(chunk)
    Success
  })
  chunks_to_bytes(chunks)
}

///|
fn is_png_signature(bytes : Bytes) -> Bool {
  bytes.length() >= 8 &&
  bytes[0].to_int() == 137 &&
  bytes[1].to_int() == 80 &&
  bytes[2].to_int() == 78 &&
  bytes[3].to_int() == 71 &&
  bytes[4].to_int() == 13 &&
  bytes[5].to_int() == 10 &&
  bytes[6].to_int() == 26 &&
  bytes[7].to_int() == 10
}

///|
fn paint_stream_surface(surface : Surface) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
fn make_vector_stream_surface_returning_status(
  kind : Int,
  status : Status,
) -> Surface raise CairoError {
  match kind {
    0 => Surface::pdf_stream(10.0, 10.0, fn(_) { status })
    1 => Surface::ps_stream(10.0, 10.0, fn(_) { status })
    _ => Surface::svg_stream(10.0, 10.0, fn(_) { status })
  }
}

///|
fn expect_vector_stream_write_error(kind : Int, status : Status) -> Unit raise {
  let result = run_cairo(() => {
    let surface = make_vector_stream_surface_returning_status(kind, status)
    paint_stream_surface(surface)
  })
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError from vector stream writer")
  }
}

///|
fn expect_png_stream_write_error(status : Status) -> Unit raise {
  let surface = Surface::image(Argb32, 2, 2)
  let result = run_cairo(() => surface.write_to_png_stream(fn(_) { status }))
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError from PNG stream writer")
  }
}

///|
test "pdf stream writer receives output chunks" {
  let chunks : Array[Bytes] = []
  let surface = Surface::pdf_stream(10.0, 10.0, fn(chunk) {
    chunks.push(chunk)
    Success
  })
  paint_stream_surface(surface)
  inspect(chunks.length() > 0, content="true")
  inspect(stream_chunks_contain(chunks, "%PDF-1."), content="true")
  inspect(stream_chunks_contain(chunks, "%%EOF"), content="true")
}

///|
test "ps stream writer receives output chunks" {
  let chunks : Array[Bytes] = []
  let surface = Surface::ps_stream(10.0, 10.0, fn(chunk) {
    chunks.push(chunk)
    Success
  })
  paint_stream_surface(surface)
  inspect(chunks.length() > 0, content="true")
  inspect(stream_chunks_contain(chunks, "%!PS-Adobe-3.0"), content="true")
  inspect(stream_chunks_contain(chunks, "%%EOF"), content="true")
}

///|
test "svg stream writer receives output chunks" {
  let chunks : Array[Bytes] = []
  let surface = Surface::svg_stream(10.0, 10.0, fn(chunk) {
    chunks.push(chunk)
    Success
  })
  paint_stream_surface(surface)
  inspect(chunks.length() > 0, content="true")
  inspect(
    stream_chunks_contain(chunks, "<?xml version=\"1.0\""),
    content="true",
  )
  inspect(stream_chunks_contain(chunks, "</svg>"), content="true")
}

///|
test "stream writer status maps to cairo IO error" {
  for kind in 0..<3 {
    expect_vector_stream_write_error(kind, WriteError)
  }
}

///|
test "stream writer invalid status maps to write error" {
  for kind in 0..<3 {
    expect_vector_stream_write_error(kind, LastStatus)
  }
}

///|
test "png stream writer receives image bytes" {
  let output = make_png_bytes()
  inspect(output.length() > 8, content="true")
  inspect(is_png_signature(output), content="true")
}

///|
test "stream writer chunks remain usable after callback returns" {
  let pdf_chunks : Array[Bytes] = []
  let pdf = Surface::pdf_stream(10.0, 10.0, fn(chunk) {
    pdf_chunks.push(chunk)
    Success
  })
  paint_stream_surface(pdf)

  let ps_chunks : Array[Bytes] = []
  let ps = Surface::ps_stream(10.0, 10.0, fn(chunk) {
    ps_chunks.push(chunk)
    Success
  })
  paint_stream_surface(ps)

  let svg_chunks : Array[Bytes] = []
  let svg = Surface::svg_stream(10.0, 10.0, fn(chunk) {
    svg_chunks.push(chunk)
    Success
  })
  paint_stream_surface(svg)

  let png_chunks : Array[Bytes] = []
  let image = Surface::image(Argb32, 2, 2)
  let image_ctx = Context::new(image)
  image_ctx.set_source_rgb(1.0, 0.0, 0.0)
  image_ctx.paint()
  image.write_to_png_stream(fn(chunk) {
    png_chunks.push(chunk)
    Success
  })

  let script_chunks : Array[Bytes] = []
  let script = Device::script_stream(fn(chunk) {
    script_chunks.push(chunk)
    Success
  })
  script.script_write_comment("retained stream chunk")
  let script_surface = Surface::script(script, ContentColorAlpha, 4.0, 4.0)
  let script_ctx = Context::new(script_surface)
  script_ctx.paint()
  script_surface.finish()
  script.finish()

  inspect(pressure_stream_chunk_storage() > 0, content="true")
  inspect(stream_chunks_contain(pdf_chunks, "%PDF-1."), content="true")
  inspect(stream_chunks_contain(pdf_chunks, "%%EOF"), content="true")
  inspect(stream_chunks_contain(ps_chunks, "%!PS-Adobe-3.0"), content="true")
  inspect(stream_chunks_contain(ps_chunks, "%%EOF"), content="true")
  inspect(
    stream_chunks_contain(svg_chunks, "<?xml version=\"1.0\""),
    content="true",
  )
  inspect(stream_chunks_contain(svg_chunks, "</svg>"), content="true")
  inspect(is_png_signature(chunks_to_bytes(png_chunks)), content="true")
  inspect(
    stream_chunks_contain(script_chunks, "retained stream chunk"),
    content="true",
  )
}

///|
test "png stream writer status maps to cairo IO error" {
  expect_png_stream_write_error(WriteError)
}

///|
test "png stream writer invalid status maps to write error" {
  expect_png_stream_write_error(LastStatus)
}

///|
test "png stream reader creates image surface" {
  let input = make_png_bytes()
  let offset = Ref(0)
  let surface = Surface::image_from_png_stream(fn(length) {
    let chunk = bytes_slice(input, offset.val, length)
    offset.val += length
    chunk
  })
  inspect(surface.get_width(), content="2")
  inspect(surface.get_height(), content="2")
  let format = surface.get_format()
  inspect(format == Argb32 || format == Rgb24, content="true")
  inspect(offset.val == input.length(), content="true")
}

///|
test "png stream reader short read maps to cairo IO error" {
  let input = make_png_bytes()
  let offset = Ref(0)
  let result = run_cairo(() => {
    let _ = Surface::image_from_png_stream(fn(length) {
      let available = input.length() - offset.val
      let actual = if available < length { available } else { length }
      let short = if actual > 0 { actual - 1 } else { 0 }
      let chunk = bytes_slice(input, offset.val, short)
      offset.val += short
      chunk
    })
    ()
  })
  match result {
    Err(CairoIOError(ReadError, _)) | Err(CairoIOError(PngError, _)) => ()
    _ => @test.fail("expected read failure from PNG stream reader")
  }
}
