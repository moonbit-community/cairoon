///|
fn surface_with_local_pixel_buffer() -> Surface raise CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  Surface::image_for_data(data, Argb32, 1, 1)
}

///|
test "image surface properties" {
  let surface = Surface::image(Argb32, 2, 1)
  debug_inspect(surface.get_format(), content="Argb32")
  inspect(surface.get_width(), content="2")
  inspect(surface.get_height(), content="1")
  inspect(surface.get_stride(), content="8")
  inspect(surface.copy_data().length(), content="8")
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
  let result = run_cairo(() => ctx.restore())
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(InvalidRestore, _)) => ()
    _ => @test.fail("expected InvalidRestore")
  }
}
