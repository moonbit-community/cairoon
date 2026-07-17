///|
test "png stream writer receives image bytes" {
  let output = make_png_bytes()
  inspect(output.length() > 8, content="true")
  inspect(is_png_signature(output), content="true")
}

///|
test "png path and stream writers produce identical bytes" {
  let path = "/tmp/cairoon_png_path_stream_compare.png"
  if @fs.path_exists(path) {
    @fs.remove_file(path)
  }

  let surface = make_png_surface()
  surface.write_to_png(path)
  let path_bytes = @fs.read_file_to_bytes(path)

  let chunks : Array[Bytes] = []
  surface.write_to_png_stream(fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  inspect(path_bytes == chunks_to_bytes(chunks), content="true")

  let path_surface = @cairoon.Surface::image_from_png(path)
  let stream_bytes = chunks_to_bytes(chunks)
  let offset = Ref(0)
  let stream_surface = @cairoon.Surface::image_from_png_stream(fn(length) {
    let chunk = bytes_slice(stream_bytes, offset.val, length)
    offset.val += length
    chunk
  })
  inspect(
    path_surface.copy_data() == stream_surface.copy_data(),
    content="true",
  )

  @fs.remove_file(path)
}

///|
test "png stream writer status maps to cairo IO error" {
  expect_png_stream_write_error(@cairoon.WriteError)
}

///|
test "png stream writer stops user callbacks after first error" {
  let surface = make_png_surface()
  let calls = Ref(0)
  let result = @cairoon.run_cairo(() => {
    surface.write_to_png_stream(fn(_) {
      calls.val += 1
      @cairoon.WriteError
    })
  })
  match result {
    Err(@cairoon.CairoIOError(@cairoon.WriteError, _)) => ()
    _ => @test.fail("expected WriteError from PNG stream writer")
  }
  inspect(calls.val, content="1")
}

///|
test "png stream writer invalid status maps to write error" {
  expect_png_stream_write_error(@cairoon.LastStatus)
}

///|
test "png stream reader creates image surface" {
  let input = make_png_bytes()
  let offset = Ref(0)
  let surface = @cairoon.Surface::image_from_png_stream(fn(length) {
    let chunk = bytes_slice(input, offset.val, length)
    offset.val += length
    chunk
  })
  inspect(surface.get_width(), content="2")
  inspect(surface.get_height(), content="2")
  let format = surface.get_format()
  inspect(format == @cairoon.Argb32 || format == @cairoon.Rgb24, content="true")
  inspect(surface.copy_data() == make_png_surface().copy_data(), content="true")
  inspect(offset.val == input.length(), content="true")
}

///|
test "png stream reader short read maps to cairo IO error" {
  let input = make_png_bytes()
  let offset = Ref(0)
  let result = @cairoon.run_cairo(() => {
    let _ = @cairoon.Surface::image_from_png_stream(fn(length) {
      let available = input.length() - offset.val
      let actual = if available < length { available } else { length }
      let short = if actual > 0 { actual - 1 } else { 0 }
      let chunk = bytes_slice(input, offset.val, short)
      offset.val += short
      chunk
    })
    ()
  })
  match result {
    Err(@cairoon.CairoIOError(@cairoon.ReadError, _))
    | Err(@cairoon.CairoIOError(@cairoon.PngError, _)) => ()
    _ => @test.fail("expected read failure from PNG stream reader")
  }
}

///|
test "png stream reader maps corrupt image data to PngError" {
  let input = make_png_bytes()
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
  let offset = Ref(0)
  let result = @cairoon.run_cairo(() => {
    let _ = @cairoon.Surface::image_from_png_stream(fn(length) {
      let chunk = bytes_slice(corrupt, offset.val, length)
      offset.val += length
      chunk
    })
    ()
  })
  if @cairoon.CAIRO_VERSION >= 11600 {
    match result {
      Err(@cairoon.CairoIOError(@cairoon.PngError, _)) => ()
      _ => @test.fail("expected PngError for a corrupt IHDR checksum")
    }
  } else {
    inspect(result is Err(_), content="true")
  }
}
