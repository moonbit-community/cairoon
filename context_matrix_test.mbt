///|
fn context_matrix_surface() -> Surface raise CairoError {
  Surface::image(Argb32, 16, 16)
}

///|
fn assert_ctx_close(actual : Double, expected : Double) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected close doubles")
  }
}

///|
fn assert_ctx_matrix_close(actual : Matrix, expected : Matrix) -> Unit raise {
  assert_ctx_close(actual.xx, expected.xx)
  assert_ctx_close(actual.yx, expected.yx)
  assert_ctx_close(actual.xy, expected.xy)
  assert_ctx_close(actual.yy, expected.yy)
  assert_ctx_close(actual.x0, expected.x0)
  assert_ctx_close(actual.y0, expected.y0)
}

///|
fn assert_ctx_point_close(
  actual : (Double, Double),
  expected : (Double, Double),
) -> Unit raise {
  let (actual_x, actual_y) = actual
  let (expected_x, expected_y) = expected
  assert_ctx_close(actual_x, expected_x)
  assert_ctx_close(actual_y, expected_y)
}

///|
test "context get set and identity matrix" {
  let ctx = Context::new(context_matrix_surface())
  assert_ctx_matrix_close(ctx.get_matrix(), Matrix::new())
  let matrix = Matrix::new(xx=2.0, yx=0.5, xy=1.5, yy=3.0, x0=5.0, y0=7.0)
  ctx.set_matrix(matrix)
  assert_ctx_matrix_close(ctx.get_matrix(), matrix)
  ctx.identity_matrix()
  assert_ctx_matrix_close(ctx.get_matrix(), Matrix::new())
}

///|
test "context translate scale rotate and transform update ctm" {
  let ctx = Context::new(context_matrix_surface())
  ctx.translate(5.0, 7.0)
  ctx.scale(2.0, 3.0)
  assert_ctx_matrix_close(
    ctx.get_matrix(),
    Matrix::new(xx=2.0, yy=3.0, x0=5.0, y0=7.0),
  )

  ctx.identity_matrix()
  ctx.rotate(0.5)
  assert_ctx_matrix_close(ctx.get_matrix(), Matrix::init_rotate(0.5))

  ctx.identity_matrix()
  let matrix = Matrix::new(xx=2.0, yy=3.0, x0=5.0, y0=7.0)
  ctx.transform(matrix)
  assert_ctx_matrix_close(ctx.get_matrix(), matrix)
}

///|
test "context user and device coordinate conversion follows ctm" {
  let ctx = Context::new(context_matrix_surface())
  ctx.translate(5.0, 7.0)
  ctx.scale(2.0, 3.0)
  assert_ctx_point_close(ctx.user_to_device(1.0, 1.0), (7.0, 10.0))
  assert_ctx_point_close(ctx.user_to_device_distance(1.0, 1.0), (2.0, 3.0))
  assert_ctx_point_close(ctx.device_to_user(7.0, 10.0), (1.0, 1.0))
  assert_ctx_point_close(ctx.device_to_user_distance(2.0, 3.0), (1.0, 1.0))
}

///|
test "context set_matrix invalid matrix maps to cairo error" {
  let ctx = Context::new(context_matrix_surface())
  let result = run_cairo(() => ctx.set_matrix(Matrix::new(xx=0.0, yy=0.0)))
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
