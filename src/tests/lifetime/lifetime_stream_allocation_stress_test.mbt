///|
fn lifetime_stress_stream_callbacks(index : Int) -> Unit raise {
  let pdf_chunks = Ref(0)
  let pdf_bytes = Ref(0)
  let pdf = @cairoon.Surface::pdf_stream(4.0, 4.0, fn(chunk) {
    lifetime_record_stream_chunk(chunk, pdf_chunks, pdf_bytes)
  })
  lifetime_paint_stream_surface(pdf)

  let ps_chunks = Ref(0)
  let ps_bytes = Ref(0)
  let ps = @cairoon.Surface::ps_stream(4.0, 4.0, fn(chunk) {
    lifetime_record_stream_chunk(chunk, ps_chunks, ps_bytes)
  })
  lifetime_paint_stream_surface(ps)

  let svg_chunks = Ref(0)
  let svg_bytes = Ref(0)
  let svg = @cairoon.Surface::svg_stream(4.0, 4.0, fn(chunk) {
    lifetime_record_stream_chunk(chunk, svg_chunks, svg_bytes)
  })
  lifetime_paint_stream_surface(svg)

  let image = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let image_ctx = @cairoon.Context::new(image)
  image_ctx.set_source_rgb(1.0, 0.0, 0.0)
  image_ctx.paint()
  let png_write_chunks = Ref(0)
  let png_write_bytes = Ref(0)
  image.write_to_png_stream(fn(chunk) {
    lifetime_record_stream_chunk(chunk, png_write_chunks, png_write_bytes)
  })

  let input = lifetime_png_bytes()
  let offset = Ref(0)
  let readback = @cairoon.Surface::image_from_png_stream(fn(length) {
    let chunk = lifetime_bytes_slice(input, offset.val, length)
    offset.val += length
    chunk
  })

  let script_chunks = Ref(0)
  let script_bytes = Ref(0)
  let script = @cairoon.Device::script_stream(fn(chunk) {
    lifetime_record_stream_chunk(chunk, script_chunks, script_bytes)
  })
  let script_surface = @cairoon.Surface::script(
    script,
    @cairoon.ContentColorAlpha,
    4.0,
    4.0,
  )
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
    @cairoon.run_cairo(() => {
      let failing = @cairoon.Surface::pdf_stream(4.0, 4.0, fn(_) {
        @cairoon.WriteError
      })
      lifetime_paint_stream_surface(failing)
    }),
  )
  expect_lifetime_write_error(
    @cairoon.run_cairo(() => {
      let failing = @cairoon.Surface::ps_stream(4.0, 4.0, fn(_) {
        @cairoon.WriteError
      })
      lifetime_paint_stream_surface(failing)
    }),
  )
  expect_lifetime_write_error(
    @cairoon.run_cairo(() => {
      let failing = @cairoon.Surface::svg_stream(4.0, 4.0, fn(_) {
        @cairoon.WriteError
      })
      lifetime_paint_stream_surface(failing)
    }),
  )
  expect_lifetime_write_error(
    @cairoon.run_cairo(() => {
      image.write_to_png_stream(fn(_) { @cairoon.WriteError })
    }),
  )
  expect_lifetime_write_error(
    @cairoon.run_cairo(() => {
      let failing_script = @cairoon.Device::script_stream(fn(_) {
        @cairoon.WriteError
      })
      let failing_surface = @cairoon.Surface::script(
        failing_script,
        @cairoon.ContentColorAlpha,
        4.0,
        4.0,
      )
      let failing_ctx = @cairoon.Context::new(failing_surface)
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
