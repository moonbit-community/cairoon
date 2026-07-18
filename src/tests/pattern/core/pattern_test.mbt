///|
test "solid pattern exposes rgba" {
  let rgb_pattern = @cairoon.Pattern::solid_rgb(0.125, 0.25, 0.5)
  let (_, _, _, opaque_alpha) = rgb_pattern.get_rgba()
  inspect(opaque_alpha, content="1")

  let pattern = @cairoon.Pattern::solid_rgba(0.125, 0.25, 0.5, 0.75)
  let (red, green, blue, alpha) = pattern.get_rgba()
  inspect(red, content="0.125")
  inspect(green, content="0.25")
  inspect(blue, content="0.5")
  inspect(alpha, content="0.75")
}

///|
test "pattern equality and hash use cairo pointer identity" {
  let surface = @cairoon.Surface::image(Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
  let pattern = ctx.get_source()
  let same = ctx.get_source()
  inspect(pattern.equal(same), content="true")
  inspect(pattern.hash() == same.hash(), content="true")

  let other = @cairoon.Pattern::solid_rgb(0.0, 0.0, 0.0)
  inspect(pattern.equal(other), content="false")
  inspect(other.hash() == 0UL, content="false")
}

///|
fn expect_pattern_dither_unavailable(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  match result {
    Err(CairoError(InvalidStatus, _)) => ()
    _ => @test.fail("expected dither API to require Cairo 1.18")
  }
}

///|
test "pattern extend filter and matrix mirror cairo state" {
  let pattern = @cairoon.Pattern::solid_rgb(1.0, 0.0, 0.0)
  debug_inspect(pattern.get_extend(), content="Pad")
  debug_inspect(pattern.get_filter(), content="Good")
  pattern.set_extend(Repeat)
  pattern.set_filter(Nearest)
  if @cairoon.CAIRO_VERSION >= 11800 {
    pattern.set_dither(DitherBest)
  } else {
    expect_pattern_dither_unavailable(
      @cairoon.run_cairo(() => pattern.set_dither(DitherBest)),
    )
  }
  let matrix = @cairoon.Matrix::new(xx=0.5, yy=0.25, x0=3.0, y0=5.0)
  pattern.set_matrix(matrix)
  debug_inspect(pattern.get_extend(), content="Repeat")
  debug_inspect(pattern.get_filter(), content="Nearest")
  if @cairoon.CAIRO_VERSION >= 11800 {
    debug_inspect(pattern.get_dither(), content="DitherBest")
  }
  debug_inspect(
    pattern.get_matrix(),
    content="{ xx: 0.5, yx: 0, xy: 0, yy: 0.25, x0: 3, y0: 5 }",
  )
}

///|
test "pattern rejects a singular matrix with InvalidMatrix" {
  let pattern = @cairoon.Pattern::solid_rgb(1.0, 0.0, 0.0)
  let singular = @cairoon.Matrix::new(xx=1.0, yx=2.0, xy=2.0, yy=4.0)
  let result = @cairoon.run_cairo(() => pattern.set_matrix(singular))
  match result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
  match @cairoon.run_cairo(() => pattern.get_matrix()) {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected sticky InvalidMatrix status")
  }
}

///|
test "pattern raw extend mirrors pycairo c int passthrough" {
  let pattern = @cairoon.Pattern::solid_rgb(1.0, 0.0, 0.0)
  inspect(pattern.get_extend_raw(), content="3")

  pattern.set_extend_raw(42)
  inspect(pattern.get_extend_raw(), content="42")
  let typed_unknown = @cairoon.run_cairo(() => pattern.get_extend())
  match typed_unknown {
    Err(CairoInvalidArgument(InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw extend")
  }

  pattern.set_extend_raw(0)
  inspect(pattern.get_extend_raw(), content="0")
  debug_inspect(pattern.get_extend(), content="ExtendNone")
}

///|
test "pattern raw filter and dither mirror pycairo c int passthrough" {
  let pattern = @cairoon.Pattern::solid_rgb(1.0, 0.0, 0.0)
  inspect(pattern.get_filter_raw(), content="1")
  if @cairoon.CAIRO_VERSION >= 11800 {
    inspect(pattern.get_dither_raw(), content="1")
  } else {
    expect_pattern_dither_unavailable(
      @cairoon.run_cairo(() => {
        let _ = pattern.get_dither_raw()
        ()
      }),
    )
  }

  pattern.set_filter_raw(42)
  inspect(pattern.get_filter_raw(), content="42")
  let typed_filter_unknown = @cairoon.run_cairo(() => pattern.get_filter())
  match typed_filter_unknown {
    Err(CairoInvalidArgument(InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw filter")
  }

  pattern.set_filter_raw(3)
  inspect(pattern.get_filter_raw(), content="3")
  debug_inspect(pattern.get_filter(), content="Nearest")

  if @cairoon.CAIRO_VERSION >= 11800 {
    pattern.set_dither_raw(42)
    inspect(pattern.get_dither_raw(), content="42")
    let typed_dither_unknown = @cairoon.run_cairo(() => pattern.get_dither())
    match typed_dither_unknown {
      Err(CairoInvalidArgument(InvalidStatus, _)) => ()
      _ => @test.fail("expected typed getter to reject unknown raw dither")
    }

    pattern.set_dither_raw(0)
    inspect(pattern.get_dither_raw(), content="0")
    debug_inspect(pattern.get_dither(), content="DitherNone")
  } else {
    expect_pattern_dither_unavailable(
      @cairoon.run_cairo(() => pattern.set_dither_raw(42)),
    )
  }
}

///|
test "context can paint from explicit solid pattern" {
  let surface = @cairoon.Surface::image(Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
  let pattern = @cairoon.Pattern::solid_rgba(0.0, 1.0, 0.0, 1.0)
  ctx.set_source(pattern)
  ctx.paint()
  let data = surface.copy_data()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
fn make_red_surface_pattern() -> @cairoon.Pattern raise @cairoon.CairoError {
  let source = @cairoon.Surface::image(Argb32, 1, 1)
  let source_ctx = @cairoon.Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()
  @cairoon.Pattern::for_surface(source)
}

///|
test "surface pattern paints after source scope exits" {
  let pattern = make_red_surface_pattern()
  let surface = @cairoon.Surface::image(Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
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
  let source = @cairoon.Surface::image(Argb32, 1, 1)
  let source_ctx = @cairoon.Context::new(source)
  source_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  source_ctx.paint()
  let pattern = @cairoon.Pattern::for_surface(source)
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
fn make_returned_surface_from_pattern() -> @cairoon.Surface raise @cairoon.CairoError {
  let source = @cairoon.Surface::image(Argb32, 1, 1)
  let source_ctx = @cairoon.Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()
  let pattern = @cairoon.Pattern::for_surface(source)
  pattern.get_surface()
}

///|
fn make_returned_data_surface_from_pattern() -> @cairoon.Surface raise @cairoon.CairoError {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let source = @cairoon.Surface::image_for_data(data, Argb32, 1, 1)
  let source_ctx = @cairoon.Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()
  let pattern = @cairoon.Pattern::for_surface(source)
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
  let solid = @cairoon.Pattern::solid_rgba(0.0, 0.0, 1.0, 1.0)
  let result = @cairoon.run_cairo(() => {
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
  let result = @cairoon.run_cairo(() => pattern.get_rgba())
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}
