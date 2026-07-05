///|
fn lifetime_paint_stream_surface(surface : Surface) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
fn expect_lifetime_write_error(result : Result[Unit, CairoError]) -> Unit raise {
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
) -> Status {
  chunk_count.val += 1
  byte_count.val += chunk.length()
  Success
}

///|
fn lifetime_record_stream_chunk_with_status(
  chunk : Bytes,
  chunk_count : Ref[Int],
  byte_count : Ref[Int],
  status : Status,
) -> Status {
  chunk_count.val += 1
  byte_count.val += chunk.length()
  status
}

///|
fn lifetime_png_bytes() -> Bytes raise CairoError {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
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
  result : Result[Unit, CairoError],
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
  result : Result[Unit, CairoError],
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
  result : Result[Unit, CairoError],
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
  status : Status,
) -> (Result[Unit, CairoError], Int, Int) raise CairoError {
  let chunk_count = Ref(0)
  let byte_count = Ref(0)
  let surface = match kind {
    0 =>
      Surface::pdf_stream(4.0, 4.0, fn(chunk) {
        lifetime_record_stream_chunk_with_status(
          chunk, chunk_count, byte_count, status,
        )
      })
    1 =>
      Surface::ps_stream(4.0, 4.0, fn(chunk) {
        lifetime_record_stream_chunk_with_status(
          chunk, chunk_count, byte_count, status,
        )
      })
    _ =>
      Surface::svg_stream(4.0, 4.0, fn(chunk) {
        lifetime_record_stream_chunk_with_status(
          chunk, chunk_count, byte_count, status,
        )
      })
  }
  let result = run_cairo(() => lifetime_paint_stream_surface(surface))
  (result, chunk_count.val, byte_count.val)
}

///|
fn lifetime_stream_fuzz_png_writer(
  status : Status,
) -> (Result[Unit, CairoError], Int, Int) raise CairoError {
  let image = Surface::image(Argb32, 2, 2)
  let ctx = Context::new(image)
  ctx.set_source_rgba(0.2, 0.5, 0.8, 1.0)
  ctx.paint()

  let chunk_count = Ref(0)
  let byte_count = Ref(0)
  let result = run_cairo(() => {
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
  status : Status,
) -> (Result[Unit, CairoError], Int, Int) raise CairoError {
  let chunk_count = Ref(0)
  let byte_count = Ref(0)
  let device = Device::script_stream(fn(chunk) {
    lifetime_record_stream_chunk_with_status(
      chunk, chunk_count, byte_count, status,
    )
  })
  let result = run_cairo(() => {
    let surface = Surface::script(device, ContentColorAlpha, 4.0, 4.0)
    let ctx = Context::new(surface)
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
) -> (Result[Unit, CairoError], Int, Int, Int, Int) raise CairoError {
  let input = lifetime_png_bytes()
  let offset = Ref(0)
  let chunk_count = Ref(0)
  let byte_count = Ref(0)
  let width = Ref(0)
  let height = Ref(0)
  let result = run_cairo(() => {
    let surface = Surface::image_from_png_stream(fn(length) {
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
fn lifetime_stream_fuzz_status(value : Int) -> Status {
  match value % 3 {
    0 => Success
    1 => WriteError
    _ => LastStatus
  }
}

///|
fn lifetime_stress_stream_callbacks(index : Int) -> Unit raise {
  let pdf_chunks = Ref(0)
  let pdf_bytes = Ref(0)
  let pdf = Surface::pdf_stream(4.0, 4.0, fn(chunk) {
    lifetime_record_stream_chunk(chunk, pdf_chunks, pdf_bytes)
  })
  lifetime_paint_stream_surface(pdf)

  let ps_chunks = Ref(0)
  let ps_bytes = Ref(0)
  let ps = Surface::ps_stream(4.0, 4.0, fn(chunk) {
    lifetime_record_stream_chunk(chunk, ps_chunks, ps_bytes)
  })
  lifetime_paint_stream_surface(ps)

  let svg_chunks = Ref(0)
  let svg_bytes = Ref(0)
  let svg = Surface::svg_stream(4.0, 4.0, fn(chunk) {
    lifetime_record_stream_chunk(chunk, svg_chunks, svg_bytes)
  })
  lifetime_paint_stream_surface(svg)

  let image = Surface::image(Argb32, 1, 1)
  let image_ctx = Context::new(image)
  image_ctx.set_source_rgb(1.0, 0.0, 0.0)
  image_ctx.paint()
  let png_write_chunks = Ref(0)
  let png_write_bytes = Ref(0)
  image.write_to_png_stream(fn(chunk) {
    lifetime_record_stream_chunk(chunk, png_write_chunks, png_write_bytes)
  })

  let input = lifetime_png_bytes()
  let offset = Ref(0)
  let readback = Surface::image_from_png_stream(fn(length) {
    let chunk = lifetime_bytes_slice(input, offset.val, length)
    offset.val += length
    chunk
  })

  let script_chunks = Ref(0)
  let script_bytes = Ref(0)
  let script = Device::script_stream(fn(chunk) {
    lifetime_record_stream_chunk(chunk, script_chunks, script_bytes)
  })
  let script_surface = Surface::script(script, ContentColorAlpha, 4.0, 4.0)
  lifetime_paint_stream_surface(script_surface)
  script.finish()

  if index % 250 == 0 {
    inspect(pdf_chunks.val > 0, content="true")
    inspect(pdf_bytes.val > 0, content="true")
    inspect(ps_chunks.val > 0, content="true")
    inspect(ps_bytes.val > 0, content="true")
    inspect(svg_chunks.val > 0, content="true")
    inspect(svg_bytes.val > 0, content="true")
    inspect(png_write_chunks.val > 0, content="true")
    inspect(png_write_bytes.val > 8, content="true")
    inspect(readback.get_width(), content="1")
    inspect(readback.get_height(), content="1")
    inspect(offset.val == input.length(), content="true")
    inspect(script_chunks.val > 0, content="true")
    inspect(script_bytes.val > 0, content="true")
  }

  expect_lifetime_write_error(
    run_cairo(() => {
      let failing = Surface::pdf_stream(4.0, 4.0, fn(_) { WriteError })
      lifetime_paint_stream_surface(failing)
    }),
  )
  expect_lifetime_write_error(
    run_cairo(() => {
      let failing = Surface::ps_stream(4.0, 4.0, fn(_) { WriteError })
      lifetime_paint_stream_surface(failing)
    }),
  )
  expect_lifetime_write_error(
    run_cairo(() => {
      let failing = Surface::svg_stream(4.0, 4.0, fn(_) { WriteError })
      lifetime_paint_stream_surface(failing)
    }),
  )
  expect_lifetime_write_error(
    run_cairo(() => image.write_to_png_stream(fn(_) { WriteError })),
  )
  expect_lifetime_write_error(
    run_cairo(() => {
      let failing_script = Device::script_stream(fn(_) { WriteError })
      let failing_surface = Surface::script(
        failing_script,
        ContentColorAlpha,
        4.0,
        4.0,
      )
      let failing_ctx = Context::new(failing_surface)
      failing_ctx.paint()
      failing_surface.finish()
      failing_script.finish()
    }),
  )
}

///|
test "backend stream callback allocation stress" {
  for index in 0..<1000 {
    lifetime_stress_stream_callbacks(index)
  }
}

///|
test "backend stream callback multi-seed fuzz covers status and reader edges" {
  let write_successes = Ref(0)
  let write_failures = Ref(0)
  let invalid_status_failures = Ref(0)
  let reader_successes = Ref(0)
  let reader_failures = Ref(0)
  let total_chunks = Ref(0)
  let total_bytes = Ref(0)

  for seed_start in [23, 311, 1237, 4001] {
    let seed = Ref(seed_start)
    for step in 0..<24 {
      let value = next_lifetime_stream_fuzz_seed(seed)
      let op = (value + step) % 7
      let status = lifetime_stream_fuzz_status(value / 7 + step)
      if op < 3 {
        let (result, chunks, bytes) = lifetime_stream_fuzz_vector_writer(
          op, status,
        )
        total_chunks.val += chunks
        total_bytes.val += bytes
        if status == Success {
          expect_lifetime_stream_fuzz_success(result, chunks, bytes)
          write_successes.val += 1
        } else {
          expect_lifetime_stream_fuzz_write_error(result, chunks)
          write_failures.val += 1
          if status == LastStatus {
            invalid_status_failures.val += 1
          }
        }
      } else if op == 3 {
        let (result, chunks, bytes) = lifetime_stream_fuzz_png_writer(status)
        total_chunks.val += chunks
        total_bytes.val += bytes
        if status == Success {
          expect_lifetime_stream_fuzz_success(result, chunks, bytes)
          write_successes.val += 1
        } else {
          expect_lifetime_stream_fuzz_write_error(result, chunks)
          write_failures.val += 1
          if status == LastStatus {
            invalid_status_failures.val += 1
          }
        }
      } else if op == 4 {
        let (result, chunks, bytes) = lifetime_stream_fuzz_script_writer(status)
        total_chunks.val += chunks
        total_bytes.val += bytes
        if status == Success {
          expect_lifetime_stream_fuzz_success(result, chunks, bytes)
          write_successes.val += 1
        } else {
          expect_lifetime_stream_fuzz_write_error(result, chunks)
          write_failures.val += 1
          if status == LastStatus {
            invalid_status_failures.val += 1
          }
        }
      } else {
        let short_read = op == 6
        let (result, chunks, bytes, width, height) = lifetime_stream_fuzz_png_reader(
          short_read,
        )
        total_chunks.val += chunks
        total_bytes.val += bytes
        if short_read {
          expect_lifetime_stream_fuzz_read_error(result, chunks)
          reader_failures.val += 1
        } else {
          expect_lifetime_stream_fuzz_success(result, chunks, bytes)
          inspect(width, content="1")
          inspect(height, content="1")
          reader_successes.val += 1
        }
      }
    }
  }

  inspect(write_successes.val > 0, content="true")
  inspect(write_failures.val > 0, content="true")
  inspect(invalid_status_failures.val > 0, content="true")
  inspect(reader_successes.val > 0, content="true")
  inspect(reader_failures.val > 0, content="true")
  inspect(total_chunks.val > 96, content="true")
  inspect(total_bytes.val > 0, content="true")
}
