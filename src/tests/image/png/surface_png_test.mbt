///|
test "image surface png file roundtrip and invalid paths" {
  let path = "/tmp/cairoon_surface_png_roundtrip.png"
  let surface = @cairoon.Surface::image(Argb32, 2, 1)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgba(0.0, 0.0, 1.0, 0.5)
  ctx.paint()
  surface.write_to_png(path)

  let loaded = @cairoon.Surface::image_from_png(path)
  inspect(loaded.get_width(), content="2")
  inspect(loaded.get_height(), content="1")
  debug_inspect(loaded.get_format(), content="Argb32")
  inspect(loaded.copy_data() == surface.copy_data(), content="true")

  let invalid_path = "/tmp/cairoon\u{0}bad.png"
  let write_result = @cairoon.run_cairo(() => surface.write_to_png(invalid_path))
  match write_result {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for write_to_png")
  }
  let read_result = @cairoon.run_cairo(() => {
    @cairoon.Surface::image_from_png(invalid_path)
  })
  match read_result {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for image_from_png")
  }
}

///|
test "corrupt PNG file preserves version-specific Cairo status" {
  let valid_path = "/tmp/cairoon_png_valid_for_corruption.png"
  let corrupt_path = "/tmp/cairoon_png_corrupt_crc.png"
  let surface = @cairoon.Surface::image(Argb32, 2, 2)
  surface.write_to_png(valid_path)
  let input = @fs.read_file_to_bytes(valid_path)
  let corrupt = Bytes::makei(input.length(), fn(index) {
    if index == 29 {
      if input[index] == b'\x00' {
        b'\x01'
      } else {
        b'\x00'
      }
    } else {
      input[index]
    }
  })
  @fs.write_bytes_to_file(corrupt_path, corrupt)
  let result = @cairoon.run_cairo(() => {
    let _ = @cairoon.Surface::image_from_png(corrupt_path)
    ()
  })
  let expects_no_memory = @cairoon.CAIRO_VERSION >= 11600 &&
    @cairoon.CAIRO_VERSION <= 11800
  if @cairoon.CAIRO_VERSION >= 11802 {
    match result {
      Err(CairoIOError(PngError, _)) => ()
      _ => @test.fail("expected PngError for a corrupt PNG file")
    }
  } else if expects_no_memory {
    match result {
      Err(CairoMemoryError(NoMemory, _)) => ()
      _ => @test.fail("expected Cairo 1.16-1.18.0 malformed-PNG status")
    }
  } else {
    inspect(result is Err(_), content="true")
  }
  @fs.remove_file(valid_path)
  @fs.remove_file(corrupt_path)
}
