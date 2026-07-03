///|
fn expect_image_data_invalid_index(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}

///|
fn expect_image_data_cairo_status(
  result : Result[Unit, CairoError],
  expected : Status,
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(status, _)) if status == expected => ()
    _ => @test.fail("expected cairo status")
  }
}

///|
fn image_data_from_local_surface() -> ImageData raise CairoError {
  let surface = Surface::image(Argb32, 1, 1)
  let data = surface.get_data()
  data.set(3, b'\xff')
  data
}

///|
fn mapped_image_data_from_local_surface() -> ImageData raise CairoError {
  let surface = Surface::image(Rgb24, 1, 1)
  let mapped = surface.map_to_image()
  let data = mapped.get_data()
  data.set(0, b'\xaa')
  data
}

///|
test "image data view reads writes and copies surface bytes" {
  let surface = Surface::image(Argb32, 1, 1)
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
test "image data view shares buffer-backed image storage" {
  let buffer : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let surface = Surface::image_for_data(buffer, Argb32, 1, 1)
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
test "image data view maps invalid surface and indexes" {
  let pdf = Surface::pdf(10.0, 10.0)
  expect_image_data_cairo_status(
    run_cairo(() => {
      let _ = pdf.get_data()
      ()
    }),
    SurfaceTypeMismatch,
  )

  let data = Surface::image(Argb32, 1, 1).get_data()
  expect_image_data_invalid_index(
    run_cairo(() => {
      let _ = data.get(-1)
      ()
    }),
  )
  expect_image_data_invalid_index(run_cairo(() => data.set(4, b'\x00')))
}

///|
test "mapped image data view writes and base unmap uploads" {
  let main = Surface::image(Rgb24, 2, 1)
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
    run_cairo(() => {
      let _ = data.copy()
      ()
    }),
    SurfaceFinished,
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
  let main = Surface::image(Rgb24, 1, 1)
  let mapped = main.map_to_image()
  let data = mapped.get_data()
  mapped.unmap()
  expect_image_data_cairo_status(
    run_cairo(() => {
      let _ = data.get(0)
      ()
    }),
    SurfaceFinished,
  )
  expect_image_data_cairo_status(
    run_cairo(() => data.set(0, b'\x00')),
    SurfaceFinished,
  )
}
