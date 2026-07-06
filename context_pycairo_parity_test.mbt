///|
fn pycairo_context_surface(
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  Surface::image(Argb32, width, height)
}

///|
fn assert_pycairo_context_close(
  actual : Double,
  expected : Double,
) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected \{expected}, got \{actual}")
  }
}

///|
fn assert_pycairo_context_extents_close(
  actual : (Double, Double, Double, Double),
  expected : (Double, Double, Double, Double),
) -> Unit raise {
  let (actual_x1, actual_y1, actual_x2, actual_y2) = actual
  let (expected_x1, expected_y1, expected_x2, expected_y2) = expected
  assert_pycairo_context_close(actual_x1, expected_x1)
  assert_pycairo_context_close(actual_y1, expected_y1)
  assert_pycairo_context_close(actual_x2, expected_x2)
  assert_pycairo_context_close(actual_y2, expected_y2)
}

///|
fn assert_pycairo_context_point_close(
  actual : (Double, Double),
  expected : (Double, Double),
) -> Unit raise {
  let (actual_x, actual_y) = actual
  let (expected_x, expected_y) = expected
  assert_pycairo_context_close(actual_x, expected_x)
  assert_pycairo_context_close(actual_y, expected_y)
}

///|
fn assert_pycairo_context_matrix_close(
  actual : Matrix,
  expected : Matrix,
) -> Unit raise {
  assert_pycairo_context_close(actual.xx, expected.xx)
  assert_pycairo_context_close(actual.yx, expected.yx)
  assert_pycairo_context_close(actual.xy, expected.xy)
  assert_pycairo_context_close(actual.yy, expected.yy)
  assert_pycairo_context_close(actual.x0, expected.x0)
  assert_pycairo_context_close(actual.y0, expected.y0)
}

///|
test "context default clip extents mirror pycairo fixture dimensions" {
  let ctx = Context::new(pycairo_context_surface(42, 42))
  assert_pycairo_context_extents_close(
    ctx.clip_extents(),
    (0.0, 0.0, 42.0, 42.0),
  )
}

///|
test "zero radius arcs leave non-empty paths like pycairo" {
  let ctx = Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.copy_path().length(), content="0")

  ctx.arc(0.0, 0.0, 0.0, 0.0, 0.0)
  inspect(ctx.copy_path().length() > 0, content="true")

  ctx.new_path()
  inspect(ctx.copy_path().length(), content="0")

  ctx.arc_negative(0.0, 0.0, 0.0, 0.0, 0.0)
  inspect(ctx.copy_path().length() > 0, content="true")
}

///|
test "context polygon path_extents mirror pycairo fixture" {
  let ctx = Context::new(pycairo_context_surface(42, 42))
  ctx.line_to(1.0, 1.0)
  ctx.line_to(1.0, 0.0)
  ctx.line_to(0.0, 0.0)
  ctx.line_to(0.0, 1.0)
  ctx.line_to(1.0, 1.0)
  assert_pycairo_context_extents_close(ctx.path_extents(), (0.0, 0.0, 1.0, 1.0))
}

///|
test "context line in_stroke mirrors pycairo fixture" {
  let ctx = Context::new(pycairo_context_surface(42, 42))
  ctx.line_to(0.0, 0.0)
  ctx.line_to(1.0, 1.0)
  inspect(ctx.in_stroke(0.0, 0.0), content="true")
  inspect(ctx.in_stroke(0.0, 2.0), content="false")
}

///|
test "context current point mirrors pycairo fixture" {
  let ctx = Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.has_current_point(), content="false")
  assert_pycairo_context_point_close(ctx.get_current_point(), (0.0, 0.0))

  ctx.move_to(10.0, 10.0)
  inspect(ctx.has_current_point(), content="true")
  assert_pycairo_context_point_close(ctx.get_current_point(), (10.0, 10.0))
}

///|
test "context empty stroke_extents mirror pycairo fixture" {
  let ctx = Context::new(pycairo_context_surface(42, 42))
  assert_pycairo_context_extents_close(
    ctx.stroke_extents(),
    (0.0, 0.0, 0.0, 0.0),
  )
}

///|
test "context default coordinate conversions mirror pycairo zero fixture" {
  let ctx = Context::new(pycairo_context_surface(42, 42))
  assert_pycairo_context_point_close(ctx.device_to_user(0.0, 0.0), (0.0, 0.0))
  assert_pycairo_context_point_close(
    ctx.device_to_user_distance(0.0, 0.0),
    (0.0, 0.0),
  )
  assert_pycairo_context_point_close(ctx.user_to_device(0.0, 0.0), (0.0, 0.0))
  assert_pycairo_context_point_close(
    ctx.user_to_device_distance(0.0, 0.0),
    (0.0, 0.0),
  )
}

///|
test "context dash state mirrors pycairo fixture" {
  let ctx = Context::new(pycairo_context_surface(42, 42))
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
  let ctx = Context::new(pycairo_context_surface(42, 42))

  ctx.set_line_width(42.0)
  assert_pycairo_context_close(ctx.get_line_width(), 42.0)

  ctx.set_miter_limit(42.0)
  assert_pycairo_context_close(ctx.get_miter_limit(), 42.0)

  ctx.set_tolerance(42.0)
  assert_pycairo_context_close(ctx.get_tolerance(), 42.0)
}

///|
test "context source rgba mirrors pycairo fixture" {
  let ctx = Context::new(pycairo_context_surface(42, 42))

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
test "context empty font family selection mirrors pycairo fixture" {
  let ctx = Context::new(pycairo_context_surface(42, 42))
  ctx.select_font_face("")
  inspect(ctx.status().is_success(), content="true")
}

///|
test "context set_font_size mirrors pycairo font matrix fixture" {
  let ctx = Context::new(pycairo_context_surface(42, 42))
  ctx.set_font_size(42.0)
  assert_pycairo_context_matrix_close(
    ctx.get_font_matrix(),
    Matrix::new(xx=42.0, yy=42.0),
  )
}
