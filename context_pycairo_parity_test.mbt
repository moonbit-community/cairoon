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
