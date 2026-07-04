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
