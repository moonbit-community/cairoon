///|
fn[T] expect_surface_finished(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
fn[T] expect_surface_type_mismatch(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn[T] expect_surface_invalid_content(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidContent, _)) => ()
    _ => @test.fail("expected InvalidContent")
  }
}

///|
fn[T] expect_surface_invalid_format(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidFormat, _)) => ()
    _ => @test.fail("expected InvalidFormat")
  }
}

///|
test "image surface properties" {
  let surface = @cairoon.Surface::image(Argb32, 2, 1)
  debug_inspect(surface.get_type(), content="SurfaceTypeImage")
  debug_inspect(surface.get_content(), content="ContentColorAlpha")
  inspect(surface.get_content_raw(), content="12288")
  debug_inspect(surface.get_format(), content="Argb32")
  inspect(surface.get_format_raw(), content="0")
  inspect(surface.get_width(), content="2")
  inspect(surface.get_height(), content="1")
  inspect(surface.get_stride(), content="8")
  inspect(surface.copy_data().length(), content="8")
}

///|
test "image surface accepts pycairo raw format ints" {
  inspect(@cairoon.Format::stride_for_width_raw(0, 2), content="8")
  inspect(
    @cairoon.Format::stride_for_width_raw(@cairoon.FORMAT_INVALID, 2),
    content="-1",
  )

  let surface = @cairoon.Surface::image_raw(1, 2, 1)
  debug_inspect(surface.get_format(), content="Rgb24")
  inspect(surface.get_format_raw(), content="1")
  inspect(surface.get_stride(), content="8")

  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let backed = @cairoon.Surface::image_for_data_raw(data, 0, 1, 1)
  debug_inspect(backed.get_format(), content="Argb32")
  inspect(backed.get_format_raw(), content="0")

  expect_surface_invalid_format(
    @cairoon.run_cairo(() => @cairoon.Surface::image_raw(-1, 1, 1)),
  )
  let invalid_data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  expect_surface_invalid_format(
    @cairoon.run_cairo(() => {
      @cairoon.Surface::image_for_data_raw(invalid_data, -1, 1, 1)
    }),
  )
}

///|
test "surface create_similar accepts pycairo raw content ints" {
  let parent = @cairoon.Surface::image(Argb32, 2, 2)
  let color = parent.create_similar_raw(0x1000, 1, 1)
  debug_inspect(color.get_content(), content="ContentColor")
  inspect(color.get_content_raw(), content="4096")

  let alpha = parent.create_similar_raw(0x2000, 1, 1)
  debug_inspect(alpha.get_content(), content="ContentAlpha")
  inspect(alpha.get_content_raw(), content="8192")

  expect_surface_invalid_content(
    @cairoon.run_cairo(() => parent.create_similar_raw(0, 1, 1)),
  )
}

///|
test "image surface properties map status and subtype errors" {
  let finished = @cairoon.Surface::image(Argb32, 1, 1)
  finished.finish()
  expect_surface_finished(@cairoon.run_cairo(() => finished.get_width()))
  expect_surface_finished(@cairoon.run_cairo(() => finished.get_height()))
  expect_surface_finished(@cairoon.run_cairo(() => finished.get_stride()))
  expect_surface_finished(@cairoon.run_cairo(() => finished.get_format()))
  expect_surface_finished(@cairoon.run_cairo(() => finished.copy_data()))

  let pdf = @cairoon.Surface::pdf(10.0, 10.0)
  expect_surface_type_mismatch(@cairoon.run_cairo(() => pdf.get_width()))
  expect_surface_type_mismatch(@cairoon.run_cairo(() => pdf.get_height()))
  expect_surface_type_mismatch(@cairoon.run_cairo(() => pdf.get_stride()))
  expect_surface_type_mismatch(@cairoon.run_cairo(() => pdf.get_format()))
  expect_surface_type_mismatch(@cairoon.run_cairo(() => pdf.copy_data()))
}

///|
test "image surface supports cairo float formats" {
  if @cairoon.CAIRO_VERSION >= 11702 {
    let rgb = @cairoon.Surface::image(Rgb96F, 3, 2)
    debug_inspect(rgb.get_type(), content="SurfaceTypeImage")
    debug_inspect(rgb.get_format(), content="Rgb96F")
    debug_inspect(rgb.get_content(), content="ContentColor")
    inspect(rgb.get_width(), content="3")
    inspect(rgb.get_height(), content="2")
    inspect(
      rgb.get_stride(),
      content="\{@cairoon.Format::stride_for_width(Rgb96F, 3)}",
    )
    inspect(rgb.copy_data().length(), content="\{rgb.get_stride() * 2}")

    let rgba = @cairoon.Surface::image(Rgba128F, 3, 2)
    debug_inspect(rgba.get_type(), content="SurfaceTypeImage")
    debug_inspect(rgba.get_format(), content="Rgba128F")
    debug_inspect(rgba.get_content(), content="ContentColorAlpha")
    inspect(
      rgba.get_stride(),
      content="\{@cairoon.Format::stride_for_width(Rgba128F, 3)}",
    )
    inspect(rgba.copy_data().length(), content="\{rgba.get_stride() * 2}")
  } else {
    match @cairoon.run_cairo(() => @cairoon.Surface::image(Rgb96F, 3, 2)) {
      Err(CairoInvalidArgument(InvalidFormat, _)) => ()
      _ => @test.fail("expected InvalidFormat for RGB96F before Cairo 1.17.2")
    }
    match @cairoon.run_cairo(() => @cairoon.Surface::image(Rgba128F, 3, 2)) {
      Err(CairoInvalidArgument(InvalidFormat, _)) => ()
      _ => @test.fail("expected InvalidFormat for RGBA128F before Cairo 1.17.2")
    }
  }
}
