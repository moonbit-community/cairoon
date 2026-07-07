///|
fn expect_image_data_invalid_index(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}

///|
fn expect_image_data_cairo_status(
  result : Result[Unit, @cairoon.CairoError],
  expected : @cairoon.Status,
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(status, _)) if status == expected => ()
    _ => @test.fail("expected cairo status")
  }
}

///|
fn expect_image_data_surface_finished(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  expect_image_data_cairo_status(result, @cairoon.SurfaceFinished)
}

///|
fn image_data_from_local_surface() -> @cairoon.ImageData raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let data = surface.get_data()
  data.set(3, b'\xff')
  data
}

///|
fn mapped_image_data_from_local_surface() -> @cairoon.ImageData raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(@cairoon.Rgb24, 1, 1)
  let mapped = surface.map_to_image()
  let data = mapped.get_data()
  data.set(0, b'\xaa')
  data
}

///|
test "image data view reads writes and copies surface bytes" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let data = surface.get_data()
  inspect(data.status().is_success(), content="true")
  inspect(data.length(), content="4")

  data.set(0, b'\x01')
  data.set(1, b'\x02')
  data.set(2, b'\x03')
  data.set(3, b'\x04')
  inspect(data.get(0).to_int(), content="1")
  inspect(data.get(1).to_int(), content="2")
  inspect(data.get(2).to_int(), content="3")
  inspect(data.get(3).to_int(), content="4")
  inspect(data.copy() == surface.copy_data(), content="true")
}

///|
test "pycairo image surface get_data mutable view fixture" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 3, 3)
  let ctx = @cairoon.Context::new(surface)
  ctx.paint()
  surface.flush()

  let data = surface.get_data()
  inspect(data.length(), content="36")
  inspect(data.copy().length(), content="36")
  data.set(0, b'\x42')

  let new_data = surface.get_data()
  inspect(new_data.get(0).to_int(), content="66")
  ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
  ctx.paint()
  surface.flush()
  inspect(new_data.get(0).to_int(), content="255")
}

///|
test "image data view shares buffer-backed image storage" {
  let buffer : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let surface = @cairoon.Surface::image_for_data(buffer, @cairoon.Argb32, 1, 1)
  let data = surface.get_data()
  data.set(2, b'\xff')
  surface.flush()
  inspect(buffer[2].to_int(), content="255")
  inspect(surface.copy_data() == Bytes::from_array(buffer), content="true")
}

///|
test "image data view retains local surface wrapper" {
  let data = image_data_from_local_surface()
  inspect(data.length(), content="4")
  inspect(data.get(3).to_int(), content="255")
  data.set(0, b'\x7f')
  inspect(data.copy()[0].to_int(), content="127")
}

///|
test "image surfaces reject get data after finish" {
  let ordinary = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  ordinary.finish()
  expect_image_data_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = ordinary.get_data()
      ()
    }),
  )

  let buffer : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let backed = @cairoon.Surface::image_for_data(buffer, @cairoon.Argb32, 1, 1)
  backed.finish()
  expect_image_data_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = backed.get_data()
      ()
    }),
  )

  let path = "/tmp/cairoon_image_data_finished.png"
  let source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  source.write_to_png(path)
  let loaded = @cairoon.Surface::image_from_png(path)
  loaded.finish()
  expect_image_data_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = loaded.get_data()
      ()
    }),
  )
}

///|
test "image data view reports base surface finish" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let data = surface.get_data()
  surface.finish()
  debug_inspect(data.status(), content="SurfaceFinished")
  expect_image_data_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = data.length()
      ()
    }),
  )
  expect_image_data_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = data.get(0)
      ()
    }),
  )
  expect_image_data_surface_finished(
    @cairoon.run_cairo(() => data.set(0, b'\x00')),
  )
  expect_image_data_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = data.copy()
      ()
    }),
  )
}

///|
test "image data view maps invalid surface and indexes" {
  let pdf = @cairoon.Surface::pdf(10.0, 10.0)
  expect_image_data_cairo_status(
    @cairoon.run_cairo(() => {
      let _ = pdf.get_data()
      ()
    }),
    @cairoon.SurfaceTypeMismatch,
  )

  let data = @cairoon.Surface::image(@cairoon.Argb32, 1, 1).get_data()
  expect_image_data_invalid_index(
    @cairoon.run_cairo(() => {
      let _ = data.get(-1)
      ()
    }),
  )
  expect_image_data_invalid_index(
    @cairoon.run_cairo(() => data.set(4, b'\x00')),
  )
}

///|
test "mapped image data view writes and base unmap uploads" {
  let main = @cairoon.Surface::image(@cairoon.Rgb24, 2, 1)
  let mapped = main.map_to_image()
  let data = mapped.get_data()
  inspect(data.length(), content="8")
  data.set(0, b'\xff')
  data.set(1, b'\xff')
  data.set(2, b'\xff')
  data.set(3, b'\xff')
  main.unmap_image(mapped)
  main.flush()
  inspect_rgb24_bytes(main.copy_data(), [255, 255, 255, 255, 0, 0, 0, 0])
  expect_image_data_cairo_status(
    @cairoon.run_cairo(() => {
      let _ = data.copy()
      ()
    }),
    @cairoon.SurfaceFinished,
  )
}

///|
test "mapped image data view retains mapped wrapper" {
  let data = mapped_image_data_from_local_surface()
  inspect(data.length(), content="4")
  inspect(data.get(0).to_int(), content="170")
  data.set(1, b'\xbb')
  inspect(data.copy()[1].to_int(), content="187")
}

///|
test "mapped image data view reports mapped unmap" {
  let main = @cairoon.Surface::image(@cairoon.Rgb24, 1, 1)
  let mapped = main.map_to_image()
  let data = mapped.get_data()
  mapped.unmap()
  expect_image_data_cairo_status(
    @cairoon.run_cairo(() => {
      let _ = data.get(0)
      ()
    }),
    @cairoon.SurfaceFinished,
  )
  expect_image_data_cairo_status(
    @cairoon.run_cairo(() => data.set(0, b'\x00')),
    @cairoon.SurfaceFinished,
  )
}
