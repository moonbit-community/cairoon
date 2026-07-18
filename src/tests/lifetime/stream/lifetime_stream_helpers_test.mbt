///|
fn lifetime_paint_stream_surface(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
fn expect_lifetime_write_error(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError")
  }
}

///|
fn lifetime_record_stream_chunk(
  chunk : Bytes,
  chunk_count : Ref[Int],
  byte_count : Ref[Int],
) -> @cairoon.Status {
  chunk_count.val += 1
  byte_count.val += chunk.length()
  Success
}

///|
fn lifetime_record_stream_chunk_with_status(
  chunk : Bytes,
  chunk_count : Ref[Int],
  byte_count : Ref[Int],
  status : @cairoon.Status,
) -> @cairoon.Status {
  chunk_count.val += 1
  byte_count.val += chunk.length()
  status
}

///|
fn lifetime_png_bytes() -> Bytes raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  ctx.paint()
  let mut output = Bytes::default()
  surface.write_to_png_stream(fn(chunk) {
    output = output + chunk
    Success
  })
  output
}

///|
fn lifetime_bytes_slice(bytes : Bytes, offset : Int, length : Int) -> Bytes {
  Bytes::makei(length, fn(i) { bytes[offset + i] })
}

///|
fn next_lifetime_stream_fuzz_seed(seed : Ref[Int]) -> Int {
  seed.val = (seed.val * 131 + 71) % 7919
  seed.val
}

///|
fn expect_lifetime_stream_fuzz_success(
  result : Result[Unit, @cairoon.CairoError],
  chunk_count : Int,
  byte_count : Int,
) -> Unit raise {
  match result {
    Ok(_) => ()
    _ => @test.fail("expected successful stream callback path")
  }
  inspect(chunk_count > 0, content="true")
  inspect(byte_count > 0, content="true")
}

///|
fn expect_lifetime_stream_fuzz_write_error(
  result : Result[Unit, @cairoon.CairoError],
  chunk_count : Int,
) -> Unit raise {
  inspect(chunk_count > 0, content="true")
  match result {
    Err(CairoIOError(WriteError, _)) => ()
    _ => @test.fail("expected WriteError from fuzzed stream callback")
  }
}

///|
fn expect_lifetime_stream_fuzz_read_error(
  result : Result[Unit, @cairoon.CairoError],
  chunk_count : Int,
) -> Unit raise {
  inspect(chunk_count > 0, content="true")
  match result {
    Err(CairoIOError(ReadError, _)) | Err(CairoIOError(PngError, _)) => ()
    _ => @test.fail("expected read failure from fuzzed PNG stream callback")
  }
}

///|
fn lifetime_stream_fuzz_vector_writer(
  kind : Int,
  status : @cairoon.Status,
) -> (Result[Unit, @cairoon.CairoError], Int, Int) raise @cairoon.CairoError {
  let chunk_count = Ref(0)
  let byte_count = Ref(0)
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(4.0, 4.0, fn(chunk) {
        lifetime_record_stream_chunk_with_status(
          chunk, chunk_count, byte_count, status,
        )
      })
    1 =>
      @cairoon.Surface::ps_stream(4.0, 4.0, fn(chunk) {
        lifetime_record_stream_chunk_with_status(
          chunk, chunk_count, byte_count, status,
        )
      })
    _ =>
      @cairoon.Surface::svg_stream(4.0, 4.0, fn(chunk) {
        lifetime_record_stream_chunk_with_status(
          chunk, chunk_count, byte_count, status,
        )
      })
  }
  let result = @cairoon.run_cairo(() => lifetime_paint_stream_surface(surface))
  (result, chunk_count.val, byte_count.val)
}

///|
fn lifetime_stream_fuzz_png_writer(
  status : @cairoon.Status,
) -> (Result[Unit, @cairoon.CairoError], Int, Int) raise @cairoon.CairoError {
  let image = @cairoon.Surface::image(Argb32, 2, 2)
  let ctx = @cairoon.Context::new(image)
  ctx.set_source_rgba(0.2, 0.5, 0.8, 1.0)
  ctx.paint()

  let chunk_count = Ref(0)
  let byte_count = Ref(0)
  let result = @cairoon.run_cairo(() => {
    image.write_to_png_stream(fn(chunk) {
      lifetime_record_stream_chunk_with_status(
        chunk, chunk_count, byte_count, status,
      )
    })
  })
  (result, chunk_count.val, byte_count.val)
}

///|
fn lifetime_stream_fuzz_script_writer(
  status : @cairoon.Status,
) -> (Result[Unit, @cairoon.CairoError], Int, Int) raise @cairoon.CairoError {
  let chunk_count = Ref(0)
  let byte_count = Ref(0)
  let device = @cairoon.Device::script_stream(fn(chunk) {
    lifetime_record_stream_chunk_with_status(
      chunk, chunk_count, byte_count, status,
    )
  })
  let result = @cairoon.run_cairo(() => {
    let surface = @cairoon.Surface::script(device, ContentColorAlpha, 4.0, 4.0)
    let ctx = @cairoon.Context::new(surface)
    ctx.set_source_rgb(0.4, 0.0, 0.7)
    ctx.paint()
    surface.finish()
    device.finish()
  })
  (result, chunk_count.val, byte_count.val)
}

///|
fn lifetime_stream_fuzz_png_reader(
  short_read : Bool,
) -> (Result[Unit, @cairoon.CairoError], Int, Int, Int, Int) raise @cairoon.CairoError {
  let input = lifetime_png_bytes()
  let offset = Ref(0)
  let chunk_count = Ref(0)
  let byte_count = Ref(0)
  let width = Ref(0)
  let height = Ref(0)
  let result = @cairoon.run_cairo(() => {
    let surface = @cairoon.Surface::image_from_png_stream(fn(length) {
      let available = input.length() - offset.val
      let actual = if available < length { available } else { length }
      let emitted = if short_read && actual > 0 { actual - 1 } else { actual }
      let chunk = lifetime_bytes_slice(input, offset.val, emitted)
      offset.val += emitted
      chunk_count.val += 1
      byte_count.val += emitted
      chunk
    })
    width.val = surface.get_width()
    height.val = surface.get_height()
  })
  (result, chunk_count.val, byte_count.val, width.val, height.val)
}

///|
fn lifetime_stream_fuzz_status(value : Int) -> @cairoon.Status {
  match value % 3 {
    0 => Success
    1 => WriteError
    _ => LastStatus
  }
}
