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
