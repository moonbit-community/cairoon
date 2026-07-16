///|
fn context_matrix_surface() -> @cairoon.Surface raise @cairoon.CairoError {
  @cairoon.Surface::image(@cairoon.Argb32, 16, 16)
}

///|
fn assert_ctx_close(actual : Double, expected : Double) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected close doubles")
  }
}

///|
fn assert_ctx_matrix_close(
  actual : @cairoon.Matrix,
  expected : @cairoon.Matrix,
) -> Unit raise {
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
  let ctx = @cairoon.Context::new(context_matrix_surface())
  assert_ctx_matrix_close(ctx.get_matrix(), @cairoon.Matrix::new())
  let matrix = @cairoon.Matrix::new(
    xx=2.0,
    yx=0.5,
    xy=1.5,
    yy=3.0,
    x0=5.0,
    y0=7.0,
  )
  ctx.set_matrix(matrix)
  assert_ctx_matrix_close(ctx.get_matrix(), matrix)
  ctx.identity_matrix()
  assert_ctx_matrix_close(ctx.get_matrix(), @cairoon.Matrix::new())
}

///|
test "context translate scale rotate and transform update ctm" {
  let ctx = @cairoon.Context::new(context_matrix_surface())
  ctx.translate(5.0, 7.0)
  ctx.scale(2.0, 3.0)
  assert_ctx_matrix_close(
    ctx.get_matrix(),
    @cairoon.Matrix::new(xx=2.0, yy=3.0, x0=5.0, y0=7.0),
  )

  ctx.identity_matrix()
  ctx.rotate(0.5)
  assert_ctx_matrix_close(ctx.get_matrix(), @cairoon.Matrix::init_rotate(0.5))

  ctx.identity_matrix()
  let matrix = @cairoon.Matrix::new(xx=2.0, yy=3.0, x0=5.0, y0=7.0)
  ctx.transform(matrix)
  assert_ctx_matrix_close(ctx.get_matrix(), matrix)

  ctx.identity_matrix()
  ctx.translate(5.0, 7.0)
  ctx.transform(@cairoon.Matrix::new(xx=2.0, yy=3.0))
  let composed = @cairoon.Matrix::new(xx=2.0, yy=3.0, x0=5.0, y0=7.0)
  assert_ctx_matrix_close(ctx.get_matrix(), composed)
  ctx.save()
  ctx.identity_matrix()
  ctx.restore()
  assert_ctx_matrix_close(ctx.get_matrix(), composed)
}

///|
test "context user and device coordinate conversion follows ctm" {
  let ctx = @cairoon.Context::new(context_matrix_surface())
  ctx.translate(5.0, 7.0)
  ctx.scale(2.0, 3.0)
  assert_ctx_point_close(ctx.user_to_device(1.0, 1.0), (7.0, 10.0))
  assert_ctx_point_close(ctx.user_to_device_distance(1.0, 1.0), (2.0, 3.0))
  assert_ctx_point_close(ctx.device_to_user(7.0, 10.0), (1.0, 1.0))
  assert_ctx_point_close(ctx.device_to_user_distance(2.0, 3.0), (1.0, 1.0))
}

///|
test "context matrix mutators reject non-invertible transforms" {
  let set_ctx = @cairoon.Context::new(context_matrix_surface())
  let set_result = @cairoon.run_cairo(() => {
    set_ctx.set_matrix(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  match set_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix from set_matrix")
  }

  let scale_ctx = @cairoon.Context::new(context_matrix_surface())
  let scale_result = @cairoon.run_cairo(() => scale_ctx.scale(0.0, 1.0))
  match scale_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix from scale")
  }

  let transform_ctx = @cairoon.Context::new(context_matrix_surface())
  let transform_result = @cairoon.run_cairo(() => {
    transform_ctx.transform(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  match transform_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix from transform")
  }
}
