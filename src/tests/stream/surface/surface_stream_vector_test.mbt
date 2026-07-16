///|
test "pdf stream writer receives output chunks" {
  let chunks : Array[Bytes] = []
  let surface = @cairoon.Surface::pdf_stream(10.0, 10.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  paint_stream_surface(surface)
  inspect(chunks.length() > 0, content="true")
  inspect(stream_chunks_contain(chunks, "%PDF-1."), content="true")
  inspect(stream_chunks_contain(chunks, "%%EOF"), content="true")
}

///|
test "ps stream writer receives output chunks" {
  let chunks : Array[Bytes] = []
  let surface = @cairoon.Surface::ps_stream(10.0, 10.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  paint_stream_surface(surface)
  inspect(chunks.length() > 0, content="true")
  inspect(stream_chunks_contain(chunks, "%!PS-Adobe-3.0"), content="true")
  inspect(stream_chunks_contain(chunks, "%%EOF"), content="true")
}

///|
test "svg stream writer receives output chunks" {
  let chunks : Array[Bytes] = []
  let surface = @cairoon.Surface::svg_stream(10.0, 10.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
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
    expect_vector_stream_write_error(kind, @cairoon.WriteError)
  }
}

///|
test "vector stream writer closed before finish maps to cairo IO error" {
  for kind in 0..<3 {
    expect_vector_stream_closed_before_finish_error(kind)
  }
}

///|
test "stream writer invalid status maps to write error" {
  for kind in 0..<3 {
    expect_vector_stream_write_error(kind, @cairoon.LastStatus)
  }
}

///|
test "surface with_finished preserves closure error after sticky stream error" {
  let surface = @cairoon.Surface::pdf_stream(10.0, 10.0, fn(_) {
    @cairoon.WriteError
  })
  let saw_write_error = Ref(false)
  let result = @cairoon.run_cairo(() => {
    surface.with_finished(() => {
      match @cairoon.run_cairo(() => surface.show_page()) {
        Err(@cairoon.CairoIOError(@cairoon.WriteError, _)) =>
          saw_write_error.val = true
        _ => ()
      }
      surface.pdf_set_page_label("bad\u{0}label")
    })
  })
  inspect(saw_write_error.val, content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected original InvalidString closure error")
  }
}
