///|
test "solid pattern exposes rgba" {
  let rgb_pattern = Pattern::solid_rgb(0.125, 0.25, 0.5)
  let (_, _, _, opaque_alpha) = rgb_pattern.get_rgba()
  inspect(opaque_alpha, content="1")

  let pattern = Pattern::solid_rgba(0.125, 0.25, 0.5, 0.75)
  let (red, green, blue, alpha) = pattern.get_rgba()
  inspect(red, content="0.125")
  inspect(green, content="0.25")
  inspect(blue, content="0.5")
  inspect(alpha, content="0.75")
}

///|
test "pattern extend filter and matrix mirror cairo state" {
  let pattern = Pattern::solid_rgb(1.0, 0.0, 0.0)
  debug_inspect(pattern.get_extend(), content="Pad")
  debug_inspect(pattern.get_filter(), content="Good")
  pattern.set_extend(Repeat)
  pattern.set_filter(Nearest)
  pattern.set_dither(DitherBest)
  let matrix = Matrix::new(xx=0.5, yy=0.25, x0=3.0, y0=5.0)
  pattern.set_matrix(matrix)
  debug_inspect(pattern.get_extend(), content="Repeat")
  debug_inspect(pattern.get_filter(), content="Nearest")
  debug_inspect(pattern.get_dither(), content="DitherBest")
  debug_inspect(
    pattern.get_matrix(),
    content="{ xx: 0.5, yx: 0, xy: 0, yy: 0.25, x0: 3, y0: 5 }",
  )
}

///|
test "context can paint from explicit solid pattern" {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  let pattern = Pattern::solid_rgba(0.0, 1.0, 0.0, 1.0)
  ctx.set_source(pattern)
  ctx.paint()
  let data = surface.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
fn make_red_surface_pattern() -> Pattern raise CairoError {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()
  Pattern::for_surface(source)
}

///|
test "surface pattern paints after source scope exits" {
  let pattern = make_red_surface_pattern()
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.set_source(pattern)
  ctx.paint()
  let data = surface.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
test "surface pattern get_surface returns referenced surface wrapper" {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  source_ctx.paint()
  let pattern = Pattern::for_surface(source)
  let returned = pattern.get_surface()
  inspect(returned.get_width(), content="1")
  inspect(returned.get_height(), content="1")
  let data = returned.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
fn make_returned_surface_from_pattern() -> Surface raise CairoError {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()
  let pattern = Pattern::for_surface(source)
  pattern.get_surface()
}

///|
fn make_returned_data_surface_from_pattern() -> Surface raise CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let source = Surface::image_for_data(data, Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()
  let pattern = Pattern::for_surface(source)
  pattern.get_surface()
}

///|
test "surface pattern get_surface survives source and pattern scopes" {
  let returned = make_returned_surface_from_pattern()
  let data = returned.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
test "surface pattern get_surface keeps data-backed surface alive" {
  let returned = make_returned_data_surface_from_pattern()
  let data = returned.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
test "non-surface pattern get_surface maps type mismatch status" {
  let solid = Pattern::solid_rgba(0.0, 0.0, 1.0, 1.0)
  let result = run_cairo(() => {
    let _ = solid.get_surface()
    ()
  })
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}

///|
test "surface pattern get_rgba maps type mismatch status" {
  let pattern = make_red_surface_pattern()
  let result = run_cairo(() => pattern.get_rgba())
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}

///|
test "raster source pattern paints from acquire callback" {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()

  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let extent_width = Ref(0)
  let target_width = Ref(0)
  let released_width = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(
    fn(target, extents) {
      acquire_calls.val += 1
      extent_width.val = extents.width
      target_width.val = target.get_width()
      source
    },
    release=Some(fn(surface) {
      release_calls.val += 1
      released_width.val = surface.get_width()
    }),
  )

  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()
  target.flush()

  let data = target.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
  inspect(acquire_calls.val > 0, content="true")
  inspect(release_calls.val == acquire_calls.val, content="true")
  inspect(extent_width.val > 0, content="true")
  inspect(target_width.val, content="1")
  inspect(released_width.val, content="1")
}

///|
fn make_data_backed_raster_source_pattern() -> Pattern raise CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let source = Surface::image_for_data(data, Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()

  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(fn(_, _) { source })
  pattern
}

///|
test "raster source pattern retains data backed acquire surface" {
  let pattern = make_data_backed_raster_source_pattern()
  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()
  let data = target.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
test "raster source acquire validates pattern subtype" {
  let source = Surface::image(Argb32, 1, 1)
  let solid = Pattern::solid_rgba(0.0, 0.0, 1.0, 1.0)
  let set_result = run_cairo(() => solid.raster_set_acquire(fn(_, _) { source }))
  match set_result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }

  let clear_result = run_cairo(() => solid.raster_clear_acquire())
  match clear_result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}

///|
test "raster source get_acquire returns current callbacks" {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  source_ctx.paint()

  let acquire_calls = Ref(0)
  let release_calls = Ref(0)
  let acquired_target_width = Ref(0)
  let acquired_extent_width = Ref(0)
  let released_height = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(
    fn(target, extents) {
      acquire_calls.val += 1
      acquired_target_width.val = target.get_width()
      acquired_extent_width.val = extents.width
      source
    },
    release=Some(fn(surface) {
      release_calls.val += 1
      released_height.val = surface.get_height()
    }),
  )

  match pattern.raster_get_acquire() {
    Some((acquire, Some(release))) => {
      let target = Surface::image(Argb32, 1, 1)
      let acquired = acquire(target, RectangleInt::new(width=1, height=1))
      release(acquired)
      inspect(acquire_calls.val, content="1")
      inspect(release_calls.val, content="1")
      inspect(acquired_target_width.val, content="1")
      inspect(acquired_extent_width.val, content="1")
      inspect(released_height.val, content="1")
    }
    _ => @test.fail("expected acquire and release callbacks")
  }
}

///|
test "raster source get_acquire reports optional and cleared callbacks" {
  let source = Surface::image(Argb32, 1, 1)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  inspect(pattern.raster_get_acquire() is None, content="true")

  pattern.raster_set_acquire(fn(_, _) { source })
  match pattern.raster_get_acquire() {
    Some((acquire, None)) => {
      let target = Surface::image(Argb32, 1, 1)
      let acquired = acquire(target, RectangleInt::new(width=1, height=1))
      inspect(acquired.get_width(), content="1")
    }
    _ => @test.fail("expected acquire callback without release")
  }

  pattern.raster_clear_acquire()
  inspect(pattern.raster_get_acquire() is None, content="true")

  let solid = Pattern::solid_rgba(0.0, 0.0, 0.0, 1.0)
  let result = run_cairo(() => solid.raster_get_acquire())
  match result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}
