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
  let surface = Surface::pdf_stream(10.0, 10.0, fn(_) { WriteError })
  let result = run_cairo(() => paint_stream_surface(surface))
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError from stream writer")
  }
}

///|
test "png stream writer receives image bytes" {
  let chunks : Array[Bytes] = []
  let surface = Surface::image(Argb32, 2, 2)
  let ctx = Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.write_to_png_stream(fn(chunk) {
    chunks.push(chunk)
    Success
  })
  let output = chunks_to_bytes(chunks)
  inspect(output.length() > 8, content="true")
  inspect(is_png_signature(output), content="true")
}

///|
test "png stream writer status maps to cairo IO error" {
  let surface = Surface::image(Argb32, 2, 2)
  let result = run_cairo(() => surface.write_to_png_stream(fn(_) { WriteError }))
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError from PNG stream writer")
  }
}
