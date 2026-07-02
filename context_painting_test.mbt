///|
fn assert_painting_byte_between(
  actual : Byte,
  low : Int,
  high : Int,
) -> Unit raise {
  let value = actual.to_int()
  if value < low || value > high {
    @test.fail("expected byte in [\{low}, \{high}], got \{value}")
  }
}

///|
fn expect_painting_invalid_matrix(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}

///|
test "context paint_with_alpha composites source alpha" {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.paint_with_alpha(0.5)
  let data = surface.copy_data()
  inspect(data.length(), content="4")
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  assert_painting_byte_between(data[2], 127, 128)
  assert_painting_byte_between(data[3], 127, 128)
}

///|
test "context mask and mask_surface apply alpha masks" {
  let pattern_target = Surface::image(Argb32, 1, 1)
  let pattern_ctx = Context::new(pattern_target)
  pattern_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  pattern_ctx.mask(Pattern::solid_rgba(0.0, 0.0, 0.0, 1.0))
  let pattern_data = pattern_target.copy_data()
  inspect(pattern_data[0].to_int(), content="0")
  inspect(pattern_data[1].to_int(), content="255")
  inspect(pattern_data[2].to_int(), content="0")
  inspect(pattern_data[3].to_int(), content="255")

  let mask_surface = Surface::image(Argb32, 1, 1)
  let mask_ctx = Context::new(mask_surface)
  mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
  mask_ctx.paint()

  let surface_target = Surface::image(Argb32, 1, 1)
  let surface_ctx = Context::new(surface_target)
  surface_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  surface_ctx.mask_surface(mask_surface)
  let surface_data = surface_target.copy_data()
  inspect(surface_data[0].to_int(), content="255")
  inspect(surface_data[1].to_int(), content="0")
  inspect(surface_data[2].to_int(), content="0")
  inspect(surface_data[3].to_int(), content="255")
}

///|
test "context set_source_surface samples surface at user-space origin" {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()

  let target = Surface::image(Argb32, 3, 3)
  let ctx = Context::new(target)
  ctx.set_source_surface(source, x=1.0, y=1.0)
  ctx.paint()

  let data = target.copy_data()
  let stride = target.get_stride()
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="0")
  inspect(data[stride + 4].to_int(), content="0")
  inspect(data[stride + 5].to_int(), content="0")
  inspect(data[stride + 6].to_int(), content="255")
  inspect(data[stride + 7].to_int(), content="255")
}

///|
test "context fill_preserve and stroke_preserve keep current path" {
  let fill_surface = Surface::image(Argb32, 4, 4)
  let fill_ctx = Context::new(fill_surface)
  fill_ctx.rectangle(1.0, 1.0, 2.0, 2.0)
  fill_ctx.fill_preserve()
  debug_inspect(fill_ctx.path_extents(), content="(1, 1, 3, 3)")
  fill_ctx.fill()
  debug_inspect(fill_ctx.path_extents(), content="(0, 0, 0, 0)")

  let stroke_surface = Surface::image(Argb32, 4, 4)
  let stroke_ctx = Context::new(stroke_surface)
  stroke_ctx.rectangle(1.0, 1.0, 2.0, 2.0)
  stroke_ctx.stroke_preserve()
  debug_inspect(stroke_ctx.path_extents(), content="(1, 1, 3, 3)")
  stroke_ctx.stroke()
  debug_inspect(stroke_ctx.path_extents(), content="(0, 0, 0, 0)")
}

///|
test "context copy_page and show_page are checked context operations" {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.copy_page()
  ctx.show_page()
  debug_inspect(ctx.status(), content="Success")
}

///|
test "context painting and page methods propagate cairo error" {
  let mask_surface = Surface::image(Argb32, 1, 1)
  let pattern = Pattern::solid_rgba(0.0, 0.0, 0.0, 1.0)
  let ctx = Context::new(Surface::image(Argb32, 1, 1))
  let set_result = run_cairo(() => ctx.set_matrix(Matrix::new(xx=0.0, yy=0.0)))
  inspect(set_result is Err(_), content="true")

  expect_painting_invalid_matrix(
    run_cairo(() => ctx.set_source_rgb(1.0, 0.0, 0.0)),
  )
  expect_painting_invalid_matrix(run_cairo(() => ctx.paint()))
  expect_painting_invalid_matrix(run_cairo(() => ctx.paint_with_alpha(0.5)))
  expect_painting_invalid_matrix(run_cairo(() => ctx.mask(pattern)))
  expect_painting_invalid_matrix(
    run_cairo(() => ctx.mask_surface(mask_surface)),
  )
  expect_painting_invalid_matrix(
    run_cairo(() => ctx.set_source_surface(mask_surface)),
  )
  expect_painting_invalid_matrix(run_cairo(() => ctx.fill_preserve()))
  expect_painting_invalid_matrix(run_cairo(() => ctx.stroke_preserve()))
  expect_painting_invalid_matrix(run_cairo(() => ctx.copy_page()))
  expect_painting_invalid_matrix(run_cairo(() => ctx.show_page()))
}
