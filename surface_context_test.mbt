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
