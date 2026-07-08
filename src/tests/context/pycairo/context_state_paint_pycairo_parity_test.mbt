///|
test "context default drawing state getters mirror pycairo fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  debug_inspect(ctx.get_antialias(), content="AntialiasDefault")
  debug_inspect(ctx.get_fill_rule(), content="FillWinding")
  debug_inspect(ctx.get_line_cap(), content="LineCapButt")
  debug_inspect(ctx.get_line_join(), content="LineJoinMiter")
  debug_inspect(ctx.get_operator(), content="OperatorOver")
}

///|
test "context drawing state setters mirror pycairo enum fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.set_antialias(@cairoon.AntialiasSubpixel)
  ctx.set_fill_rule(@cairoon.FillEvenOdd)
  ctx.set_line_cap(@cairoon.LineCapSquare)
  ctx.set_line_join(@cairoon.LineJoinBevel)
  ctx.set_operator(@cairoon.OperatorSource)

  debug_inspect(ctx.get_antialias(), content="AntialiasSubpixel")
  debug_inspect(ctx.get_fill_rule(), content="FillEvenOdd")
  debug_inspect(ctx.get_line_cap(), content="LineCapSquare")
  debug_inspect(ctx.get_line_join(), content="LineJoinBevel")
  debug_inspect(ctx.get_operator(), content="OperatorSource")
}

///|
test "context hairline mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.get_hairline(), content="false")
  ctx.set_hairline(true)
  inspect(ctx.get_hairline(), content="true")
}

///|
test "context raw operator limits mirror pycairo c int fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let min_c_int = -2147483647 - 1
  let values = [-1, 0, 2147483647, min_c_int]
  for value in values {
    ctx.set_operator_raw(value)
    inspect(ctx.get_operator_raw(), content="\{value}")
  }

  match @cairoon.run_cairo(() => ctx.get_operator()) {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidStatus, _)) => ()
    _ => @test.fail("expected typed getter to reject unknown raw operator")
  }

  ctx.set_operator_raw(0)
  debug_inspect(ctx.get_operator(), content="OperatorClear")
}

///|
test "context save restore preserves drawing state like pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.set_line_width(3.0)
  ctx.save()
  ctx.set_line_width(7.0)
  assert_pycairo_context_close(ctx.get_line_width(), 7.0)
  ctx.restore()
  assert_pycairo_context_close(ctx.get_line_width(), 3.0)
}

///|
test "context dash state mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.get_dash_count(), content="0")
  let (empty_dashes, empty_offset) = ctx.get_dash()
  inspect(empty_dashes.length(), content="0")
  inspect(empty_offset, content="0")

  ctx.set_dash([0.0, 1.0, 2.0, 3.0], offset=10.0)
  inspect(ctx.get_dash_count(), content="4")
  let (dashes, offset) = ctx.get_dash()
  inspect(dashes.length(), content="4")
  inspect(dashes[0], content="0")
  inspect(dashes[1], content="1")
  inspect(dashes[2], content="2")
  inspect(dashes[3], content="3")
  inspect(offset, content="4")

  ctx.set_dash([1.0], offset=1.25)
  let (single_dash, single_offset) = ctx.get_dash()
  inspect(single_dash.length(), content="1")
  inspect(single_dash[0], content="1")
  inspect(single_offset, content="1.25")
}

///|
test "context scalar setters mirror pycairo numeric fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))

  ctx.set_line_width(42.0)
  assert_pycairo_context_close(ctx.get_line_width(), 42.0)

  ctx.set_miter_limit(42.0)
  assert_pycairo_context_close(ctx.get_miter_limit(), 42.0)

  ctx.set_tolerance(42.0)
  assert_pycairo_context_close(ctx.get_tolerance(), 42.0)
}

///|
test "context source rgba mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))

  ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
  assert_pycairo_context_extents_close(
    ctx.get_source().get_rgba(),
    (1.0, 1.0, 1.0, 1.0),
  )

  ctx.set_source_rgba(1.0, 1.0, 1.0, 0.5)
  assert_pycairo_context_extents_close(
    ctx.get_source().get_rgba(),
    (1.0, 1.0, 1.0, 0.5),
  )
}

///|
test "context explicit source pattern mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let pattern = @cairoon.Pattern::solid_rgb(0.0, 0.0, 0.0)
  ctx.set_source(pattern)
  inspect(ctx.get_source().equal(pattern), content="true")
}

///|
test "context append_path mirrors pycairo copied path fixture" {
  let source = @cairoon.Context::new(pycairo_context_surface(42, 42))
  source.line_to(1.0, 2.0)
  let path = source.copy_path()
  let source_string = path.to_string()

  let target = @cairoon.Context::new(pycairo_context_surface(42, 42))
  target.append_path(path)
  let target_string = target.copy_path().to_string()
  inspect(target_string == source_string, content="true")
}

///|
test "context empty clip reset mirrors pycairo in_clip fixture" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 100, 100),
  )
  inspect(ctx.in_clip(50.0, 50.0), content="true")
  ctx.clip()
  inspect(ctx.in_clip(50.0, 50.0), content="false")
  ctx.reset_clip()
  inspect(ctx.in_clip(50.0, 50.0), content="true")
}

///|
test "context group stack mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.push_group()
  let _ = ctx.pop_group()

  ctx.push_group()
  ctx.pop_group_to_source()

  ctx.push_group_with_content(@cairoon.ContentColor)
  let _ = ctx.pop_group()

  expect_pycairo_context_invalid_pop_group(
    @cairoon.run_cairo(() => {
      let _ = ctx.pop_group()
      ()
    }),
  )
}

///|
test "context mask and alpha paint mirror pycairo fixtures" {
  let paint_surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let paint_ctx = @cairoon.Context::new(paint_surface)
  paint_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  paint_ctx.paint_with_alpha(1.0)
  assert_pycairo_context_argb32_pixel(paint_surface, [0, 0, 255, 255])

  let pattern_surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let pattern_ctx = @cairoon.Context::new(pattern_surface)
  pattern_ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  pattern_ctx.mask(@cairoon.Pattern::solid_rgba(0.0, 0.0, 0.0, 1.0))
  assert_pycairo_context_argb32_pixel(pattern_surface, [0, 255, 0, 255])

  let mask_surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let mask_ctx = @cairoon.Context::new(mask_surface)
  mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
  mask_ctx.paint()

  let surface_mask_target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let surface_mask_ctx = @cairoon.Context::new(surface_mask_target)
  surface_mask_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  surface_mask_ctx.mask_surface(mask_surface)
  assert_pycairo_context_argb32_pixel(surface_mask_target, [255, 0, 0, 255])
}

///|
test "context surface source offsets mirror pycairo fixtures" {
  let source = pycairo_context_colored_argb32_source()
  let source_data = source.copy_data()

  let default_target = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
  let default_ctx = @cairoon.Context::new(default_target)
  default_ctx.set_source_surface(source)
  default_ctx.paint()
  inspect(default_target.copy_data() == source_data, content="true")

  let shifted_target = @cairoon.Surface::image(@cairoon.Argb32, 3, 3)
  let shifted_ctx = @cairoon.Context::new(shifted_target)
  shifted_ctx.set_source_surface(source, x=1.0, y=1.0)
  shifted_ctx.paint()
  assert_pycairo_context_argb32_pixel_at(shifted_target, 0, 0, [0, 0, 0, 0])
  assert_pycairo_context_argb32_pixel_at(shifted_target, 1, 1, [0, 0, 255, 255])
  assert_pycairo_context_argb32_pixel_at(shifted_target, 2, 1, [0, 255, 0, 255])
  assert_pycairo_context_argb32_pixel_at(shifted_target, 1, 2, [255, 0, 0, 255])
  assert_pycairo_context_argb32_pixel_at(shifted_target, 2, 2, [
    255, 255, 255, 255,
  ])
}

///|
test "context mask_surface offset mirrors pycairo fixture" {
  let mask = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let mask_ctx = @cairoon.Context::new(mask)
  mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
  mask_ctx.paint()

  let target = @cairoon.Surface::image(@cairoon.Argb32, 3, 3)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  ctx.mask_surface(mask, x=1.0, y=1.0)
  assert_pycairo_context_argb32_pixel_at(target, 0, 0, [0, 0, 0, 0])
  assert_pycairo_context_argb32_pixel_at(target, 1, 1, [255, 0, 0, 255])
}
