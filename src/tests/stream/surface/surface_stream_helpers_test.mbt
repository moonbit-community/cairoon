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
fn make_png_surface() -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(Argb32, 2, 2)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface
}

///|
fn make_png_bytes() -> Bytes raise @cairoon.CairoError {
  let chunks : Array[Bytes] = []
  let surface = make_png_surface()
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
fn paint_stream_surface(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
fn make_vector_stream_surface_returning_status(
  kind : Int,
  status : @cairoon.Status,
) -> @cairoon.Surface raise @cairoon.CairoError {
  match kind {
    0 => @cairoon.Surface::pdf_stream(10.0, 10.0, fn(_) { status })
    1 => @cairoon.Surface::ps_stream(10.0, 10.0, fn(_) { status })
    _ => @cairoon.Surface::svg_stream(10.0, 10.0, fn(_) { status })
  }
}

///|
fn make_vector_stream_surface_with_close_flag(
  kind : Int,
  closed : Ref[Bool],
) -> @cairoon.Surface raise @cairoon.CairoError {
  match kind {
    0 =>
      @cairoon.Surface::pdf_stream(10.0, 10.0, fn(_) {
        if closed.val {
          WriteError
        } else {
          Success
        }
      })
    1 =>
      @cairoon.Surface::ps_stream(10.0, 10.0, fn(_) {
        if closed.val {
          WriteError
        } else {
          Success
        }
      })
    _ =>
      @cairoon.Surface::svg_stream(10.0, 10.0, fn(_) {
        if closed.val {
          WriteError
        } else {
          Success
        }
      })
  }
}

///|
fn expect_vector_stream_write_error(
  kind : Int,
  status : @cairoon.Status,
) -> Unit raise {
  let result = @cairoon.run_cairo(() => {
    let surface = make_vector_stream_surface_returning_status(kind, status)
    paint_stream_surface(surface)
  })
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError from vector stream writer")
  }
}

///|
fn expect_vector_stream_closed_before_finish_error(kind : Int) -> Unit raise {
  let closed = Ref(false)
  let surface = make_vector_stream_surface_with_close_flag(kind, closed)
  closed.val = true
  let result = @cairoon.run_cairo(() => paint_stream_surface(surface))
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError from closed vector stream writer")
  }
}

///|
fn expect_png_stream_write_error(status : @cairoon.Status) -> Unit raise {
  let surface = @cairoon.Surface::image(Argb32, 2, 2)
  let result = @cairoon.run_cairo(() => {
    surface.write_to_png_stream(fn(_) { status })
  })
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError from PNG stream writer")
  }
}
