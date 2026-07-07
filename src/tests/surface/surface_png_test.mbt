///|
test "image surface png file roundtrip and invalid paths" {
  let path = "/tmp/cairoon_surface_png_roundtrip.png"
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 2, 1)
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
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for write_to_png")
  }
  let read_result = @cairoon.run_cairo(() => {
    @cairoon.Surface::image_from_png(invalid_path)
  })
  match read_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for image_from_png")
  }
}
