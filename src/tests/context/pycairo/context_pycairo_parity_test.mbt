///|
fn pycairo_context_surface(
  width : Int,
  height : Int,
) -> @cairoon.Surface raise @cairoon.CairoError {
  @cairoon.Surface::image(Argb32, width, height)
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
  actual : @cairoon.Matrix,
  expected : @cairoon.Matrix,
) -> Unit raise {
  assert_pycairo_context_close(actual.xx, expected.xx)
  assert_pycairo_context_close(actual.yx, expected.yx)
  assert_pycairo_context_close(actual.xy, expected.xy)
  assert_pycairo_context_close(actual.yy, expected.yy)
  assert_pycairo_context_close(actual.x0, expected.x0)
  assert_pycairo_context_close(actual.y0, expected.y0)
}

///|
fn assert_pycairo_context_argb32_pixel(
  surface : @cairoon.Surface,
  expected : Array[Int],
) -> Unit raise {
  let data = surface.copy_data()
  inspect(data.length(), content="4")
  for index in 0..<expected.length() {
    inspect(data[index].to_int(), content="\{expected[index]}")
  }
}

///|
fn assert_pycairo_context_argb32_pixel_at(
  surface : @cairoon.Surface,
  x : Int,
  y : Int,
  expected : Array[Int],
) -> Unit raise {
  let data = surface.copy_data()
  let offset = y * surface.get_stride() + x * 4
  for index in 0..<expected.length() {
    inspect(data[offset + index].to_int(), content="\{expected[index]}")
  }
}

///|
fn pycairo_context_colored_argb32_source() -> @cairoon.Surface raise @cairoon.CairoError {
  let data : FixedArray[Byte] = FixedArray::make(16, b'\x00')
  data[0] = b'\x00'
  data[1] = b'\x00'
  data[2] = b'\xFF'
  data[3] = b'\xFF'
  data[4] = b'\x00'
  data[5] = b'\xFF'
  data[6] = b'\x00'
  data[7] = b'\xFF'
  data[8] = b'\xFF'
  data[9] = b'\x00'
  data[10] = b'\x00'
  data[11] = b'\xFF'
  data[12] = b'\xFF'
  data[13] = b'\xFF'
  data[14] = b'\xFF'
  data[15] = b'\xFF'
  @cairoon.Surface::image_for_data(data, Argb32, 2, 2)
}

///|
fn pycairo_context_has_nonzero_byte(bytes : Bytes) -> Bool {
  for index in 0..<bytes.length() {
    if bytes[index].to_int() != 0 {
      return true
    }
  }
  false
}

///|
fn expect_pycairo_context_invalid_pop_group(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(InvalidPopGroup, _)) => ()
    _ => @test.fail("expected InvalidPopGroup")
  }
}

///|
test "context default clip extents mirror pycairo fixture dimensions" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  assert_pycairo_context_extents_close(
    ctx.clip_extents(),
    (0.0, 0.0, 42.0, 42.0),
  )
}

///|
test "context cmp hash mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let other = @cairoon.Context::new(ctx.get_target())
  inspect(ctx == ctx, content="true")
  inspect(ctx != other, content="true")
  inspect(ctx.equal(other), content="false")
  inspect(ctx.not_equal(other), content="true")
  inspect(Hash::hash(ctx) == Hash::hash(ctx), content="true")
}

///|
test "context tags mirror pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.tag_begin("foo", "bar=quux")
  ctx.tag_end("foo")
  inspect(ctx.status().is_success(), content="true")
}

///|
test "zero radius arcs leave non-empty paths like pycairo" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
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
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.line_to(1.0, 1.0)
  ctx.line_to(1.0, 0.0)
  ctx.line_to(0.0, 0.0)
  ctx.line_to(0.0, 1.0)
  ctx.line_to(1.0, 1.0)
  assert_pycairo_context_extents_close(ctx.path_extents(), (0.0, 0.0, 1.0, 1.0))
}

///|
test "context fill_extents and empty in_fill mirror pycairo fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.in_fill(0.1, 0.1), content="false")

  ctx.line_to(1.0, 1.0)
  ctx.line_to(1.0, 0.0)
  ctx.line_to(0.0, 0.0)
  ctx.line_to(0.0, 1.0)
  ctx.line_to(1.0, 1.0)
  assert_pycairo_context_extents_close(ctx.fill_extents(), (0.0, 0.0, 1.0, 1.0))
}

///|
test "context line in_stroke mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.line_to(0.0, 0.0)
  ctx.line_to(1.0, 1.0)
  inspect(ctx.in_stroke(0.0, 0.0), content="true")
  inspect(ctx.in_stroke(0.0, 2.0), content="false")
}

///|
test "context current point mirrors pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  inspect(ctx.has_current_point(), content="false")
  assert_pycairo_context_point_close(ctx.get_current_point(), (0.0, 0.0))

  ctx.move_to(10.0, 10.0)
  inspect(ctx.has_current_point(), content="true")
  assert_pycairo_context_point_close(ctx.get_current_point(), (10.0, 10.0))
}

///|
test "context absolute path primitives mirror pycairo current-point fixtures" {
  let move_ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  move_ctx.move_to(10.0, 10.0)
  assert_pycairo_context_point_close(move_ctx.get_current_point(), (10.0, 10.0))

  let line_ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  line_ctx.line_to(1.0, 2.0)
  assert_pycairo_context_point_close(line_ctx.get_current_point(), (1.0, 2.0))

  let curve_ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  curve_ctx.move_to(0.0, 0.0)
  curve_ctx.curve_to(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
  assert_pycairo_context_point_close(curve_ctx.get_current_point(), (5.0, 6.0))
}

///|
test "context rectangle and relative path methods mirror pycairo fixtures" {
  let rectangle_ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  rectangle_ctx.rectangle(1.0, 2.0, 4.0, 5.0)
  assert_pycairo_context_extents_close(
    rectangle_ctx.path_extents(),
    (1.0, 2.0, 5.0, 7.0),
  )

  let rel_line_ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  rel_line_ctx.line_to(0.0, 0.0)
  rel_line_ctx.rel_line_to(1.0, 1.0)
  assert_pycairo_context_point_close(
    rel_line_ctx.get_current_point(),
    (1.0, 1.0),
  )

  let rel_move_ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  rel_move_ctx.line_to(0.0, 0.0)
  rel_move_ctx.rel_move_to(1.0, 1.0)
  assert_pycairo_context_point_close(
    rel_move_ctx.get_current_point(),
    (1.0, 1.0),
  )

  let rel_curve_ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  rel_curve_ctx.line_to(0.0, 0.0)
  rel_curve_ctx.rel_curve_to(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  assert_pycairo_context_point_close(
    rel_curve_ctx.get_current_point(),
    (0.0, 0.0),
  )
}

///|
test "context empty stroke_extents mirror pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  assert_pycairo_context_extents_close(
    ctx.stroke_extents(),
    (0.0, 0.0, 0.0, 0.0),
  )
}

///|
test "context default coordinate conversions mirror pycairo zero fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
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
test "context transformed coordinate conversions mirror pycairo fixture" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  ctx.translate(10.0, 20.0)
  ctx.scale(2.0, 4.0)

  assert_pycairo_context_matrix_close(
    ctx.get_matrix(),
    @cairoon.Matrix::new(xx=2.0, yy=4.0, x0=10.0, y0=20.0),
  )
  assert_pycairo_context_point_close(ctx.user_to_device(3.0, 5.0), (16.0, 40.0))
  assert_pycairo_context_point_close(
    ctx.user_to_device_distance(3.0, 5.0),
    (6.0, 20.0),
  )
  assert_pycairo_context_point_close(ctx.device_to_user(16.0, 40.0), (3.0, 5.0))
  assert_pycairo_context_point_close(
    ctx.device_to_user_distance(6.0, 20.0),
    (3.0, 5.0),
  )
}

///|
test "context matrix mutators mirror pycairo method fixtures" {
  let ctx = @cairoon.Context::new(pycairo_context_surface(42, 42))
  let identity = @cairoon.Matrix::new()
  ctx.set_matrix(identity)
  assert_pycairo_context_matrix_close(ctx.get_matrix(), identity)

  ctx.translate(0.5, 0.5)
  assert_pycairo_context_matrix_close(
    ctx.get_matrix(),
    @cairoon.Matrix::new(x0=0.5, y0=0.5),
  )

  ctx.scale(2.0, 3.0)
  assert_pycairo_context_matrix_close(
    ctx.get_matrix(),
    @cairoon.Matrix::new(xx=2.0, yy=3.0, x0=0.5, y0=0.5),
  )

  ctx.identity_matrix()
  let transform = @cairoon.Matrix::new(xx=2.0, yy=3.0, x0=5.0, y0=7.0)
  ctx.transform(transform)
  assert_pycairo_context_matrix_close(ctx.get_matrix(), transform)

  ctx.identity_matrix()
  ctx.rotate(0.3)
  assert_pycairo_context_matrix_close(
    ctx.get_matrix(),
    @cairoon.Matrix::init_rotate(0.3),
  )
}
