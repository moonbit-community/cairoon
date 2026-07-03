///|
fn surface_with_local_pixel_buffer() -> Surface raise CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  Surface::image_for_data(data, Argb32, 1, 1)
}

///|
fn expect_surface_invalid_size(
  result : Result[Surface, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidSize, _)) => ()
    _ => @test.fail("expected InvalidSize")
  }
}

///|
fn[T] expect_surface_finished(result : Result[T, CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
test "image surface properties" {
  let surface = Surface::image(Argb32, 2, 1)
  debug_inspect(surface.get_type(), content="SurfaceTypeImage")
  debug_inspect(surface.get_content(), content="ContentColorAlpha")
  debug_inspect(surface.get_format(), content="Argb32")
  inspect(surface.get_width(), content="2")
  inspect(surface.get_height(), content="1")
  inspect(surface.get_stride(), content="8")
  inspect(surface.copy_data().length(), content="8")
}

///|
test "image surface supports cairo float formats" {
  let rgb = Surface::image(Rgb96F, 3, 2)
  debug_inspect(rgb.get_type(), content="SurfaceTypeImage")
  debug_inspect(rgb.get_format(), content="Rgb96F")
  debug_inspect(rgb.get_content(), content="ContentColor")
  inspect(rgb.get_width(), content="3")
  inspect(rgb.get_height(), content="2")
  inspect(rgb.get_stride(), content="\{Format::stride_for_width(Rgb96F, 3)}")
  inspect(rgb.copy_data().length(), content="\{rgb.get_stride() * 2}")

  let rgba = Surface::image(Rgba128F, 3, 2)
  debug_inspect(rgba.get_type(), content="SurfaceTypeImage")
  debug_inspect(rgba.get_format(), content="Rgba128F")
  debug_inspect(rgba.get_content(), content="ContentColorAlpha")
  inspect(rgba.get_stride(), content="\{Format::stride_for_width(Rgba128F, 3)}")
  inspect(rgba.copy_data().length(), content="\{rgba.get_stride() * 2}")
}

///|
test "surface equality and hash use cairo pointer identity" {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  let target = ctx.get_target()
  inspect(surface.equal(target), content="true")
  inspect(target.equal(surface), content="true")
  inspect(surface.hash() == target.hash(), content="true")

  let other = Surface::image(Argb32, 1, 1)
  inspect(surface.equal(other), content="false")
}

///|
test "surface finish records status for base methods" {
  let surface = Surface::image(Argb32, 1, 1)
  debug_inspect(surface.status(), content="Success")
  surface.finish()
  debug_inspect(surface.status(), content="SurfaceFinished")

  // Cairo finish is intentionally idempotent; operations after finish fail.
  surface.finish()
  expect_surface_finished(run_cairo(() => surface.flush()))
  expect_surface_finished(run_cairo(() => surface.copy_page()))
  expect_surface_finished(run_cairo(() => surface.show_page()))
}

///|
test "surface finished status covers capability dirty and state methods" {
  let surface = Surface::image(Argb32, 2, 2)
  inspect(
    surface.has_show_text_glyphs() || !surface.has_show_text_glyphs(),
    content="true",
  )
  surface.finish()
  expect_surface_finished(run_cairo(() => surface.has_show_text_glyphs()))
  expect_surface_finished(run_cairo(() => surface.mark_dirty()))
  expect_surface_finished(
    run_cairo(() => surface.mark_dirty_rectangle(0, 0, 1, 1)),
  )
  expect_surface_finished(run_cairo(() => surface.set_device_offset(1.0, 2.0)))
  expect_surface_finished(run_cairo(() => surface.get_device_offset()))
  expect_surface_finished(run_cairo(() => surface.set_device_scale(1.0, 2.0)))
  expect_surface_finished(run_cairo(() => surface.get_device_scale()))
  expect_surface_finished(
    run_cairo(() => surface.set_fallback_resolution(72.0, 72.0)),
  )
  expect_surface_finished(run_cairo(() => surface.get_fallback_resolution()))
}

///|
test "surface similar constructors and state queries" {
  let source = Surface::image(Argb32, 2, 2)
  let similar = source.create_similar(ContentColor, 3, 4)
  inspect(similar.status().is_success(), content="true")
  debug_inspect(similar.get_content(), content="ContentColor")

  let image = source.create_similar_image(Rgb24, 3, 4)
  inspect(image.status().is_success(), content="true")
  debug_inspect(image.get_type(), content="SurfaceTypeImage")
  debug_inspect(image.get_content(), content="ContentColor")
  debug_inspect(image.get_format(), content="Rgb24")
  inspect(image.get_width(), content="3")
  inspect(image.get_height(), content="4")
}

///|
test "surface similar constructors validate invalid dimensions" {
  let source = Surface::image(Argb32, 2, 2)
  expect_surface_invalid_size(
    run_cairo(() => source.create_similar(ContentColor, -1, 1)),
  )
  expect_surface_invalid_size(
    run_cairo(() => source.create_similar(ContentColor, 1, -1)),
  )
  expect_surface_invalid_size(
    run_cairo(() => source.create_similar_image(Argb32, -1, 1)),
  )
  expect_surface_invalid_size(
    run_cairo(() => source.create_similar_image(Argb32, 1, -1)),
  )
}

///|
test "surface device state and dirty markers round trip" {
  let surface = Surface::image(Argb32, 3, 3)
  surface.set_device_offset(1.25, -2.5)
  debug_inspect(surface.get_device_offset(), content="(1.25, -2.5)")

  surface.set_device_scale(5.0, 3.0)
  debug_inspect(surface.get_device_scale(), content="(5, 3)")

  let bad_scale = run_cairo(() => surface.set_device_scale(0.0, 1.0))
  match bad_scale {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix for zero device scale")
  }

  surface.set_fallback_resolution(42.0, 96.0)
  debug_inspect(surface.get_fallback_resolution(), content="(42, 96)")

  surface.mark_dirty()
  surface.mark_dirty_rectangle(0, 0, 1, 1)

  let has_text_glyphs = surface.has_show_text_glyphs()
  inspect(has_text_glyphs || !has_text_glyphs, content="true")
}

///|
test "surface state and subsurface constructors preserve pycairo numeric limits" {
  let max_double = 1.7976931348623157e308
  let min_double = -max_double
  let min_positive = 2.2250738585072014e-308
  let surface = Surface::image(Argb32, 100, 100)

  surface.set_device_offset(max_double, min_double)
  debug_inspect(
    surface.get_device_offset(),
    content="(1.7976931348623157e+308, -1.7976931348623157e+308)",
  )

  surface.set_device_scale(max_double, min_double)
  debug_inspect(
    surface.get_device_scale(),
    content="(1.7976931348623157e+308, -1.7976931348623157e+308)",
  )

  let huge_child = surface.create_for_rectangle(
    max_double, max_double, max_double, max_double,
  )
  inspect(huge_child.status().is_success(), content="true")

  let tiny_child = surface.create_for_rectangle(
    min_double, min_double, min_positive, min_positive,
  )
  inspect(tiny_child.status().is_success(), content="true")
}

///|
test "context paints deterministic argb32 bytes" {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.paint()
  let data = surface.copy_data()
  inspect(data.length(), content="4")
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
test "image surface for data shares caller buffer" {
  let stride = Format::stride_for_width(Argb32, 1)
  let data : FixedArray[Byte] = FixedArray::make(stride, b'\x00')
  let surface = Surface::image_for_data(data, Argb32, 1, 1, stride~)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  ctx.paint()
  surface.flush()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
  inspect(surface.copy_data() == Bytes::from_array(data), content="true")
}

///|
test "image surface for data supports cairo float formats" {
  let rgb_stride = Format::stride_for_width(Rgb96F, 2)
  let rgb_data : FixedArray[Byte] = FixedArray::make(rgb_stride, b'\x00')
  let rgb = Surface::image_for_data(rgb_data, Rgb96F, 2, 1, stride=rgb_stride)
  debug_inspect(rgb.get_format(), content="Rgb96F")
  inspect(rgb.get_stride(), content="\{rgb_stride}")
  inspect(rgb.copy_data() == Bytes::from_array(rgb_data), content="true")

  let rgba_stride = Format::stride_for_width(Rgba128F, 2)
  let rgba_data : FixedArray[Byte] = FixedArray::make(rgba_stride, b'\x00')
  let rgba = Surface::image_for_data(
    rgba_data,
    Rgba128F,
    2,
    1,
    stride=rgba_stride,
  )
  debug_inspect(rgba.get_format(), content="Rgba128F")
  inspect(rgba.get_stride(), content="\{rgba_stride}")
  inspect(rgba.copy_data() == Bytes::from_array(rgba_data), content="true")
}

///|
test "image surface for data retains local buffer" {
  let surface = surface_with_local_pixel_buffer()
  let ctx = Context::new(surface)
  ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  ctx.paint()
  let data = surface.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
test "image surface for data allows empty zero dimension buffer" {
  let data : FixedArray[Byte] = FixedArray::make(0, b'\x00')
  let zero_height = Surface::image_for_data(data, Argb32, 10, 0)
  inspect(zero_height.get_width(), content="10")
  inspect(zero_height.get_height(), content="0")
  inspect(zero_height.get_stride(), content="40")
  inspect(zero_height.copy_data().length(), content="0")

  let zero_width = Surface::image_for_data(data, Argb32, 0, 10)
  inspect(zero_width.get_width(), content="0")
  inspect(zero_width.get_height(), content="10")
  inspect(zero_width.get_stride(), content="0")
  inspect(zero_width.copy_data().length(), content="0")
}

///|
test "image surface for data validates stride and buffer size" {
  let stride = Format::stride_for_width(Argb32, 1)
  let short : FixedArray[Byte] = FixedArray::make(stride - 1, b'\x00')
  let short_result = run_cairo(() => {
    Surface::image_for_data(short, Argb32, 1, 1, stride~)
  })
  match short_result {
    Err(CairoInvalidArgument(InvalidSize, _)) => ()
    _ => @test.fail("expected InvalidSize for short image buffer")
  }

  let bad_stride : FixedArray[Byte] = FixedArray::make(12, b'\x00')
  let stride_result = run_cairo(() => {
    Surface::image_for_data(bad_stride, Argb32, 3, 3, stride=3)
  })
  match stride_result {
    Err(CairoInvalidArgument(InvalidStride, _)) => ()
    _ => @test.fail("expected InvalidStride for invalid image stride")
  }

  let negative : FixedArray[Byte] = FixedArray::make(0, b'\x00')
  let negative_result = run_cairo(() => {
    Surface::image_for_data(negative, Argb32, -1, 1)
  })
  match negative_result {
    Err(CairoInvalidArgument(InvalidSize, _)) => ()
    _ => @test.fail("expected InvalidSize for negative image dimension")
  }
}

///|
test "image surface png file roundtrip and invalid paths" {
  let path = "/tmp/cairoon_surface_png_roundtrip.png"
  let surface = Surface::image(Argb32, 2, 1)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(0.0, 0.0, 1.0, 0.5)
  ctx.paint()
  surface.write_to_png(path)

  let loaded = Surface::image_from_png(path)
  inspect(loaded.get_width(), content="2")
  inspect(loaded.get_height(), content="1")
  debug_inspect(loaded.get_format(), content="Argb32")
  inspect(loaded.copy_data() == surface.copy_data(), content="true")

  let invalid_path = "/tmp/cairoon\u{0}bad.png"
  let write_result = run_cairo(() => surface.write_to_png(invalid_path))
  match write_result {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for write_to_png")
  }
  let read_result = run_cairo(() => Surface::image_from_png(invalid_path))
  match read_result {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for image_from_png")
  }
}

///|
test "context invalid restore maps to cairo error" {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  debug_inspect(ctx.status(), content="Success")
  let result = run_cairo(() => ctx.restore())
  inspect(result is Err(_), content="true")
  debug_inspect(ctx.status(), content="InvalidRestore")
  match result {
    Err(CairoError(InvalidRestore, _)) => ()
    _ => @test.fail("expected InvalidRestore")
  }
}
