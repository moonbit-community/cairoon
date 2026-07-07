///|
fn surface_with_local_pixel_buffer() -> @cairoon.Surface raise @cairoon.CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  @cairoon.Surface::image_for_data(data, @cairoon.Argb32, 1, 1)
}

///|
test "image surface for data shares caller buffer" {
  let stride = @cairoon.Format::stride_for_width(@cairoon.Argb32, 1)
  let data : FixedArray[Byte] = FixedArray::make(stride, b'\x00')
  let surface = @cairoon.Surface::image_for_data(
    data,
    @cairoon.Argb32,
    1,
    1,
    stride~,
  )
  let ctx = @cairoon.Context::new(surface)
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
  let rgb_stride = @cairoon.Format::stride_for_width(@cairoon.Rgb96F, 2)
  let rgb_data : FixedArray[Byte] = FixedArray::make(rgb_stride, b'\x00')
  let rgb = @cairoon.Surface::image_for_data(
    rgb_data,
    @cairoon.Rgb96F,
    2,
    1,
    stride=rgb_stride,
  )
  debug_inspect(rgb.get_format(), content="Rgb96F")
  inspect(rgb.get_stride(), content="\{rgb_stride}")
  inspect(rgb.copy_data() == Bytes::from_array(rgb_data), content="true")

  let rgba_stride = @cairoon.Format::stride_for_width(@cairoon.Rgba128F, 2)
  let rgba_data : FixedArray[Byte] = FixedArray::make(rgba_stride, b'\x00')
  let rgba = @cairoon.Surface::image_for_data(
    rgba_data,
    @cairoon.Rgba128F,
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
  let ctx = @cairoon.Context::new(surface)
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
  let zero_height = @cairoon.Surface::image_for_data(
    data,
    @cairoon.Argb32,
    10,
    0,
  )
  inspect(zero_height.get_width(), content="10")
  inspect(zero_height.get_height(), content="0")
  inspect(zero_height.get_stride(), content="40")
  inspect(zero_height.copy_data().length(), content="0")

  let zero_width = @cairoon.Surface::image_for_data(
    data,
    @cairoon.Argb32,
    0,
    10,
  )
  inspect(zero_width.get_width(), content="0")
  inspect(zero_width.get_height(), content="10")
  inspect(zero_width.get_stride(), content="0")
  inspect(zero_width.copy_data().length(), content="0")
}

///|
test "image surface for data validates stride and buffer size" {
  let stride = @cairoon.Format::stride_for_width(@cairoon.Argb32, 1)
  let short : FixedArray[Byte] = FixedArray::make(stride - 1, b'\x00')
  let short_result = @cairoon.run_cairo(() => {
    @cairoon.Surface::image_for_data(short, @cairoon.Argb32, 1, 1, stride~)
  })
  match short_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidSize, _)) => ()
    _ => @test.fail("expected InvalidSize for short image buffer")
  }

  let bad_stride : FixedArray[Byte] = FixedArray::make(12, b'\x00')
  let stride_result = @cairoon.run_cairo(() => {
    @cairoon.Surface::image_for_data(
      bad_stride,
      @cairoon.Argb32,
      3,
      3,
      stride=3,
    )
  })
  match stride_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidStride, _)) => ()
    _ => @test.fail("expected InvalidStride for invalid image stride")
  }

  let negative : FixedArray[Byte] = FixedArray::make(0, b'\x00')
  let negative_result = @cairoon.run_cairo(() => {
    @cairoon.Surface::image_for_data(negative, @cairoon.Argb32, -1, 1)
  })
  match negative_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidSize, _)) => ()
    _ => @test.fail("expected InvalidSize for negative image dimension")
  }
}
