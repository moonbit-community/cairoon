///|
fn make_returned_target_surface() -> Surface raise CairoError {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.paint()
  ctx.get_target()
}

///|
fn make_context_with_local_surface_source() -> Context raise CairoError {
  let target = Surface::image(Argb32, 1, 1)
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()

  let ctx = Context::new(target)
  ctx.set_source_surface(source)
  ctx
}

///|
fn make_source_pattern_from_local_context() -> Pattern raise CairoError {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()

  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.set_source_surface(source)
  ctx.get_source()
}

///|
test "context get_target returns a referenced surface wrapper" {
  let target = make_returned_target_surface()
  let data = target.copy_data()
  inspect(data.length(), content="4")
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
test "context equality and hash use cairo pointer identity" {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  let same = ctx
  let other = Context::new(surface)
  inspect(ctx.equal(same), content="true")
  inspect(ctx.hash() == same.hash(), content="true")
  inspect(ctx.equal(other), content="false")
}

///|
test "context get_source returns an independent pattern wrapper" {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 0.5)
  let source = ctx.get_source()
  ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  let (red, green, blue, alpha) = source.get_rgba()
  inspect(red, content="1")
  inspect(green, content="0")
  inspect(blue, content="0")
  inspect(alpha, content="0.5")
}

///|
test "context set_source_surface keeps source cairo surface alive" {
  let ctx = make_context_with_local_surface_source()
  ctx.paint()
  let target = ctx.get_target()
  let data = target.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
test "context get_source surface pattern survives source and context scopes" {
  let pattern = make_source_pattern_from_local_context()
  let source = pattern.get_surface()
  inspect(source.get_width(), content="1")
  let source_data = source.copy_data()
  inspect(source_data[0].to_int(), content="255")
  inspect(source_data[1].to_int(), content="0")
  inspect(source_data[2].to_int(), content="0")
  inspect(source_data[3].to_int(), content="255")

  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()
  let target_data = target.copy_data()
  inspect(target_data[0].to_int(), content="255")
  inspect(target_data[1].to_int(), content="0")
  inspect(target_data[2].to_int(), content="0")
  inspect(target_data[3].to_int(), content="255")
}

///|
test "surface copy_page and show_page are checked operations" {
  let surface = Surface::image(Argb32, 1, 1)
  surface.copy_page()
  surface.show_page()
  debug_inspect(surface.status(), content="Success")
}

///|
test "context borrowed returns propagate cairo error" {
  let ctx = Context::new(Surface::image(Argb32, 1, 1))
  let set_result = run_cairo(() => ctx.set_matrix(Matrix::new(xx=0.0, yy=0.0)))
  inspect(set_result is Err(_), content="true")

  let target_result = run_cairo(() => {
    let _ = ctx.get_target()
    ()
  })
  inspect(target_result is Err(_), content="true")
  match target_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let source_result = run_cairo(() => {
    let _ = ctx.get_source()
    ()
  })
  inspect(source_result is Err(_), content="true")
  match source_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
